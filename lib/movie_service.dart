import 'package:http/http.dart' as http;
import 'dart:convert';
import 'movie_model.dart';

class MovieService {
  final String bearerToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5MmQwYjhmODk1ZTQ0OWE3NWUwMmEwNWMxZWY5NGU4ZSIsIm5iZiI6MTcyNjE4MzAyNi4xNjQ2MzksInN1YiI6IjY2ZTM3NTgwOTAxM2ZlODcyMjIzY2EzZiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.sBM4uM2cFL60W_EoOzTWO3G0mtjCAFAdxV1GTB0QRqs';

  // Fetch trending movies with pagination
  Future<List<Movie>> fetchTrendingMovies({int page = 1}) async {
    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/trending/movie/week?page=$page'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json;charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List results = jsonResponse['results'] ?? [];

      if (results.isNotEmpty) {
        return results.map((movie) => Movie.fromJson(movie)).toList();
      } else {
        throw Exception('No movies found in the response.');
      }
    } else {
      throw Exception('Failed to load trending movies. Status code: ${response.statusCode}');
    }
  }
}
