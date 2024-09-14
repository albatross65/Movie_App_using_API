import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'movie_model.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // Add movie to favorites
  Future<void> addFavorite(Movie movie) async {
    await _firestore.collection('users/$userId/favorites').add({
      'title': movie.title,
      'posterPath': movie.posterPath,
      'rating': movie.rating,  // Ensure this is saved
      'overview': movie.overview,
    });
  }


  // Remove movie from favorites
  Future<void> removeFavorite(String movieTitle) async {
    final snapshot = await _firestore
        .collection('users/$userId/favorites')
        .where('title', isEqualTo: movieTitle)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete(); // Remove movie from Firestore
    }
  }

  // Check if a movie is in favorites
  Future<bool> isFavorite(String movieTitle) async {
    final snapshot = await _firestore
        .collection('users/$userId/favorites')
        .where('title', isEqualTo: movieTitle)
        .get();
    return snapshot.docs.isNotEmpty;
  }
  Future<List<Movie>> fetchFavorites() async {
    final snapshot = await _firestore.collection('users/$userId/favorites').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Movie(
        title: data['title'],
        posterPath: data['posterPath'],
        rating: data['rating'],  // Pass the rating value here
        overview: data['overview'],
      );
    }).toList();
  }
}
