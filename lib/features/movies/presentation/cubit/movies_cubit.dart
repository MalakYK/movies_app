import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/movie_model.dart';
import '../../data/movie_api_service.dart';

part 'movies_state.dart';

class MoviesCubit extends Cubit<MoviesState> {
  final MovieApiService api;

  MoviesCubit(this.api) : super(const MoviesState.initial());

  Future<void> loadHome() async {
    emit(state.copyWith(status: MoviesStatus.loading));
    try {
      final movies = await api.getMovies();
      emit(state.copyWith(status: MoviesStatus.success, movies: movies));
    } catch (e) {
      emit(state.copyWith(status: MoviesStatus.failure, error: e.toString()));
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      return loadHome();
    }
    emit(state.copyWith(status: MoviesStatus.loading));
    try {
      final movies = await api.getMovies(
        queryTerm: query.trim(),
        sortBy: 'rating',
      );
      emit(state.copyWith(status: MoviesStatus.success, movies: movies));
    } catch (e) {
      emit(state.copyWith(status: MoviesStatus.failure, error: e.toString()));
    }
  }

  Future<void> byGenre(String genre) async {
    emit(state.copyWith(status: MoviesStatus.loading, selectedGenre: genre));
    try {
      final movies = await api.getMovies(
        genre: genre == 'All' ? null : genre,
        sortBy: 'rating',
      );
      emit(state.copyWith(status: MoviesStatus.success, movies: movies));
    } catch (e) {
      emit(state.copyWith(status: MoviesStatus.failure, error: e.toString()));
    }
  }
}
