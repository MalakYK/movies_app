import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../movies/data/movie_api_service.dart';
import '../../../movies/presentation/widgets/movie_card.dart';
import '../cubit/browse_cubit.dart';

class BrowseTab extends StatefulWidget {
  const BrowseTab({super.key});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  late final BrowseCubit _browseCubit;

  @override
  void initState() {
    super.initState();

    _browseCubit = BrowseCubit(
      MovieApiService(),
    )..loadBrowse();
  }

  @override
  void dispose() {
    _browseCubit.close();
    super.dispose();
  }

  int _crossAxisCount(double width) {
    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _browseCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth >= 700 ? 28 : 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<BrowseCubit, BrowseState>(
                      buildWhen: (previous, current) =>
                      previous.genres != current.genres ||
                          previous.selectedGenre != current.selectedGenre,
                      builder: (context, state) {
                        final genres = [
                          'All',
                          ...state.genres,
                        ];

                        return SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: genres.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(width: 7),
                            itemBuilder: (context, index) {
                              final genre = genres[index];
                              final selected =
                                  state.selectedGenre == genre;

                              return ChoiceChip(
                                label: Text(genre),
                                selected: selected,
                                onSelected: (_) {
                                  context
                                      .read<BrowseCubit>()
                                      .selectGenre(genre);
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
                                  color: selected
                                      ? Colors.black
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: BlocBuilder<BrowseCubit, BrowseState>(
                        builder: (context, state) {
                          if (state.status == BrowseStatus.loading &&
                              state.movies.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }

                          if (state.status == BrowseStatus.failure &&
                              state.movies.isEmpty) {
                            return _ErrorView(
                              message: 'Unable to load movies',
                              onRetry: () {
                                context
                                    .read<BrowseCubit>()
                                    .loadBrowse();
                              },
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

                          final crossAxisCount =
                          _crossAxisCount(constraints.maxWidth);

                          return GridView.builder(
                            padding: const EdgeInsets.only(bottom: 12),
                            itemCount: state.movies.length,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: .66,
                            ),
                            itemBuilder: (context, index) {
                              final movie = state.movies[index];

                              return BlocBuilder<
                                  FavoritesCubit, FavoritesState>(
                                builder: (context, favState) {
                                  return MovieCard(
                                    movie: movie,
                                    isFavorite: favState.movies.any(
                                          (m) => m.id == movie.id,
                                    ),
                                    onFavorite: () {
                                      context
                                          .read<FavoritesCubit>()
                                          .toggle(movie);
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white54,
            size: 55,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}