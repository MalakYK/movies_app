import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../history/presentation/cubit/history_cubit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../movies/data/models/movie_model.dart';
import '../../../movies/data/movie_api_service.dart';
import '../../../movies/presentation/widgets/movie_card.dart';
import '../cubit/movie_details_cubit.dart';
import '../cubit/movie_details_state.dart';

class MovieDetailsScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailsScreen({
    super.key,
    required this.movieId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MovieDetailsCubit(
        api: MovieApiService(),
      )..loadMovieDetails(movieId),
      child: _MovieDetailsView(movieId: movieId),
    );
  }
}

class _MovieDetailsView extends StatelessWidget {
  final int movieId;

  const _MovieDetailsView({required this.movieId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<MovieDetailsCubit, MovieDetailsState>(
        listenWhen: (previous, current) =>
        previous.status != current.status &&
            current.status == MovieDetailsStatus.success &&
            current.movie != null,
        listener: (context, state) {
          final movie = state.movie;
          if (movie != null) {
            context.read<HistoryCubit>().addToHistory(movie);
          }
        },
        child: BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
          builder: (context, state) {
            if (state.status == MovieDetailsStatus.loading ||
                state.status == MovieDetailsStatus.initial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.status == MovieDetailsStatus.failure ||
                state.movie == null) {
              return _ErrorView(
                onRetry: () =>
                    context.read<MovieDetailsCubit>().retry(movieId),
              );
            }

            return _DetailsContent(
              movie: state.movie!,
              suggestions: state.suggestions,
            );
          },
        ),
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  final MovieModel movie;
  final List<MovieModel> suggestions;

  const _DetailsContent({
    required this.movie,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTabletOrDesktop = screenWidth > 600;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MoviePosterWithHeader(movie: movie),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MovieTitle(movie: movie),
                    const SizedBox(height: 4),
                    _MovieYear(movie: movie),
                    const SizedBox(height: 16),
                    _WatchButton(movie: movie),
                    const SizedBox(height: 14),
                    _MovieStats(movie: movie),
                    const SizedBox(height: 24),
                    if (movie.screenshots.isNotEmpty) ...[
                      const _SectionHeader(title: 'Screen Shots'),
                      const SizedBox(height: 12),
                      _Screenshots(screenshots: movie.screenshots),
                      const SizedBox(height: 24),
                    ],
                    if (suggestions.isNotEmpty) ...[
                      const _SectionHeader(title: 'Similar'),
                      const SizedBox(height: 12),
                      _SuggestionsGrid(
                        movies: suggestions,
                        isTablet: isTabletOrDesktop,
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (movie.summary != null && movie.summary!.isNotEmpty) ...[
                      const _SectionHeader(title: 'Summary'),
                      const SizedBox(height: 12),
                      _Description(movie: movie),
                      const SizedBox(height: 24),
                    ],
                    if (movie.cast != null && movie.cast!.isNotEmpty) ...[
                      const _SectionHeader(title: 'Cast'),
                      const SizedBox(height: 12),
                      _CastList(
                        cast: movie.cast!,
                        isTablet: isTabletOrDesktop,
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (movie.genres.isNotEmpty) ...[
                      const _SectionHeader(title: 'Genres'),
                      const SizedBox(height: 12),
                      _Genres(movie: movie),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _MoviePosterWithHeader extends StatelessWidget {
  final MovieModel movie;

  const _MoviePosterWithHeader({required this.movie});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = (screenHeight * 0.55).clamp(380.0, 600.0);

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: movie.largeCoverImage ?? movie.mediumCoverImage ?? '',
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.fieldBackground,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.fieldBackground,
                child: const Icon(
                  Icons.movie,
                  color: Colors.white38,
                  size: 70,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/images/screen.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    AppColors.background.withOpacity(0.8),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.35, 0.85, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, state) {
                    final isFavorite = state.movies.any((m) => m.id == movie.id);
                    return IconButton(
                      onPressed: () =>
                          context.read<FavoritesCubit>().toggle(movie),
                      icon: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: isFavorite ? AppColors.primary : Colors.white,
                        size: 32,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Center(
            child: SvgPicture.asset(
              'assets/icons/play.svg',
              width: 80,
              height: 80,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieTitle extends StatelessWidget {
  final MovieModel movie;

  const _MovieTitle({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        movie.titleLong?.trim().isNotEmpty == true
            ? movie.titleLong!
            : movie.title,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MovieYear extends StatelessWidget {
  final MovieModel movie;

  const _MovieYear({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        movie.year ?? '-',
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _WatchButton extends StatelessWidget {
  final MovieModel movie;

  const _WatchButton({required this.movie});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE82626),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Watch',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _MovieStats extends StatelessWidget {
  final MovieModel movie;

  const _MovieStats({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            svgPath: 'assets/icons/heart.svg',
            value: movie.likeCount.toString(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatItem(
            svgPath: 'assets/icons/time.svg',
            value: movie.runtime ?? 'N/A',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatItem(
            svgPath: 'assets/icons/star.svg',
            value: movie.rating.toStringAsFixed(1),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String svgPath;
  final String value;

  const _StatItem({
    required this.svgPath,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svgPath,
            width: 22,
            height: 22,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Screenshots extends StatelessWidget {
  final List<String> screenshots;

  const _Screenshots({required this.screenshots});

  @override
  Widget build(BuildContext context) {
    final uniqueScreenshots = screenshots.toSet().toList();

    return Column(
      children: uniqueScreenshots.map((url) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.fieldBackground,
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.fieldBackground,
                  child: const Icon(Icons.broken_image, color: Colors.white38),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SuggestionsGrid extends StatelessWidget {
  final List<MovieModel> movies;
  final bool isTablet;

  const _SuggestionsGrid({
    required this.movies,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: movies.length > 4 ? 4 : movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            final isFavorite = state.movies.any((m) => m.id == movie.id);
            return MovieCard(
              movie: movie,
              isFavorite: isFavorite,
              onFavorite: () => context.read<FavoritesCubit>().toggle(movie),
              onTap: () {
                Navigator.pushReplacementNamed(
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
  }
}

class _Description extends StatelessWidget {
  final MovieModel movie;

  const _Description({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Text(
      movie.summary ?? '',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
    );
  }
}

class _CastList extends StatelessWidget {
  final List<CastModel> cast;
  final bool isTablet;

  const _CastList({
    required this.cast,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (isTablet) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 8,
        ),
        itemCount: cast.length,
        itemBuilder: (context, index) => _CastCard(actor: cast[index]),
      );
    }

    return Column(
      children: cast.map((actor) => _CastCard(actor: actor)).toList(),
    );
  }
}

class _CastCard extends StatelessWidget {
  final CastModel actor;

  const _CastCard({required this.actor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: actor.urlSmallImage ?? '',
              width: 55,
              height: 65,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 55,
                height: 65,
                color: Colors.grey[800],
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Name: ${actor.name ?? 'N/A'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Character: ${actor.characterName ?? 'N/A'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Genres extends StatelessWidget {
  final MovieModel movie;

  const _Genres({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: movie.genres.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            genre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white54, size: 55),
          const SizedBox(height: 16),
          const Text('Unable to load movie details.',
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
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