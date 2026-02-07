import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _apiKey = '33fbdc0f';
  static const String _baseUrl = 'http://www.omdbapi.com/';

  /// Search movies by keyword
  Future<List<Movie>> searchMovies(String query, {int page = 1, String? type, String? year}) async {
    String urlStr = '$_baseUrl?s=$query&page=$page&apikey=$_apiKey';
    if (type != null) urlStr += '&type=$type';
    if (year != null) urlStr += '&y=$year';
    final url = Uri.parse(urlStr);
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

  /// Search movies and fetch IMDb ratings for each result
  Future<List<Movie>> searchMoviesWithRatings(String query, {String? type, String? year}) async {
    final movies = await searchMovies(query, type: type, year: year);
    List<Movie> moviesWithRatings = [];
    for (final movie in movies) {
      final rating = await _fetchRating(movie.imdbId);
      moviesWithRatings.add(movie.copyWith(imdbRating: rating));
    }
    return moviesWithRatings;
  }

  /// Search by category (predefined popular queries per genre)
  Future<List<Movie>> searchByCategory(String category) async {
    final Map<String, String> categoryQueries = {
      'Top Rated': 'dark knight',
      'Latest 2025': 'movie',
      'Action': 'action hero',
      'Comedy': 'comedy fun',
      'Sci-Fi': 'space future',
      'Horror': 'horror night',
      'Romance': 'love story',
      'Thriller': 'thriller mystery',
    };

    final Map<String, String?> categoryTypes = {
      'Top Rated': null,
      'Latest 2025': null,
      'Action': 'movie',
      'Comedy': 'movie',
      'Sci-Fi': 'movie',
      'Horror': 'movie',
      'Romance': 'movie',
      'Thriller': 'movie',
    };

    final Map<String, String?> categoryYears = {
      'Latest 2025': '2025',
    };

    final query = categoryQueries[category] ?? category;
    final type = categoryTypes[category];
    final year = categoryYears[category];

    return searchMoviesWithRatings(query, type: type, year: year);
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

  /// Fetch IMDb rating for a single movie by its ID
  Future<String> _fetchRating(String imdbId) async {
    try {
      final url = Uri.parse('$_baseUrl?i=$imdbId&apikey=$_apiKey');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Response'] == 'True') {
          return data['imdbRating'] ?? 'N/A';
        }
      }
    } catch (_) {}
    return 'N/A';
  }

  /// Initial trending search terms
  static const List<String> _trendingSearches = [
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

  /// Additional search terms for "Explore More"
  static const List<String> _exploreSearches = [
    'Matrix',
    'Gladiator',
    'Titanic',
    'Joker',
    'Deadpool',
    'Mission Impossible',
    'Harry Potter',
    'Lord Rings',
    'Jurassic',
    'Transformers',
    'Pirates Caribbean',
    'Iron Man',
    'Thor',
    'Guardians Galaxy',
    'Black Panther',
  ];

  int _exploreIndex = 0;

  /// Reset explore index (call when refreshing)
  void resetExplore() {
    _exploreIndex = 0;
  }

  /// Fetch a curated list of trending/popular movies with ratings
  Future<List<Movie>> getTrendingMovies() async {
    _exploreIndex = 0;
    return _fetchMoviesFromSearches(_trendingSearches);
  }

  /// Load more movies for the "Explore More" feature
  Future<List<Movie>> loadMoreMovies() async {
    const batchSize = 5;
    final start = _exploreIndex;
    final end = (_exploreIndex + batchSize).clamp(0, _exploreSearches.length);

    if (start >= _exploreSearches.length) {
      return []; // No more to load
    }

    final searches = _exploreSearches.sublist(start, end);
    _exploreIndex = end;
    return _fetchMoviesFromSearches(searches);
  }

  /// Whether there are more movies available to explore
  bool get hasMoreToExplore => _exploreIndex < _exploreSearches.length;

  Future<List<Movie>> _fetchMoviesFromSearches(List<String> searches) async {
    List<Movie> allMovies = [];

    for (final query in searches) {
      try {
        final movies = await searchMovies(query);
        if (movies.isNotEmpty) {
          final movie = movies.first;
          final rating = await _fetchRating(movie.imdbId);
          allMovies.add(movie.copyWith(imdbRating: rating));
        }
      } catch (_) {
        // Skip failed searches
      }
    }

    return allMovies;
  }
}
