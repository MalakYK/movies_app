import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../movies/data/models/movie_model.dart';
import '../../data/favorites_repository.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repository;
  StreamSubscription<List<MovieModel>>? _subscription;

  FavoritesCubit(this.repository) : super(const FavoritesState.initial()) {
    listenToFavorites();
  }

  void listenToFavorites() {
    emit(const FavoritesState.loading());
    _subscription?.cancel();
    try {
      _subscription = repository.watchFavorites().listen(
            (movies) {
          emit(FavoritesState.loaded(movies));
        },
        onError: (error) {
          emit(FavoritesState.failure(error.toString()));
        },
      );
    } catch (e) {
      emit(FavoritesState.failure(e.toString()));
    }
  }

  Future<void> toggle(MovieModel movie) async {
    final isFav = state.movies.any((m) => m.id == movie.id);

    try {
      if (isFav) {
        await repository.remove(movie.id);
      } else {
        await repository.add(movie);
      }
    } catch (e) {
      listenToFavorites();
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}