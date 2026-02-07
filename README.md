# Flutter Movie App

A beautiful Flutter movie application that lets you browse trending movies, search for any movie, and view detailed information including IMDb ratings — all powered by the [OMDb API](http://www.omdbapi.com/).

## Features

- **Trending Movies** — Curated list of popular movies displayed on the home screen
- **Smart Search with Filter Chips** — Tap the search bar to reveal quick filter categories:
  - Top Rated, Latest 2025, Action, Comedy, Sci-Fi, Horror, Romance, Thriller
  - Each filter fetches movies in that category with IMDb ratings
  - Active filter is highlighted for quick reference
- **Search** — Search any movie by title with instant results
- **IMDb Ratings** — View IMDb ratings alongside the year on every movie card
- **Explore More** — Load additional movies with a single tap at the bottom of the list
- **Movie Details** — Full movie info including:
  - Poster, Title, Year, Runtime, Rated
  - Genre tags
  - Full plot description
  - Director, Writers, Actors
  - Awards, Box Office, Language, Country
  - IMDb Votes
- **Dark Theme** — Modern dark UI with amber accents
- **Pull to Refresh** — Pull down to refresh the trending movies list
- **Smooth Navigation** — Tap any movie card to see its full details with a hero-style poster

## Screenshots

| Home Screen | Movie Detail |
|:-----------:|:------------:|
| Trending movies list with search | Full movie info with poster |

## Project Structure

```
lib/
├── main.dart                    # App entry point & theme configuration
├── models/
│   └── movie.dart               # Movie & MovieDetail data models
├── services/
│   └── api_service.dart         # OMDb API service layer
└── screens/
    ├── home_screen.dart         # Home screen with trending & search
    └── movie_detail_screen.dart # Detailed movie information screen
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10+)
- An [OMDb API Key](http://www.omdbapi.com/apikey.aspx) (free tier available)
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/asadm1704/Flutter_Movie_App.git
   cd Flutter_Movie_App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add your OMDb API Key**

   Open `lib/services/api_service.dart` and replace the API key:
   ```dart
   static const String _apiKey = 'YOUR_API_KEY_HERE';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Dependencies

| Package | Purpose |
|---------|---------|
| [`http`](https://pub.dev/packages/http) | Making HTTP requests to the OMDb API |
| [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) | iOS-style icons |

## API Configuration

This app uses the [OMDb API](http://www.omdbapi.com/) to fetch movie data.

1. Visit [OMDb API Key](http://www.omdbapi.com/apikey.aspx) to get a free API key
2. **Activate** your key via the confirmation email
3. Add the key in `lib/services/api_service.dart`

## Built With

- **Flutter** — UI framework
- **Dart** — Programming language
- **OMDb API** — Movie data provider
- **Material Design 3** — Design system

## License

This project is open source and available under the [MIT License](LICENSE).

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to open an issue or submit a pull request.

---

Made with Flutter
