import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import 'models/movie_model.dart';

class MovieApiService {
  final Dio _dio;

  MovieApiService([Dio? dio])
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

  Future<List<MovieModel>> getMovies({
    String? genre,
    String? queryTerm,
    int page = 1,
    int limit = 20,
    String sortBy = 'date_added',
    String orderBy = 'desc',
  }) async {
    final response = await _dio.get(
      ApiConstants.listMovies,
      queryParameters: {
        'limit': limit,
        'page': page,
        'sort_by': sortBy,
        'order_by': orderBy,
        if (genre != null && genre.isNotEmpty) 'genre': genre,
        if (queryTerm != null && queryTerm.isNotEmpty) 'query_term': queryTerm,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final movies = (data['data']?['movies'] as List?) ?? const [];
    return movies
        .map((movie) => MovieModel.fromJson(movie as Map<String, dynamic>))
        .toList();
  }

  Future<MovieModel> getMovieDetails(int movieId) async {
    final response = await _dio.get(
      ApiConstants.movieDetails,
      queryParameters: {'movie_id': movieId},
    );
    return MovieModel.fromJson(
      (response.data as Map<String, dynamic>)['data']['movie']
      as Map<String, dynamic>,
    );
  }

  Future<List<MovieModel>> getSuggestions(int movieId) async {
    final response = await _dio.get(
      ApiConstants.movieSuggestions,
      queryParameters: {'movie_id': movieId},
    );
    final movies =
        ((response.data as Map<String, dynamic>)['data']['movies'] as List?) ??
            const [];
    return movies
        .map((movie) => MovieModel.fromJson(movie as Map<String, dynamic>))
        .toList();
  }
}
