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

  String? get userName {
    final metadata = user?.userMetadata;
    final name = metadata?['full_name'] as String? ?? metadata?['name'] as String? ?? metadata?['displayName'] as String?;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    final email = user?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return null;
  }

  String? get userPhone {
    final phone = user?.phone ?? user?.userMetadata?['phone'] as String? ?? user?.userMetadata?['phoneNumber'] as String?;
    if (phone != null && phone.trim().isNotEmpty) return phone.trim();
    return null;
  }

  String? get displayName {
    return userName ?? 'User';
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
