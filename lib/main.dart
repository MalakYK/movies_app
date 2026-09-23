import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/favorites/data/favorites_repository.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/history/data/history_repository.dart';
import 'features/history/presentation/cubit/history_cubit.dart';
import 'features/splash/presentation/views/splash_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            AuthRepository(),
          )..checkAuthStatus(),
        ),

        // FavoritesCubit and HistoryCubit already start listening
        // inside their own constructors, so no extra cascade call
        // is needed here.
        BlocProvider<FavoritesCubit>(
          create: (_) => FavoritesCubit(
            FavoritesRepository(),
          ),
        ),

        BlocProvider<HistoryCubit>(
          create: (_) => HistoryCubit(
            HistoryRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}