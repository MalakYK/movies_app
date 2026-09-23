part of 'history_cubit.dart';

enum HistoryStatus {
  initial,
  loading,
  loaded,
  failure,
}

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<MovieModel> movies;
  final String? message;

  const HistoryState._({
    required this.status,
    this.movies = const [],
    this.message,
  });

  const HistoryState.initial()
      : this._(
    status: HistoryStatus.initial,
  );

  const HistoryState.loading()
      : this._(
    status: HistoryStatus.loading,
  );

  const HistoryState.loaded(
      List<MovieModel> movies,
      ) : this._(
    status: HistoryStatus.loaded,
    movies: movies,
  );

  const HistoryState.failure(
      String message,
      ) : this._(
    status: HistoryStatus.failure,
    message: message,
  );

  @override
  List<Object?> get props => [
    status,
    movies,
    message,
  ];
}