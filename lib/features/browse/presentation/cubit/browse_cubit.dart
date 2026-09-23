import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../movies/data/models/movie_model.dart';
import '../../../movies/data/movie_api_service.dart';

part 'browse_state.dart';

class BrowseCubit extends Cubit<BrowseState> {
  final MovieApiService api;

  BrowseCubit(this.api) : super(const BrowseState.initial());

  Future<void> loadBrowse() async {
    emit(
      state.copyWith(
        status: BrowseStatus.loading,
        clearError: true,
      ),
    );

    try {
      final movies = await api.getMovies(
        page: 1,
        limit: 50,
        sortBy: 'date_added',
        orderBy: 'desc',
      );

      final genreSet = <String>{};

      for (final movie in movies) {
        for (final genre in movie.genres) {
          final value = genre.trim();

          if (value.isNotEmpty) {
            genreSet.add(value);
          }
        }
      }

      final genres = genreSet.toList()..sort();

      emit(
        BrowseState.success(
          movies: movies,
          allMovies: movies,
          genres: genres,
          selectedGenre: 'All',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BrowseStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> selectGenre(String genre) async {
    if (genre == 'All') {
      emit(
        state.copyWith(
          status: BrowseStatus.success,
          movies: state.allMovies,
          selectedGenre: 'All',
          clearError: true,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        status: BrowseStatus.loading,
        selectedGenre: genre,
        clearError: true,
      ),
    );

    try {
      final movies = await api.getMovies(
        genre: genre,
        page: 1,
        limit: 50,
        sortBy: 'rating',
        orderBy: 'desc',
      );

      emit(
        state.copyWith(
          status: BrowseStatus.success,
          movies: movies,
          selectedGenre: genre,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BrowseStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }
}