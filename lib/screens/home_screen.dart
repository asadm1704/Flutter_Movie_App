import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Movie> _trendingMovies = [];
  List<Movie> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isLoadingMore = false;
  bool _showFilters = false;
  String? _activeFilter;
  String? _error;

  static const List<Map<String, dynamic>> _searchFilters = [
    {'label': 'Top Rated', 'icon': Icons.star},
    {'label': 'Latest 2025', 'icon': Icons.new_releases},
    {'label': 'Action', 'icon': Icons.local_fire_department},
    {'label': 'Comedy', 'icon': Icons.sentiment_very_satisfied},
    {'label': 'Sci-Fi', 'icon': Icons.rocket_launch},
    {'label': 'Horror', 'icon': Icons.visibility},
    {'label': 'Romance', 'icon': Icons.favorite},
    {'label': 'Thriller', 'icon': Icons.psychology},
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _showFilters = _searchFocusNode.hasFocus;
      });
    });
    _loadTrendingMovies();
  }

  Future<void> _loadTrendingMovies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final movies = await _apiService.getTrendingMovies();
      setState(() {
        _trendingMovies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchMovies(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _activeFilter = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
      _error = null;
      _activeFilter = null;
      _showFilters = false;
    });
    _searchFocusNode.unfocus();

    try {
      final movies = await _apiService.searchMoviesWithRatings(query);
      setState(() {
        _searchResults = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchByFilter(String category) async {
    setState(() {
      _isSearching = true;
      _isLoading = true;
      _error = null;
      _activeFilter = category;
      _showFilters = false;
    });
    _searchFocusNode.unfocus();
    _searchController.text = category;

    try {
      final movies = await _apiService.searchByCategory(category);
      // Sort by rating for "Top Rated"
      if (category == 'Top Rated') {
        movies.sort((a, b) {
          final rA = double.tryParse(a.imdbRating) ?? 0;
          final rB = double.tryParse(b.imdbRating) ?? 0;
          return rB.compareTo(rA);
        });
      }
      setState(() {
        _searchResults = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreMovies() async {
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final moreMovies = await _apiService.loadMoreMovies();
      setState(() {
        _trendingMovies.addAll(moreMovies);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moviesToShow = _isSearching ? _searchResults : _trendingMovies;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C2E),
      appBar: AppBar(
        title: const Text(
          'Movie App',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF1C1C2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by title, rating, genre...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon:
                    _isSearching
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _isSearching = false;
                              _searchResults = [];
                              _activeFilter = null;
                              _showFilters = false;
                            });
                          },
                        )
                        : null,
                filled: true,
                fillColor: const Color(0xFF2A2A3D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _searchMovies,
            ),
          ),

          // Filter Chips
          if (_showFilters || _activeFilter != null)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _searchFilters.length,
                itemBuilder: (context, index) {
                  final filter = _searchFilters[index];
                  final isActive = _activeFilter == filter['label'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      avatar: Icon(
                        filter['icon'] as IconData,
                        size: 16,
                        color: isActive ? Colors.black : Colors.amber,
                      ),
                      label: Text(filter['label'] as String),
                      labelStyle: TextStyle(
                        color: isActive ? Colors.black : Colors.white,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      selected: isActive,
                      onSelected: (_) => _searchByFilter(filter['label'] as String),
                      backgroundColor: const Color(0xFF2A2A3D),
                      selectedColor: Colors.amber,
                      checkmarkColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isActive ? Colors.amber : Colors.grey[700]!,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Section Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _activeFilter != null
                    ? _activeFilter!
                    : _isSearching
                        ? 'Search Results'
                        : 'Trending Movies',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Movie List
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    )
                    : _error != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Something went wrong',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadTrendingMovies,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : moviesToShow.isEmpty
                    ? Center(
                      child: Text(
                        _isSearching
                            ? 'No movies found'
                            : 'No trending movies',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadTrendingMovies,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: moviesToShow.length + (_isSearching ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (index < moviesToShow.length) {
                            return _MovieCard(movie: moviesToShow[index]);
                          }
                          // Explore More button
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24, top: 8),
                            child: Center(
                              child: _isLoadingMore
                                  ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                      color: Colors.amber,
                                    ),
                                  )
                                  : _apiService.hasMoreToExplore
                                      ? ElevatedButton.icon(
                                        onPressed: _loadMoreMovies,
                                        icon: const Icon(Icons.explore),
                                        label: const Text('Explore More'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                      : Text(
                                        'You\'ve explored all movies!',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                      ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    final hasValidPoster =
        movie.poster != 'N/A' && movie.poster.startsWith('http');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailScreen(imdbId: movie.imdbId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A3D),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 100,
                height: 150,
                child:
                    hasValidPoster
                        ? Image.network(
                          movie.poster,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.amber,
                              ),
                            );
                          },
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                        )
                        : Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.movie,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.year,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (movie.imdbRating != 'N/A') ...[
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.imdbRating,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        movie.type.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Arrow
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
