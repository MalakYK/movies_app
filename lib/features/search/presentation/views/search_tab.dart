import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../movies/data/movie_api_service.dart';
import '../../../movies/presentation/cubit/movies_cubit.dart';
import '../../../movies/presentation/widgets/movie_card.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  late final MoviesCubit _moviesCubit;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _moviesCubit = MoviesCubit(MovieApiService());
  }

  @override
  void dispose() {
    controller.dispose();
    _moviesCubit.close();
    super.dispose();
  }

  void search() {
    _moviesCubit.search(controller.text);
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
      value: _moviesCubit,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                constraints.maxWidth >= 700 ? 28 : 16,
                14,
                constraints.maxWidth >= 700 ? 28 : 16,
                10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    onSubmitted: (_) => search(),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          'assets/icons/search.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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

                        if (state.status == MoviesStatus.failure) {
                          return Center(
                            child: Text(
                              'Unable to search movies',
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          );
                        }

                        if (controller.text.trim().isEmpty ||
                            state.movies.isEmpty) {
                          return Center(
                            child: Image.asset(
                              'assets/images/Empty.png',
                              width: 180,
                              height: 180,
                              fit: BoxFit.contain,
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
                          itemBuilder: (_, index) {
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
    );
  }
}