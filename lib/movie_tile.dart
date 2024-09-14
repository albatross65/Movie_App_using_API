import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'MovieDetailsPage.dart';
import 'movie_model.dart';
import 'favorite_service.dart';

class MovieTile extends StatefulWidget {
  final Movie movie;
  final bool showUnlikeAnimation;

  MovieTile({required this.movie, this.showUnlikeAnimation = true});

  @override
  _MovieTileState createState() => _MovieTileState();
}

class _MovieTileState extends State<MovieTile> with SingleTickerProviderStateMixin {
  final FavoriteService favoriteService = FavoriteService();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // Check if the movie is already a favorite
  Future<void> _checkFavoriteStatus() async {
    final favoriteStatus = await favoriteService.isFavorite(widget.movie.title);
    setState(() {
      isFavorite = favoriteStatus;
    });
  }

  // Toggle favorite status when like button is tapped
  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      await favoriteService.removeFavorite(widget.movie.title);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${widget.movie.title} removed from favorites")),
      );
    } else {
      await favoriteService.addFavorite(widget.movie);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${widget.movie.title} added to favorites")),
      );
    }
    setState(() {
      isFavorite = !isFavorite; // Toggle the favorite status locally
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                MovieDetailsPage(movie: widget.movie),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var fadeTween = Tween(begin: 0.0, end: 1.0);
              var fadeAnimation = animation.drive(fadeTween);

              return FadeTransition(
                opacity: fadeAnimation,
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              spreadRadius: 2.0,
              offset: Offset(5.0, 5.0),
            ),
          ],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Stack(
          children: [
            Hero(
              tag: widget.movie.title, // Unique Hero tag for each movie
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  widget.movie.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            // Add Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent, // Top part transparent
                    Colors.black.withOpacity(0.7), // Bottom part with dark opacity
                  ],
                ),
              ),
            ),
            // Like button with animation
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: _toggleFavorite, // Handle the like toggle
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isFavorite) // Show Lottie animation when liked
                      Lottie.asset(
                        'assets/like_animation.json',
                        width: 50,
                        height: 50,
                      ),
                    Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
