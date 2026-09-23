import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../history/presentation/cubit/history_cubit.dart';
import '../../../movies/presentation/widgets/movie_card.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with SingleTickerProviderStateMixin {
  String _name = 'Malak Yasser';
  String _avatar = 'assets/images/Component_8.png';
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
      }
    });

    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    _name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : 'Malak Yasser';

    try {
      final doc = await _getUserDocument(user.uid);
      final data = doc.data();
      if (data != null) {
        final name = data['name']?.toString().trim();
        final avatar = data['avatar']?.toString();
        if (name != null && name.isNotEmpty) _name = name;
        if (avatar != null && avatar.isNotEmpty) _avatar = avatar;
      }
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserDocument(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  int _crossAxisCount(double width) {
    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
                (_) => false,
          );
        } else if (state.status == AuthStatus.failure && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
              constraints.maxWidth >= 700 ? 28.0 : 16.0;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  0,
                ),
                child: _loading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
                    : Column(
                  children: [
                    _buildProfileHeader(constraints.maxWidth),
                    const SizedBox(height: 20),
                    _buildButtons(),
                    const SizedBox(height: 16),
                    _buildTabs(),
                    const SizedBox(height: 4),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildWatchListSection(constraints.maxWidth),
                          _buildHistorySection(constraints.maxWidth),
                        ],
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

  Widget _buildProfileHeader(double width) {
    final isWide = width >= 700;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, AppRoutes.updateProfile);
                _loadProfile();
              },
              child: CircleAvatar(
                radius: isWide ? 48 : 40,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage(_avatar),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: isWide ? 150 : 100,
              child: Text(
                _name,
                textAlign: TextAlign.center,
                maxLines: 2,
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
        const SizedBox(width: 20),
        Expanded(
          child: BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, favoriteState) {
              return BlocBuilder<HistoryCubit, HistoryState>(
                builder: (context, historyState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(
                        favoriteState.movies.length.toString(),
                        'Wish List',
                      ),
                      _buildStatColumn(
                        historyState.movies.length.toString(),
                        'History',
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.updateProfile);
              _loadProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => context.read<AuthCubit>().logout(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          child: const Row(
            children: [
              Text(
                'Exit',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(width: 6),
              Icon(Icons.logout, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final currentIndex = _tabController.index;

    return TabBar(
      controller: _tabController,
      indicatorColor: AppColors.primary,
      indicatorWeight: 3,
      dividerColor: Colors.transparent,
      labelColor: AppColors.primary,
      unselectedLabelColor: Colors.white,
      tabs: [
        Tab(
          icon: SvgPicture.asset(
            'assets/icons/watch_list.svg',
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(
              currentIndex == 0 ? AppColors.primary : Colors.white,
              BlendMode.srcIn,
            ),
          ),
          text: 'Watch List',
        ),
        Tab(
          icon: SvgPicture.asset(
            'assets/icons/history.svg',
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(
              currentIndex == 1 ? AppColors.primary : Colors.white,
              BlendMode.srcIn,
            ),
          ),
          text: 'History',
        ),
      ],
    );
  }

  Widget _buildWatchListSection(double width) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        if (state.status == FavoritesStatus.loading && state.movies.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state.movies.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          itemCount: state.movies.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _crossAxisCount(width),
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
            childAspectRatio: .66,
          ),
          itemBuilder: (_, index) {
            final movie = state.movies[index];

            return MovieCard(
              movie: movie,
              isFavorite: true,
              onFavorite: () => context.read<FavoritesCubit>().toggle(movie),
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
  }

  Widget _buildHistorySection(double width) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        if (state.status == HistoryStatus.loading && state.movies.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state.status == HistoryStatus.failure) {
          return const Center(
            child: Text(
              'Unable to load history',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        if (state.movies.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          itemCount: state.movies.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _crossAxisCount(width),
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
            childAspectRatio: .66,
          ),
          itemBuilder: (_, index) {
            final movie = state.movies[index];

            return BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favoriteState) {
                final isFavorite =
                favoriteState.movies.any((m) => m.id == movie.id);

                return MovieCard(
                  movie: movie,
                  isFavorite: isFavorite,
                  onFavorite: () => context.read<FavoritesCubit>().toggle(movie),
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
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Image.asset(
        'assets/images/Empty.png',
        width: 140,
        height: 140,
        fit: BoxFit.contain,
      ),
    );
  }
}