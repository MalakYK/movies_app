import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../movies/presentation/widgets/movie_card.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with SingleTickerProviderStateMixin {
  String _name = 'Malak Yasser';
  String _avatar = 'assets/images/Component_8.png';
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
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
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null) {
        _name = (data['name'] as String?)?.trim().isNotEmpty == true
            ? (data['name'] as String).trim()
            : _name;
        _avatar = (data['avatar'] as String?) ?? 'assets/images/Component_8.png';
      }
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: _loading
                ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
                : Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              AppRoutes.updateProfile,
                            );
                            _loadProfile();
                          },
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage(_avatar),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 36),
                    // Wish List & History
                    Expanded(
                      child: BlocBuilder<FavoritesCubit, FavoritesState>(
                        builder: (context, state) {
                          final count = state.movies.length;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn('$count', 'Wish List'),
                              _buildStatColumn('0', 'History'),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.updateProfile,
                          );
                          _loadProfile();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF6BD00),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        children: const [
                          Text(
                            'Exit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.logout, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    final currentIndex = _tabController.index;
                    return TabBar(
                      controller: _tabController,
                      indicatorColor: const Color(0xFFF6BD00),
                      indicatorWeight: 3,
                      dividerColor: Colors.transparent,
                      labelColor: const Color(0xFFF6BD00),
                      unselectedLabelColor: Colors.white,
                      tabs: [
                        Tab(
                          icon: SvgPicture.asset(
                            'assets/icons/watch_list.svg',
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              currentIndex == 0
                                  ? const Color(0xFFF6BD00)
                                  : Colors.white,
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
                              currentIndex == 1
                                  ? const Color(0xFFF6BD00)
                                  : Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          text: 'History',
                        ),
                      ],
                    );
                  },
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildWatchListSection(),
                      _buildEmptyState(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildWatchListSection() {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        if (state.status == FavoritesStatus.loading) {
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
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 10,
            childAspectRatio: .66,
          ),
          itemBuilder: (_, index) {
            final movie = state.movies[index];
            return MovieCard(
              movie: movie,
              isFavorite: true,
              onFavorite: () => context.read<FavoritesCubit>().toggle(movie),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.movieDetails,
                arguments: movie.id,
              ),
            );
          },
        );
      },
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