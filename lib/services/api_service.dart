import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _apiKey = '33fbdc0f';
  static const String _baseUrl = 'http://www.omdbapi.com/';

  /// Search movies by keyword
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final url = Uri.parse('$_baseUrl?s=$query&page=$page&apikey=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Response'] == 'True') {
        final List results = data['Search'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load movies');
    }
  }

  /// Get full movie details by IMDb ID
  Future<MovieDetail> getMovieDetail(String imdbId) async {
    final url = Uri.parse('$_baseUrl?i=$imdbId&plot=full&apikey=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Response'] == 'True') {
        return MovieDetail.fromJson(data);
      } else {
        throw Exception(data['Error'] ?? 'Movie not found');
      }
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  /// Fetch a curated list of trending/popular movies
  /// OMDb doesn't have a "trending" endpoint, so we search popular keywords
  Future<List<Movie>> getTrendingMovies() async {
    final trendingSearches = [
      'Avengers',
      'Batman',
      'Spider',
      'Star Wars',
      'John Wick',
      'Fast Furious',
      'Inception',
      'Interstellar',
      'Oppenheimer',
      'Dune',
    ];

    List<Movie> allMovies = [];

    for (final query in trendingSearches) {
      try {
        final movies = await searchMovies(query);
        if (movies.isNotEmpty) {
          allMovies.add(movies.first);
        }
      } catch (_) {
        // Skip failed searches
      }
    }

    return allMovies;
  }
}
