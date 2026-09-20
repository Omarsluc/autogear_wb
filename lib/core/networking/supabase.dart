import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order_record.dart';
import '../models/part_record.dart';
import '../models/profile.dart';

/// Supabase project credentials.
///
/// Pass at build/run time:
/// `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
abstract final class SupabaseConfig {
  static const supaUrl = "https://vrwgtpbeejpnnaoflrfy.supabase.co";
  static const supaAnon = "sb_publishable_BEeJ9Ig5CURIz2Nmk489Lw_zcDL9jj1";
  static const url = String.fromEnvironment('SUPABASE_URL', defaultValue: supaUrl);
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: supaAnon);

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

abstract final class SupabaseTables {
  static const profiles = 'profiles';
  // static const brands = 'brands';
  static const parts = 'parts';
  static const partCompatibility = 'part_compatibility';
  static const orders = 'orders';
  static const orderItems = 'order_items';
}

class SupabaseServiceException implements Exception {
  SupabaseServiceException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'SupabaseServiceException: $message${cause != null ? ' ($cause)' : ''}';
}

/// Filters for catalog part queries.
class PartQueryFilters {
  const PartQueryFilters({
    this.brandId,
    this.brandName,
    this.model,
    this.year,
    this.partType,
    this.searchQuery,
    this.limit = 50,
    this.offset = 0,
  });

  final int? brandId;
  final String? brandName;
  final String? model;
  final int? year;
  final String? partType;
  final String? searchQuery;
  final int limit;
  final int offset;
}

/// Payload for creating a new order with line items.
class CreateOrderRequest {
  const CreateOrderRequest({
    required this.items,
    this.status = 'pending',
    this.whatsappMessage,
  });

  final List<CreateOrderItemRequest> items;
  final String status;
  final String? whatsappMessage;

  double get totalPrice =>
      items.fold(0, (sum, item) => sum + item.unitPrice * item.quantity);
}

class CreateOrderItemRequest {
  const CreateOrderItemRequest({
    required this.partId,
    required this.quantity,
    required this.unitPrice,
  });

  final int partId;
  final int quantity;
  final double unitPrice;
}

/// Central Supabase client wrapper for auth, catalog, and orders.
class SupabaseService {
  SupabaseService._();

  static SupabaseService? _instance;

