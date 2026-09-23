import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../movies/data/models/movie_model.dart';
import '../../data/history_repository.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository repository;

  StreamSubscription<List<MovieModel>>? _subscription;

  HistoryCubit(this.repository) : super(const HistoryState.initial()) {
    listenToHistory();
  }

  void listenToHistory() {
    emit(const HistoryState.loading());

    _subscription?.cancel();

    try {
      _subscription = repository.watchHistory().listen(
            (movies) {
          emit(HistoryState.loaded(movies));
        },
        onError: (error) {
          emit(HistoryState.failure(error.toString()));
        },
      );
    } catch (e) {
      emit(HistoryState.failure(e.toString()));
    }
  }

  Future<void> addToHistory(MovieModel movie) async {
    try {
      await repository.addToHistory(movie);
    } catch (e) {
      emit(HistoryState.failure(e.toString()));
    }
  }

  Future<void> remove(int movieId) async {
    try {
      await repository.remove(movieId);
    } catch (e) {
      emit(HistoryState.failure(e.toString()));
    }
  }

  Future<void> clear() async {
    try {
      await repository.clear();
    } catch (e) {
      emit(HistoryState.failure(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}