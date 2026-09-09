import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../movies/data/models/movie_model.dart';
import '../../../movies/data/movie_api_service.dart';
import '../../../movies/presentation/widgets/movie_card.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final MovieApiService _api = MovieApiService();
  late Future<MovieModel> _movieFuture;
  late Future<List<MovieModel>> _suggestionsFuture;

  @override
  void initState() {
    super.initState();
    _movieFuture = _api.getMovieDetails(widget.movieId);
    _suggestionsFuture = _api.getSuggestions(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Movie Details'),
      ),
      body: FutureBuilder<MovieModel>(
        future: _movieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Unable to load movie details.',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _movieFuture = _api.getMovieDetails(widget.movieId);
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final movie = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl:
                    movie.largeCoverImage ?? movie.mediumCoverImage ?? '',
                    width: double.infinity,
                    height: 430,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      height: 430,
                      color: AppColors.fieldBackground,
                      child: const Icon(
                        Icons.movie,
                        color: Colors.white38,
                        size: 70,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, state) {
                        final favorite =
                        state.movies.any((m) => m.id == movie.id);
                        return IconButton(
                          onPressed: () => context
                              .read<FavoritesCubit>()
                              .toggle(movie),
                          icon: Icon(
                            favorite
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      movie.rating.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (movie.year != null) ...[
                      const SizedBox(width: 15),
                      Text(
                        movie.year!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                    if (movie.runtime != null && movie.runtime != '0') ...[
                      const SizedBox(width: 15),
                      Text(
                        '${movie.runtime} min',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: movie.genres
                      .map(
                        (genre) => Chip(
                      label: Text(genre),
                      backgroundColor: AppColors.fieldBackground,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  )
                      .toList(),
                ),
                const SizedBox(height: 14),
                Text(
                  movie.summary?.trim().isNotEmpty == true
                      ? movie.summary!
                      : 'No description available.',
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'You May Also Like',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<MovieModel>>(
                  future: _suggestionsFuture,
                  builder: (context, suggestionSnapshot) {
                    if (suggestionSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SizedBox(
                        height: 190,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    final suggestions = suggestionSnapshot.data ?? [];
                    if (suggestions.isEmpty) {
                      return const Text(
                        'No suggestions available.',
                        style: TextStyle(color: Colors.white54),
                      );
                    }

                    return SizedBox(
                      height: 190,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: suggestions.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 10),
                        itemBuilder: (_, index) {
                          final suggestion = suggestions[index];
                          return MovieCard(
                            movie: suggestion,
                            isFavorite: context
                                .watch<FavoritesCubit>()
                                .state
                                .movies
                                .any((m) => m.id == suggestion.id),
                            onFavorite: () => context
                                .read<FavoritesCubit>()
                                .toggle(suggestion),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.movieDetails,
                              arguments: suggestion.id,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
