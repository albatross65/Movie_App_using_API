import 'dart:math'; // For shuffling
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'Favorites Screen.dart';
import 'main.dart';
import 'movie_tile.dart';
import 'movie_service.dart';
import 'movie_model.dart';
import 'shimmer_loading.dart';
import 'auth_service.dart'; // AuthService for logout
import 'movie_carousel.dart'; // Import MovieCarousel

class MovieGrid extends StatefulWidget {
  @override
  _MovieGridState createState() => _MovieGridState();
}

class _MovieGridState extends State<MovieGrid> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _drawerController;
  late Animation<Offset> _drawerSlideAnimation;

  List<Movie> movies = [];
  List<Movie> featuredMovies = []; // For the MovieCarousel
  int page = 1;
  bool isLoadingMore = false;
  bool hasMore = true;
  bool isLoadingInitialData = true;
  bool hasError = false;

  final AuthService _authService = AuthService(); // Instance of AuthService

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener); // Add scroll listener for pagination
    _fetchMovies();

    // Drawer animation setup
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _drawerSlideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut));
    _drawerController.forward(); // Start the drawer slide-in animation
  }

  Future<void> _fetchMovies() async {
    if (isLoadingMore || !hasMore) return; // Prevent multiple fetches
    setState(() {
      isLoadingMore = true;
      if (movies.isEmpty) {
        isLoadingInitialData = true;
      }
      hasError = false;
    });

    try {
      final newMovies = await MovieService().fetchTrendingMovies(page: page);
      setState(() {
        if (newMovies.isEmpty) {
          hasMore = false;
        } else {
          movies.addAll(newMovies);
          featuredMovies = movies.take(5).toList(); // First 5 movies for carousel
          movies.shuffle(Random()); // Shuffle the movies for variety
          page++; // Increment page for next fetch
        }
      });
    } catch (e) {
      print('Error fetching movies: $e');
      setState(() {
        hasError = true;
      });
    }

    setState(() {
      isLoadingMore = false;
      isLoadingInitialData = false;
    });
  }

  // Listener for detecting when user scrolls to the bottom to load more movies
  void _scrollListener() {
    if (_scrollController.position.extentAfter < 300 && !isLoadingMore && hasMore) {
      _fetchMovies(); // Fetch more movies when user scrolls near the bottom
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Drawer icon color
        ),
        title: Center(
          child: Text(
            'Trending Movies',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.deepPurple.shade800,
      ),
      drawer: SlideTransition(
        position: _drawerSlideAnimation,
        child: Drawer(
          child: Container(
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
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Text('Movie Browser',
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                ListTile(
                  leading: Icon(Icons.favorite, color: Colors.white),
                  title: Text('Favorites', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FavoritesScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.white), // White icon
                  title: Text('Logout', style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    await _authService.signOut();
                    // Navigate to the SignInScreen after logout
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => SignInScreen(authService: _authService)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
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
        child: SingleChildScrollView(
          controller: _scrollController, // Enable scrolling for the entire view
          child: Column(
            children: [
              // Add the MovieCarousel at the top
              featuredMovies.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: MovieCarousel(movies: featuredMovies),
              )
                  : SizedBox.shrink(),
              SizedBox(height: 20),
              // Show grid below the carousel
              MasonryGridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // Prevents grid from scrolling separately
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: movies.length + (isLoadingMore ? 1 : 0), // Infinite loading support
                itemBuilder: (BuildContext context, int index) {
                  if (index < movies.length) {
                    final movie = movies[index];
                    return MovieTile(
                      movie: movie,
                      showUnlikeAnimation: false, // Disable unlike animation
                    );
                  } else {
                    return Center(
                      child: Lottie.asset(
                        'assets/loading_animation.json',
                        width: 200,
                        height: 200,
                        alignment: Alignment.center, // Center the loading animation
                      ),
                    );
                  }
                },
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