  static SupabaseService get instance {
    final service = _instance;
    if (service == null) {
      throw SupabaseServiceException(
        'SupabaseService not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return service;
  }

  static bool get isInitialized => _instance != null;

  /// Initializes the Supabase SDK and service singleton.
  static Future<void> initialize({
    String? url,
    String? anonKey,
  }) async {
    final resolvedUrl = url ?? SupabaseConfig.url;
    final resolvedAnonKey = anonKey ?? SupabaseConfig.anonKey;

    if (resolvedUrl.isEmpty || resolvedAnonKey.isEmpty) {
      throw SupabaseServiceException(
        'Missing Supabase credentials. Provide url/anonKey or use '
        'SUPABASE_URL and SUPABASE_ANON_KEY dart-defines.',
      );
    }

    await Supabase.initialize(
      url: resolvedUrl,
      publishableKey: resolvedAnonKey,
    );

    _instance = SupabaseService._();
  }

  SupabaseClient get client => Supabase.instance.client;
  GoTrueClient get auth => client.auth;

  User? get currentUser => auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  String? get currentUserId => currentUser?.id;

  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  static String _cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'\s+|-'), '');
  }

  static String _phoneToEmail(String phone) {
    final clean = _cleanPhone(phone);
    return '$clean@phone.autogear.com';
  }

  Future<User> signUp({
    required String phone,
    required String password,
    String? fullName,
  }) async {
    final clean = _cleanPhone(phone);
    final syntheticEmail = _phoneToEmail(clean);

    try {
      final response = await auth.signUp(
        email: syntheticEmail,
        password: password,
        data: {
          'phone': clean,
          if (fullName != null) 'full_name': fullName,
        },
      );

      final user = response.user;
      if (user == null) {
        throw SupabaseServiceException('Sign up failed: no user returned.');
      }

      // Try updating/upserting profile details.
      try {
        await upsertProfile(
          Profile(
            id: user.id,
            fullName: fullName,
            phone: clean,
          ),
        );
      } catch (_) {
        // Profile creation handled by DB trigger or RLS policy.
      }

      return user;
    } on AuthException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<User> signIn({
    required String phone,
    required String password,
  }) async {
    final clean = _cleanPhone(phone);
    final syntheticEmail = _phoneToEmail(clean);

    try {
      final response = await auth.signInWithPassword(
        email: syntheticEmail,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw SupabaseServiceException('Sign in failed: no user returned.');
      }

      return user;
    } on AuthException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } on AuthException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Profiles
  // ---------------------------------------------------------------------------

  Future<Profile?> getProfile([String? userId]) async {
    final id = userId ?? currentUserId;
    if (id == null) return null;

    try {
      final data = await client
          .from(SupabaseTables.profiles)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;
      return Profile.fromJson(data);
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<Profile> upsertProfile(Profile profile) async {
    try {
      final data = await client
          .from(SupabaseTables.profiles)
          .upsert(profile.toJson())
          .select()
          .single();

      return Profile.fromJson(data);
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Brands
  // ---------------------------------------------------------------------------

  // Future<List<Brand>> fetchBrands() async {
  //   try {
  //     final data = await client
  //         .from(SupabaseTables.brands)
  //         .select()
  //         .order('name');
  //
  //     return (data as List)
  //         .cast<Map<String, dynamic>>()
  //         .map(Brand.fromJson)
  //         .toList();
  //   } on PostgrestException catch (e) {
  //     throw SupabaseServiceException(e.message, cause: e);
  //   }
  // }

  // ---------------------------------------------------------------------------

  // Future<Brand?> fetchBrandByName(String name) async {
  //   try {
  //     final data = await client
  //         .from(SupabaseTables.brands)
  //         .select()
  //         .ilike('name', name)
  //         .maybeSingle();
  //
  //     if (data == null) return null;
  //     return Brand.fromJson(data);
  //   } on PostgrestException catch (e) {
  //     throw SupabaseServiceException(e.message, cause: e);
  //   }
  // }
  // ---------------------------------------------------------------------------
  // Parts Catalog Queries & RPCs (Table: parts)
  // ---------------------------------------------------------------------------

  Future<List<String>> fetchMakes() async {
    try {
      final response = await client.rpc('get_makes');
      if (response is List && response.isNotEmpty) {
        return response
            .map((row) => (row as Map<String, dynamic>)['make'] as String?)
            .whereType<String>()
            .toList();
      }
    } catch (_) {}

    try {
      final List<dynamic> data = await client.from(SupabaseTables.parts).select('make');
      return data
          .map((row) => (row as Map<String, dynamic>)['make'] as String?)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<List<String>> fetchModels({String? make}) async {
    try {
      final response = await client.rpc('get_models', params: {
        if (make != null && make.isNotEmpty) 'p_make': make,
      });
      if (response is List && response.isNotEmpty) {
        return response
            .map((row) => (row as Map<String, dynamic>)['model'] as String?)
            .whereType<String>()
            .toList();
      }
    } catch (_) {}

    try {
      var query = client.from(SupabaseTables.parts).select('model');
      if (make != null && make.isNotEmpty) {
        query = query.eq('make', make);
      }
      final List<dynamic> data = await query;
      return data
          .map((row) => (row as Map<String, dynamic>)['model'] as String?)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<List<int>> fetchYears({String? make, String? model}) async {
    try {
      final response = await client.rpc('get_years', params: {
        if (make != null && make.isNotEmpty) 'p_make': make,
        if (model != null && model.isNotEmpty) 'p_model': model,
      });
      if (response is List && response.isNotEmpty) {
        return response
            .map((row) => (row as Map<String, dynamic>)['year'] as int?)
            .whereType<int>()
            .toList();
      }
    } catch (_) {}

    try {
      var query = client.from(SupabaseTables.parts).select('year');
      if (make != null && make.isNotEmpty) query = query.eq('make', make);
      if (model != null && model.isNotEmpty) query = query.eq('model', model);
      final List<dynamic> data = await query;
      final yearSet = <int>{};
      for (final row in data) {
        final yVal = (row as Map<String, dynamic>)['year'];
        if (yVal is List) {
          for (final y in yVal) {
            final parsed = int.tryParse(y.toString());
            if (parsed != null) yearSet.add(parsed);
          }
        } else if (yVal != null) {
          final parsed = int.tryParse(yVal.toString());
          if (parsed != null) yearSet.add(parsed);
        }
      }
      final list = yearSet.toList()..sort((a, b) => b.compareTo(a));
      return list;
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<List<String>> fetchSystems({String? make, String? model, int? year}) async {
    try {
      final response = await client.rpc('get_systems', params: {
        if (make != null && make.isNotEmpty) 'p_make': make,
        if (model != null && model.isNotEmpty) 'p_model': model,
        if (year != null) 'p_year': year,
      });
      if (response is List && response.isNotEmpty) {
        return response
            .map((row) => (row as Map<String, dynamic>)['system'] as String?)
            .whereType<String>()
            .toList();
      }
    } catch (_) {}

    try {
      var query = client.from(SupabaseTables.parts).select('system');
      if (make != null && make.isNotEmpty) query = query.eq('make', make);
      if (model != null && model.isNotEmpty) query = query.eq('model', model);
      if (year != null) query = query.contains('year', [year]);
      final List<dynamic> data = await query;
      return data
          .map((row) => (row as Map<String, dynamic>)['system'] as String?)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<List<String>> fetchPartNames({
    String? make,
    String? model,
    int? year,
    String? system,
  }) async {
    try {
      final response = await client.rpc('get_part_names', params: {
        if (make != null && make.isNotEmpty) 'p_make': make,
        if (model != null && model.isNotEmpty) 'p_model': model,
        if (year != null) 'p_year': year,
        if (system != null && system.isNotEmpty) 'p_system': system,
      });
      if (response is List && response.isNotEmpty) {
        return response
            .map((row) {
              if (row is Map<String, dynamic>) {
                return (row['item_type'] ?? row['part_name']) as String?;
              }
              if (row is String) return row;
              return null;
            })
            .whereType<String>()
            .toList();
      }
    } catch (_) {}

    try {
      var query = client.from(SupabaseTables.parts).select('item_type');
      if (make != null && make.isNotEmpty) query = query.eq('make', make);
      if (model != null && model.isNotEmpty) query = query.eq('model', model);
      if (year != null) query = query.contains('year', [year]);
      if (system != null && system.isNotEmpty) query = query.eq('system', system);
      final List<dynamic> data = await query;
      return data
          .map((row) {
            final m = row as Map<String, dynamic>;
            return m['item_type'] as String?;
          })
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<List<PartRecord>> searchParts({
    String? make,
    String? model,
    int? year,
    String? system,
    String? partName,
    String? searchQuery,
  }) async {
    // 1. Try RPC search_parts
    try {
      final response = await client.rpc('search_parts', params: {
        if (make != null && make.isNotEmpty) 'p_make': make,
        if (model != null && model.isNotEmpty) 'p_model': model,
        if (year != null) 'p_year': year,
        if (system != null && system.isNotEmpty) 'p_system': system,
        if (partName != null && partName.isNotEmpty) 'p_part': partName,
        if (searchQuery != null && searchQuery.trim().isNotEmpty)
          'p_query': searchQuery.trim(),
      });

      if (response is List) {
        return response
            .cast<Map<String, dynamic>>()
            .map(PartRecord.fromJson)
            .toList();
      }
    } catch (_) {}

    // 2. Direct table fallback on parts table
    try {
      var query = client.from(SupabaseTables.parts).select();

      if (make != null && make.isNotEmpty) {
        query = query.eq('make', make);
      }
      if (model != null && model.isNotEmpty) {
        query = query.eq('model', model);
      }
      if (year != null) {
        query = query.contains('year', [year]);
      }
      if (system != null && system.isNotEmpty) {
        query = query.eq('system', system);
      }
      if (partName != null && partName.isNotEmpty) {
        query = query.eq('item_type', partName);
      }

      final q = searchQuery?.trim();
      if (q != null && q.isNotEmpty) {
        query = query.or(
          'oem.ilike.%$q%,'
          'sn.ilike.%$q%,'
          'item_type.ilike.%$q%,'
          'english_notes.ilike.%$q%,'
          'arabic_notes.ilike.%$q%',
        );
      }

      final List<dynamic> data = await query.order('created_at', ascending: false);
      return data
          .cast<Map<String, dynamic>>()
          .map(PartRecord.fromJson)
          .toList();
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<List<PartRecord>> fetchParts([PartQueryFilters filters = const PartQueryFilters()]) async {
    return searchParts(
      make: filters.brandName,
      model: filters.model,
      year: filters.year,
      system: filters.partType,
      searchQuery: filters.searchQuery,
    );
  }

  Future<PartRecord?> fetchPartById(dynamic partId) async {
    try {
      final data = await client
          .from(SupabaseTables.parts)
          .select()
          .eq('id', partId)
          .maybeSingle();

      if (data == null) return null;
      return PartRecord.fromJson(data);
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<List<PartRecord>> searchPartsByOeNumber(String oeNumber) async {
    return searchParts(searchQuery: oeNumber);
  }

  // ---------------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------------

  Future<OrderRecord> createOrder(CreateOrderRequest request) async {
    final userId = currentUserId;
    if (userId == null) {
      throw SupabaseServiceException('You must be signed in to create an order.');
    }

    if (request.items.isEmpty) {
      throw SupabaseServiceException('Order must contain at least one item.');
    }

    try {
      final orderData = await client
          .from(SupabaseTables.orders)
          .insert({
            'user_id': userId,
            'status': request.status,
            'total_price': request.totalPrice,
            if (request.whatsappMessage != null)
              'whatsapp_message': request.whatsappMessage,
          })
          .select()
          .single();

      final orderId = orderData['id'] as int;

      final itemRows = request.items
          .map(
            (item) => {
              'order_id': orderId,
              ...item.toInsertJson(),
            },
          )
          .toList();

      await client.from(SupabaseTables.orderItems).insert(itemRows);

      final order = await fetchOrderById(orderId);
      if (order == null) {
        throw SupabaseServiceException('Order created but could not be loaded.');
      }

      return order;
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<List<OrderRecord>> fetchUserOrders([String? userId]) async {
    final id = userId ?? currentUserId;
    if (id == null) {
      throw SupabaseServiceException('No user id available for order lookup.');
    }

    try {
      final data = await client
          .from(SupabaseTables.orders)
          .select('''
            *,
            order_items (
              *,
              parts ( * )
            )
          ''')
          .eq('user_id', id)
          .order('created_at', ascending: false);

      return (data as List)
          .cast<Map<String, dynamic>>()
          .map(OrderRecord.fromJson)
          .toList();
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<OrderRecord?> fetchOrderById(int orderId) async {
    try {
      final data = await client
          .from(SupabaseTables.orders)
          .select('''
            *,
            order_items (
              *,
              parts ( * )
            )
          ''')
          .eq('id', orderId)
          .maybeSingle();

      if (data == null) return null;
      return OrderRecord.fromJson(data);
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<OrderRecord> updateOrderStatus(int orderId, String status) async {
    try {
      final data = await client
          .from(SupabaseTables.orders)
          .update({'status': status})
          .eq('id', orderId)
          .select('''
            *,
            order_items (
              *,
              parts ( * )
            )
          ''')
          .single();

      return OrderRecord.fromJson(data);
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }
}

extension on CreateOrderItemRequest {
  Map<String, dynamic> toInsertJson() => {
        'part_id': partId,
        'quantity': quantity,
        'unit_price': unitPrice,
      };
}
