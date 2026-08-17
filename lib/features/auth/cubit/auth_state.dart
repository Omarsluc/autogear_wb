import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/networking/supabase.dart';

class AppAuthState {
  const AppAuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final User? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;
  bool get isSupabaseReady => SupabaseService.isInitialized;

  String? get displayName {
    final metadata = user?.userMetadata;
    final name = metadata?['full_name'] as String?;
    if (name != null && name.isNotEmpty) return name;
    return user?.email;
  }

  AppAuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AppAuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
