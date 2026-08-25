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

  Future<User> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      final response = await auth.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null) 'full_name': fullName,
          if (phone != null) 'phone': phone,
        },
      );

      final user = response.user;
      if (user == null) {
        throw SupabaseServiceException('Sign up failed: no user returned.');
      }

      await upsertProfile(
        Profile(
          id: user.id,
          fullName: fullName,
          phone: phone,
        ),
      );

      return user;
    } on AuthException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await auth.signInWithPassword(
        email: email,
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
  // Parts & compatibility
  // ---------------------------------------------------------------------------

  static const _partWithCompatibilitySelect = '''
    *,
    part_compatibility (
      *
    )
  ''';

  Future<List<PartRecord>> fetchParts([PartQueryFilters filters = const PartQueryFilters()]) async {
    try {
      var query = client
          .from(SupabaseTables.parts)
          .select(_partWithCompatibilitySelect);

      if (filters.partType != null) {
        query = query.eq('part_type', filters.partType!);
      }

      final search = filters.searchQuery?.trim();
      if (search != null && search.isNotEmpty) {
        query = query.or(
          'sn_number.ilike.%$search%,'
          'part_type.ilike.%$search%,'
          'application_raw.ilike.%$search%',
        );
      }

      final data = await query
          .order('created_at', ascending: false)
          .range(filters.offset, filters.offset + filters.limit - 1);

      final parts = (data as List)
          .cast<Map<String, dynamic>>()
          .map(PartRecord.fromJson)
          .toList();

      return _applyCompatibilityFilters(parts, filters);
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<PartRecord?> fetchPartById(int partId) async {
    try {
      final data = await client
          .from(SupabaseTables.parts)
          .select(_partWithCompatibilitySelect)
          .eq('id', partId)
          .maybeSingle();

      if (data == null) return null;
      return PartRecord.fromJson(data);
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<List<PartRecord>> searchPartsByOeNumber(String oeNumber) async {
    try {
      final data = await client
          .from(SupabaseTables.parts)
          .select(_partWithCompatibilitySelect)
          .contains('oe_part_numbers', [oeNumber]);

      return (data as List)
          .cast<Map<String, dynamic>>()
          .map(PartRecord.fromJson)
          .toList();
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<List<String>> fetchDistinctPartTypes() async {
    try {
      final data = await client
          .from(SupabaseTables.parts)
          .select('part_type')
          .order('part_type');

      return (data as List)
          .cast<Map<String, dynamic>>()
          .map((row) => row['part_type'] as String)
          .toSet()
          .toList()
        ..sort();
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  Future<List<String>> fetchModelsForBrand(int brandId) async {
    try {
      final data = await client
          .from(SupabaseTables.partCompatibility)
          .select('model')
          .eq('brand_id', brandId)
          .order('model');

      return (data as List)
          .cast<Map<String, dynamic>>()
          .map((row) => row['model'] as String)
          .toSet()
          .toList()
        ..sort();
    } on PostgrestException catch (e) {
      throw SupabaseServiceException(e.message, cause: e);
    }
  }

  List<PartRecord> _applyCompatibilityFilters(
    List<PartRecord> parts,
    PartQueryFilters filters,
  ) {
    final brandId = filters.brandId;
    final brandName = filters.brandName?.toUpperCase();
    final model = filters.model;
    final year = filters.year;

    if (brandId == null &&
        brandName == null &&
        model == null &&
        year == null) {
      return parts;
    }

    return parts.where((part) {
      return part.compatibilities.any((compat) {
        if (brandId != null && compat.brandId != brandId) return false;
        if (brandName != null &&
            compat.brand?.name.toUpperCase() != brandName &&
            !(compat.rawText?.toUpperCase().contains(brandName) ?? false)) {
          return false;
        }
        if (model != null && compat.model != model) return false;
        if (!compat.matchesYear(year)) return false;
        return true;
      });
    }).toList();
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
