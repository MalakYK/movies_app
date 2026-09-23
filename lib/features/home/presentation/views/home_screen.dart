import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../movies/data/movie_api_service.dart';
import '../../../movies/data/models/movie_model.dart';
import '../../../movies/presentation/cubit/movies_cubit.dart';
import '../../../movies/presentation/widgets/movie_card.dart';
import '../../../profile/presentation/views/profile_tab.dart';
import '../../../search/presentation/views/search_tab.dart';
import '../../../browse/presentation/views/browse_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  late final MoviesCubit _moviesCubit;

  @override
  void initState() {
    super.initState();
    _moviesCubit = MoviesCubit(MovieApiService())..loadHome();
  }

  @override
  void dispose() {
    _moviesCubit.close();
    super.dispose();
  }

  Widget _buildNavIcon(String assetName, bool isSelected) {
    const selectedColor = Color(0xFFF6BD00);
    const unselectedColor = Colors.white;

    return SvgPicture.asset(
      'assets/icons/$assetName',
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        isSelected ? selectedColor : unselectedColor,
        BlendMode.srcIn,
      ),
    );
  }

  void _navigateToBrowse() {
    setState(() {
      _index = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _moviesCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _index,
          children: [
            _HomeTab(onSeeMorePressed: _navigateToBrowse),
            const SearchTab(),
            const BrowseTab(),
            const ProfileTab(),
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: const NavigationBarThemeData(
              indicatorColor: Colors.transparent,
            ),
          ),
          child: NavigationBar(
            backgroundColor: AppColors.fieldBackground,
            selectedIndex: _index,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            onDestinationSelected: (index) => setState(() => _index = index),
            destinations: [
              NavigationDestination(
                icon: _buildNavIcon('home.svg', false),
                selectedIcon: _buildNavIcon('home.svg', true),
                label: '',
              ),
              NavigationDestination(
                icon: _buildNavIcon('search.svg', false),
                selectedIcon: _buildNavIcon('search.svg', true),
                label: '',
              ),
              NavigationDestination(
                icon: _buildNavIcon('explore.svg', false),
                selectedIcon: _buildNavIcon('explore.svg', true),
                label: '',
              ),
              NavigationDestination(
                icon: _buildNavIcon('Profiel.svg', false),
                selectedIcon: _buildNavIcon('Profiel.svg', true),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onSeeMorePressed;

  const _HomeTab({required this.onSeeMorePressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<MoviesCubit>().loadHome(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: BlocBuilder<MoviesCubit, MoviesState>(
            builder: (context, state) {
              if (state.status == MoviesStatus.loading && state.movies.isEmpty) {
                return const SizedBox(
                  height: 600,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (state.status == MoviesStatus.failure && state.movies.isEmpty) {
                return SizedBox(
                  height: 600,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white54,
                          size: 50,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Unable to load movies',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => context.read<MoviesCubit>().loadHome(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final movies = state.movies;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/available_now.png',
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text(
                        'Available Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (movies.isNotEmpty) _MoviesCarousel(movies: movies),
                  const SizedBox(height: 5),
                  Center(
                    child: Image.asset(
                      'assets/images/watch_now.png',
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text(
                        'Watch Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionTitle(
                      title: 'Action',
                      onSeeMore: onSeeMorePressed,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length.clamp(0, 10),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, index) {
                        final movie = movies[index];
                        return _FavoriteMovieCard(movie: movie);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MoviesCarousel extends StatefulWidget {
  final List<MovieModel> movies;

  const _MoviesCarousel({required this.movies});

  @override
  State<_MoviesCarousel> createState() => _MoviesCarouselState();
}

class _MoviesCarouselState extends State<_MoviesCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.65,
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMovie = widget.movies[_currentIndex];

    return SizedBox(
      height: 380,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Image.network(
                  currentMovie.largeCoverImage ??
                      currentMovie.mediumCoverImage ??
                      '',
                  key: ValueKey(currentMovie.id),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppColors.background),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            PageView.builder(
              controller: _pageController,
              itemCount: widget.movies.length.clamp(0, 10),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final movie = widget.movies[index];
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = (_pageController.page! - index);
                      value = (1 - (value.abs() * 0.25)).clamp(0.0, 1.0);
                    } else {
                      value = index == _currentIndex ? 1.0 : 0.75;
                    }

                    return Center(
                      child: SizedBox(
                        height: Curves.easeOut.transform(value) * 350,
                        width: 240,
                        child: child,
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.movieDetails,
                      arguments: movie.id,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            movie.largeCoverImage ??
                                movie.mediumCoverImage ??
                                '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: AppColors.fieldBackground),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    movie.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.star,
                                    color: AppColors.primary,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteMovieCard extends StatelessWidget {
  final MovieModel movie;

  const _FavoriteMovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        return MovieCard(
          movie: movie,
          isFavorite: state.movies.any((m) => m.id == movie.id),
          onFavorite: () => context.read<FavoritesCubit>().toggle(movie),
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.movieDetails,
            arguments: movie.id,
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onSeeMore;

  const _SectionTitle({required this.title, required this.onSeeMore});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: onSeeMore,
          child: Row(
            children: const [
              Text(
                'See More',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_forward,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}