part of 'browse_cubit.dart';

enum BrowseStatus {
  initial,
  loading,
  success,
  failure,
}

class BrowseState extends Equatable {
  final BrowseStatus status;
  final List<MovieModel> movies;
  final List<MovieModel> allMovies;
  final List<String> genres;
  final String selectedGenre;
  final String? error;

  const BrowseState({
    required this.status,
    this.movies = const [],
    this.allMovies = const [],
    this.genres = const [],
    this.selectedGenre = 'All',
    this.error,
  });

  const BrowseState.initial()
      : this(
    status: BrowseStatus.initial,
  );

  const BrowseState.success({
    required this.movies,
    required this.allMovies,
    required this.genres,
    required this.selectedGenre,
  })  : status = BrowseStatus.success,
        error = null;

  BrowseState copyWith({
    BrowseStatus? status,
    List<MovieModel>? movies,
    List<MovieModel>? allMovies,
    List<String>? genres,
    String? selectedGenre,
    String? error,
    bool clearError = false,
  }) {
    return BrowseState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      allMovies: allMovies ?? this.allMovies,
      genres: genres ?? this.genres,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    movies,
    allMovies,
    genres,
    selectedGenre,
    error,
  ];
}