import 'package:flutter/material.dart';

import '../../features/home/presentation/views/home_screen.dart';
import '../../features/login/presentation/views/login_screen.dart';
import '../../features/movie_details/presentation/views/movie_details_screen.dart';
import '../../features/onboarding/presentation/views/onboarding_screen.dart';
import '../../features/register/presentation/views/register_screen.dart';
import '../../features/reset_password/presentation/views/reset_password_screen.dart';
import '../../features/update_profile/presentation/views/update_profile_screen.dart';
import '../constants/app_colors.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String updateProfile = '/update-profile';
  static const String home = '/home';
  static const String movieDetails = '/movie-details';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      case updateProfile:
        return MaterialPageRoute(builder: (_) => const UpdateProfileScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case movieDetails:
        return MaterialPageRoute(
          builder: (_) => MovieDetailsScreen(movieId: settings.arguments as int),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text('Page not found', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
    }
  }
}
