part of 'movies_cubit.dart';

enum MoviesStatus { initial, loading, success, failure }

class MoviesState extends Equatable {
  final MoviesStatus status;
  final List<MovieModel> movies;
  final String? error;
  final String selectedGenre;

  const MoviesState({
    required this.status,
    this.movies = const [],
    this.error,
    this.selectedGenre = 'All',
  });

  const MoviesState.initial() : this(status: MoviesStatus.initial);

  MoviesState copyWith({
    MoviesStatus? status,
    List<MovieModel>? movies,
    String? error,
    String? selectedGenre,
  }) {
    return MoviesState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      error: error,
      selectedGenre: selectedGenre ?? this.selectedGenre,
    );
  }

  @override
  List<Object?> get props => [status, movies, error, selectedGenre];
}
