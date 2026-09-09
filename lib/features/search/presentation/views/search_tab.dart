import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../movies/presentation/cubit/movies_cubit.dart';
import '../../../movies/presentation/widgets/movie_card.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void search() => context.read<MoviesCubit>().search(controller.text);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              onSubmitted: (_) => search(),
              onChanged: (text) {
                if (text.isEmpty) {
                  setState(() {});
                }
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
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
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (controller.text.trim().isEmpty || state.movies.isEmpty) {
                    return Center(
                      child: Image.asset(
                        'assets/images/Empty.png',
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                    );
                  }

                  return GridView.builder(
                    itemCount: state.movies.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: .66,
                    ),
                    itemBuilder: (_, index) {
                      final movie = state.movies[index];
                      return BlocBuilder<FavoritesCubit, FavoritesState>(
                        builder: (context, favState) => MovieCard(
                          movie: movie,
                          isFavorite: favState.movies.any((m) => m.id == movie.id),
                          onFavorite: () => context.read<FavoritesCubit>().toggle(movie),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.movieDetails,
                            arguments: movie.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}