import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../movies/data/movie_api_service.dart';
import 'movie_details_state.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  final MovieApiService _api;

  MovieDetailsCubit({
    MovieApiService? api,
  })  : _api = api ?? MovieApiService(),
        super(const MovieDetailsState());

  Future<void> loadMovieDetails(int movieId) async {
    emit(
      state.copyWith(
        status: MovieDetailsStatus.loading,
        clearError: true,
      ),
    );

    try {
      final movie = await _api.getMovieDetails(movieId);

      final suggestions =
      await _api.getSuggestions(movieId);

      emit(
        MovieDetailsState(
          status: MovieDetailsStatus.success,
          movie: movie,
          suggestions: suggestions,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MovieDetailsStatus.failure,
          errorMessage:
          'Unable to load movie details.',
        ),
      );
    }
  }

  Future<void> retry(int movieId) async {
    await loadMovieDetails(movieId);
  }
}