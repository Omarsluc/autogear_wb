import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/networking/supabase.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel() {
    _user = _serviceOrNull?.currentUser;
    _subscription = _serviceOrNull?.authStateChanges.listen((event) {
      _user = event.session?.user;
      _errorMessage = null;
      notifyListeners();
    });
  }

  StreamSubscription<AuthState>? _subscription;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSupabaseReady => SupabaseService.isInitialized;

  SupabaseService? get _serviceOrNull =>
      SupabaseService.isInitialized ? SupabaseService.instance : null;

  SupabaseService get _service => SupabaseService.instance;

  String? get displayName {
    final metadata = _user?.userMetadata;
    final name = metadata?['full_name'] as String?;
    if (name != null && name.isNotEmpty) return name;
    return _user?.email;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    return _runAuth(() => _service.signIn(email: email, password: password));
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    return _runAuth(
      () => _service.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      ),
    );
  }

  Future<void> signOut() async {
    if (!isSupabaseReady) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _service.signOut();
      _errorMessage = null;
    } on SupabaseServiceException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _runAuth(Future<User> Function() action) async {
    if (!isSupabaseReady) {
      _errorMessage = 'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final signedInUser = await action();
      _user = signedInUser;
      return true;
    } on SupabaseServiceException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
