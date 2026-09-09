import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _backPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildFirstPage(),
          _buildSecondPage(),
          _buildThirdPage(),
          _buildFourthPage(),
          _buildFifthPage(),
          _buildSixthPage(),
        ],
      ),
    );
  }

  // =========================================================
  // FIRST PAGE
  // =========================================================
  Widget _buildFirstPage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppAssets.onboardingMovies,
          fit: BoxFit.cover,
        ),
        Image.asset(
          AppAssets.onboardingMoviesOverlay,
          fit: BoxFit.cover,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  AppStrings.firstTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  AppStrings.firstDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      AppStrings.exploreNow,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // SECOND PAGE
  // =========================================================
  Widget _buildSecondPage() {
    return _buildOnboardingLayout(
      bgImage: AppAssets.superheroes,
      overlayImage: AppAssets.superheroesOverlay,
      title: AppStrings.discoverMovies,
      description: AppStrings.discoverMoviesDescription,
      onNext: _nextPage,
    );
  }

  // =========================================================
  // THIRD PAGE
  // =========================================================
  Widget _buildThirdPage() {
    return _buildOnboardingLayout(
      bgImage: AppAssets.godfather1,
      overlayImage: AppAssets.godfather2,
      title: AppStrings.exploreAllGenres,
      description: AppStrings.exploreGenresDescription,
      onNext: _nextPage,
      onBack: _backPage,
    );
  }

  // =========================================================
  // FOURTH PAGE
  // =========================================================
  Widget _buildFourthPage() {
    return _buildOnboardingLayout(
      bgImage: AppAssets.boys1,
      overlayImage: AppAssets.boys2,
      title: AppStrings.createWatchlists,
      description: AppStrings.watchlistsDescription,
      onNext: _nextPage,
      onBack: _backPage,
    );
  }

  // =========================================================
  // FIFTH PAGE
  // =========================================================
  Widget _buildFifthPage() {
    return _buildOnboardingLayout(
      bgImage: AppAssets.superWoman1,
      overlayImage: AppAssets.superWoman2,
      title: AppStrings.rateReviewAndLearn,
      description: AppStrings.rateReviewDescription,
      onNext: _nextPage,
      onBack: _backPage,
    );
  }

  // =========================================================
  // SIXTH PAGE
  // =========================================================
  Widget _buildSixthPage() {
    return _buildOnboardingLayout(
      bgImage: AppAssets.samMendes1,
      overlayImage: AppAssets.samMendes2,
      title: AppStrings.startWatchingNow,
      description: null,
      nextText: AppStrings.finish,
      onNext: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_seen', true);

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
        );
      },
      onBack: _backPage,
    );
  }

  // =========================================================
  // SHARED ONBOARDING LAYOUT
  // =========================================================
  Widget _buildOnboardingLayout({
    required String bgImage,
    required String overlayImage,
    required String title,
    String? description,
    String nextText = AppStrings.next,
    required VoidCallback onNext,
    VoidCallback? onBack,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          bgImage,
          fit: BoxFit.cover,
        ),
        Image.asset(
          overlayImage,
          fit: BoxFit.cover,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              color: Color(0xFF121312),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: const Color(0xFF121312),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      nextText,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (onBack != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: onBack,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        AppStrings.back,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}