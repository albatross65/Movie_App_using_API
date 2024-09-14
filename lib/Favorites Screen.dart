import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'favorite_service.dart';
import 'movie_tile.dart';
import 'movie_model.dart';
import 'shimmer_loading.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  List<Movie> favoriteMovies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteMovies();
  }

  Future<void> _fetchFavoriteMovies() async {
    try {
      final favorites = await FavoriteService().fetchFavorites();
      setState(() {
        favoriteMovies = favorites;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching favorites: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Drawer icon color
        ),
        title: Text(
          'Your Favorites',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.deepPurple.shade800,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade800,
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade200,
              Colors.deepPurple.shade800,
            ],
          ),
        ),
        child: isLoading
            ? ShimmerLoading()
            : favoriteMovies.isEmpty
            ? _buildEmptyState()
            : _buildFavoritesGrid(),
      ),
    );
  }

  // Build the empty state when no favorites are present
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/empty_state.json', height: 200),
          SizedBox(height: 20),
          Text(
            'No favorites yet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Start adding some movies to your favorites.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // Build the favorites grid with fade-in animation
  Widget _buildFavoritesGrid() {
    return MasonryGridView.builder(
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: favoriteMovies.length,
      itemBuilder: (BuildContext context, int index) {
        final movie = favoriteMovies[index];
        return FadeInMovieTile(movie: movie); // Added fade-in effect
      },
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
    );
  }
}

// Movie tile with fade-in animation
class FadeInMovieTile extends StatefulWidget {
  final Movie movie;

  FadeInMovieTile({required this.movie});

  @override
  _FadeInMovieTileState createState() => _FadeInMovieTileState();
}

class _FadeInMovieTileState extends State<FadeInMovieTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: MovieTile(
        movie: widget.movie,
        showUnlikeAnimation: false, // Hide unlike animation
      ),
    );
  }
}
