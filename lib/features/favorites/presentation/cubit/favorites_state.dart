part of 'favorites_cubit.dart';

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<MovieModel> movies;
  final String? message;

  const FavoritesState._({
    required this.status,
    this.movies = const [],
    this.message,
  });

  const FavoritesState.initial() : this._(status: FavoritesStatus.initial);
  const FavoritesState.loading() : this._(status: FavoritesStatus.loading);
  const FavoritesState.loaded(List<MovieModel> movies)
      : this._(status: FavoritesStatus.loaded, movies: movies);
  const FavoritesState.failure(String message)
      : this._(status: FavoritesStatus.failure, message: message);

  @override
  List<Object?> get props => [status, movies, message];
}

enum FavoritesStatus { initial, loading, loaded, failure }
