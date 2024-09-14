class Movie {
  final String title;
  final String posterPath;
  final double? rating; // Make rating optional
  final String overview;

  Movie({
    required this.title,
    required this.posterPath,
    this.rating, // Optional field
    required this.overview,
  });
  // Create a Movie instance from JSON
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] ?? 'Unknown Title',
      posterPath: json['poster_path'] ?? '',
      overview: json['overview'] ?? 'No description available',
      rating: (json['vote_average'] ?? 0).toDouble(),
    );
  }

  // Build the full image URL for the poster
  String get imageUrl => 'https://image.tmdb.org/t/p/w500$posterPath';
}
