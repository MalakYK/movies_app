import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  StreamSubscription<User?>? _subscription;

  AuthCubit(this.repository) : super(const AuthState.initial());

  void checkAuthStatus() {
    _subscription?.cancel();
    _subscription = repository.authStateChanges.listen((user) {
      emit(
        user == null
            ? const AuthState.unauthenticated()
            : AuthState.authenticated(user),
      );
    });
  }

  Future<void> login(String email, String password) async {
    emit(const AuthState.loading());
    try {
      final result = await repository.login(email, password);
      final user = result.user;
      if (user == null) {
        emit(const AuthState.failure('Login failed. Please try again.'));
        return;
      }
      emit(AuthState.authenticated(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthState.failure(_mapError(e)));
    } catch (_) {
      emit(const AuthState.failure('Something went wrong. Please try again.'));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    emit(const AuthState.loading());
    try {
      final result = await repository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      final user = result.user;
      if (user == null) {
        emit(const AuthState.failure('Registration failed. Please try again.'));
        return;
      }
      emit(AuthState.authenticated(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthState.failure(_mapError(e)));
    } catch (_) {
      emit(const AuthState.failure('Something went wrong. Please try again.'));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(const AuthState.loading());
    try {
      await repository.resetPassword(email);
      emit(const AuthState.actionSuccess('Password reset email sent.'));
    } on FirebaseAuthException catch (e) {
      emit(AuthState.failure(_mapError(e)));
    } catch (_) {
      emit(const AuthState.failure('Something went wrong. Please try again.'));
    }
  }

  Future<void> logout() async {
    try {
      await repository.logout();
      emit(const AuthState.unauthenticated());
    } catch (_) {
      emit(const AuthState.failure('Unable to log out. Please try again.'));
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String avatar,
  }) async {
    emit(const AuthState.loading());
    try {
      await repository.updateProfile(
        name: name,
        phone: phone,
        avatar: avatar,
      );
      final user = repository.currentUser;
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(const AuthState.failure('User session expired.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthState.failure(_mapError(e)));
    } catch (_) {
      emit(const AuthState.failure('Unable to update profile.'));
    }
  }

  Future<void> deleteAccount() async {
    emit(const AuthState.loading());
    try {
      await repository.deleteAccount();
      emit(const AuthState.unauthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthState.failure(_mapError(e)));
    } catch (_) {
      emit(const AuthState.failure('Unable to delete account.'));
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try later.';
      case 'requires-recent-login':
        return 'Please log in again before deleting your account.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
