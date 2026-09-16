import 'package:equatable/equatable.dart';

import '../../../movies/data/models/movie_model.dart';

enum MovieDetailsStatus {
  initial,
  loading,
  success,
  failure,
}

class MovieDetailsState extends Equatable {
  final MovieDetailsStatus status;
  final MovieModel? movie;
  final List<MovieModel> suggestions;
  final String? errorMessage;

  const MovieDetailsState({
    this.status = MovieDetailsStatus.initial,
    this.movie,
    this.suggestions = const [],
    this.errorMessage,
  });

  MovieDetailsState copyWith({
    MovieDetailsStatus? status,
    MovieModel? movie,
    List<MovieModel>? suggestions,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MovieDetailsState(
      status: status ?? this.status,
      movie: movie ?? this.movie,
      suggestions: suggestions ?? this.suggestions,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    movie,
    suggestions,
    errorMessage,
  ];
}