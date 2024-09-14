import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'MovieDetailsPage.dart'; // Ensure this is imported correctly
import 'movie_model.dart';
import 'favorite_service.dart'; // Import favorite service to handle likes

class MovieCarousel extends StatefulWidget {
  final List<Movie> movies;

  MovieCarousel({required this.movies});

  @override
  _MovieCarouselState createState() => _MovieCarouselState();
}

class _MovieCarouselState extends State<MovieCarousel> {
  final FavoriteService favoriteService = FavoriteService();
  late Map<String, bool> favoriteStatusMap;

  @override
  void initState() {
    super.initState();
    // Initialize favorite status for each movie
    favoriteStatusMap = {
      for (var movie in widget.movies) movie.title: false,
    };
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    // Check if each movie is already a favorite
    for (var movie in widget.movies) {
      bool isFavorite = await favoriteService.isFavorite(movie.title);
      setState(() {
        favoriteStatusMap[movie.title] = isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite(Movie movie) async {
    bool isFavorite = favoriteStatusMap[movie.title] ?? false;

    if (isFavorite) {
      await favoriteService.removeFavorite(movie.title);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${movie.title} removed from favorites")),
      );
    } else {
      await favoriteService.addFavorite(movie);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${movie.title} added to favorites")),
      );
    }

    setState(() {
      favoriteStatusMap[movie.title] = !isFavorite; // Toggle local state
    });
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: widget.movies.length,
      itemBuilder: (context, index, realIndex) {
        final movie = widget.movies[index];
        bool isFavorite = favoriteStatusMap[movie.title] ?? false;

        return GestureDetector(
          onTap: () {
            // Navigate to the MovieDetailsPage when a movie is clicked
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailsPage(movie: movie),
              ),
            );
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 400, // Fixed height for consistency
                ),
              ),
              // Gradient overlay to enhance readability
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7), // Darker gradient at the bottom
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              // Optional: Add movie rating or other info in the top corner
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '⭐ ${movie.rating.toString()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              // Like button with animation
              Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    _toggleFavorite(movie); // Toggle favorite status
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isFavorite) // Show Lottie animation when liked
                        Lottie.asset(
                          'assets/like_animation.json', // Lottie animation for liking
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
        );
      },
      options: CarouselOptions(
        height: 400,
        autoPlay: true,
        enlargeCenterPage: true,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.easeInOut, // Smoother transition curve
        aspectRatio: 16 / 9,
        viewportFraction: 0.85, // Display part of the next and previous movies
      ),
    );
  }
}
