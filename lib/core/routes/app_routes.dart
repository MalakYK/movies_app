import 'package:flutter/material.dart';

import '../../features/login/presentation/views/login_screen.dart';
import '../../features/register/presentation/views/register_screen.dart';
import '../../features/reset_password/presentation/views/reset_password_screen.dart';
import '../../features/update_profile/presentation/views/update_profile_screen.dart';
import '../../features/onboarding/presentation/views/onboarding_screen.dart';

class AppRoutes {
  static const String splash = '/';

  static const String onboarding = '/onboarding';

  static const String login = '/login';

  static const String register = '/register';

  static const String resetPassword =
      '/reset-password';

  static const String updateProfile =
      '/update-profile';

  static Route<dynamic> onGenerateRoute(
      RouteSettings settings,
      ) {
    switch (settings.name) {
    // =========================
    // Onboarding
    // =========================
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );

    // =========================
    // Login
    // =========================
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

    // =========================
    // Register
    // =========================
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

    // =========================
    // Reset Password
    // =========================
      case resetPassword:
        return MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
        );

    // =========================
    // Update Profile
    // =========================
      case updateProfile:
        return MaterialPageRoute(
          builder: (_) => const UpdateProfileScreen(),
        );

    // =========================
    // Unknown Route
    // =========================
      default:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );
    }
  }
}