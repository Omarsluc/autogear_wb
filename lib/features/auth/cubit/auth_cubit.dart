import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/networking/supabase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AppAuthState> {
  AuthCubit()
      : super(
          AppAuthState(
            user: SupabaseService.isInitialized
                ? SupabaseService.instance.currentUser
                : null,
          ),
        ) {
    _subscription = _serviceOrNull?.authStateChanges.listen((event) {
      emit(state.copyWith(user: event.session?.user, clearError: true));
    });
  }

  StreamSubscription<AuthState>? _subscription;

  SupabaseService? get _serviceOrNull =>
      SupabaseService.isInitialized ? SupabaseService.instance : null;

  SupabaseService get _service => SupabaseService.instance;

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<bool> signIn({
    required String phone,
    required String password,
  }) async {
    return _runAuth(() => _service.signIn(phone: phone, password: password));
  }

  Future<bool> signUp({
    required String phone,
    required String password,
    String? fullName,
  }) async {
    return _runAuth(
      () => _service.signUp(
        phone: phone,
        password: password,
        fullName: fullName,
      ),
    );
  }

  Future<void> signOut() async {
    if (!state.isSupabaseReady) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await _service.signOut();
      emit(state.copyWith(isLoading: false, clearUser: true, clearError: true));
    } on SupabaseServiceException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    }
  }

  Future<bool> _runAuth(Future<User> Function() action) async {
    if (!state.isSupabaseReady) {
      emit(
        state.copyWith(
          errorMessage:
              'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.',
        ),
      );
      return false;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final signedInUser = await action();
      emit(state.copyWith(user: signedInUser, isLoading: false, clearError: true));
      return true;
    } on SupabaseServiceException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
      return false;
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
