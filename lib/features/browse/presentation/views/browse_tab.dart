import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../movies/data/models/movie_model.dart';
import '../../../movies/presentation/cubit/movies_cubit.dart';
import '../../../movies/presentation/widgets/movie_card.dart';

class BrowseTab extends StatefulWidget {
  const BrowseTab({super.key});

  static const genres = [
    'Action',
    'Adventure',
    'Animation',
    'Biography',
    'Comedy',
    'Crime',
    'Drama',
    'Horror',
    'Romance',
    'Sci-Fi',
    'Thriller',
  ];

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: BrowseTab.genres.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 7);
                  },
                  itemBuilder: (context, index) {
                    final genre = BrowseTab.genres[index];

                    return BlocBuilder<MoviesCubit, MoviesState>(
                      builder: (context, state) {
                        final selected = state.selectedGenre == genre;

                        return ChoiceChip(
                          label: Text(genre),
                          selected: selected,
                          onSelected: (_) {
                            context.read<MoviesCubit>().byGenre(genre);
                          },
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.background,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(
                            color: AppColors.primary,
                          ),
                          labelStyle: TextStyle(
                            color: selected ? Colors.black : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: BlocBuilder<MoviesCubit, MoviesState>(
                  builder: (context, state) {
                    if (state.status == MoviesStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state.movies.isEmpty) {
                      return const Center(
                        child: Text(
                          'No movies found',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      itemCount: state.movies.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: .66,
                      ),
                      itemBuilder: (context, index) {
                        final movie = state.movies[index];

                        return BlocBuilder<FavoritesCubit, FavoritesState>(
                          builder: (context, favState) {
                            return MovieCard(
                              movie: movie,
                              isFavorite: favState.movies.any(
                                    (m) => m is MovieModel && m.id == movie.id,
                              ),
                              onFavorite: () {
                                context.read<FavoritesCubit>().toggle(movie);
                              },
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.movieDetails,
                                  arguments: movie.id,
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}