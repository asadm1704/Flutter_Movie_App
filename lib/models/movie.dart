class Movie {
  final String title;
  final String year;
  final String imdbId;
  final String type;
  final String poster;
  final String imdbRating;

  Movie({
    required this.title,
    required this.year,
    required this.imdbId,
    required this.type,
    required this.poster,
    this.imdbRating = 'N/A',
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'] ?? '',
      year: json['Year'] ?? '',
      imdbId: json['imdbID'] ?? '',
      type: json['Type'] ?? '',
      poster: json['Poster'] ?? 'N/A',
      imdbRating: json['imdbRating'] ?? 'N/A',
    );
  }

  Movie copyWith({String? imdbRating}) {
    return Movie(
      title: title,
      year: year,
      imdbId: imdbId,
      type: type,
      poster: poster,
      imdbRating: imdbRating ?? this.imdbRating,
    );
  }
}

class MovieDetail {
  final String title;
  final String year;
  final String rated;
  final String released;
  final String runtime;
  final String genre;
  final String director;
  final String writer;
  final String actors;
  final String plot;
  final String language;
  final String country;
  final String awards;
  final String poster;
  final String imdbRating;
  final String imdbVotes;
  final String imdbId;
  final String boxOffice;

  MovieDetail({
    required this.title,
    required this.year,
    required this.rated,
    required this.released,
    required this.runtime,
    required this.genre,
    required this.director,
    required this.writer,
    required this.actors,
    required this.plot,
    required this.language,
    required this.country,
    required this.awards,
    required this.poster,
    required this.imdbRating,
    required this.imdbVotes,
    required this.imdbId,
    required this.boxOffice,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      title: json['Title'] ?? '',
      year: json['Year'] ?? '',
      rated: json['Rated'] ?? 'N/A',
      released: json['Released'] ?? 'N/A',
      runtime: json['Runtime'] ?? 'N/A',
      genre: json['Genre'] ?? 'N/A',
      director: json['Director'] ?? 'N/A',
      writer: json['Writer'] ?? 'N/A',
      actors: json['Actors'] ?? 'N/A',
      plot: json['Plot'] ?? 'N/A',
      language: json['Language'] ?? 'N/A',
      country: json['Country'] ?? 'N/A',
      awards: json['Awards'] ?? 'N/A',
      poster: json['Poster'] ?? 'N/A',
      imdbRating: json['imdbRating'] ?? 'N/A',
      imdbVotes: json['imdbVotes'] ?? 'N/A',
      imdbId: json['imdbID'] ?? '',
      boxOffice: json['BoxOffice'] ?? 'N/A',
    );
  }
}
