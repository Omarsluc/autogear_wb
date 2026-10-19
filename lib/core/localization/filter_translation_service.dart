import 'package:flutter/foundation.dart';
import '../networking/supabase.dart';

class FilterTranslation {
  const FilterTranslation({
    required this.id,
    required this.kind,
    required this.termEn,
    required this.termAr,
  });

  final int id;
  final String kind;
  final String termEn;
  final String termAr;

  factory FilterTranslation.fromJson(Map<String, dynamic> json) {
    return FilterTranslation(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      kind: (json['kind']?.toString() ?? '').trim().toLowerCase(),
      termEn: (json['term_en']?.toString() ?? '').trim(),
      termAr: (json['term_ar']?.toString() ?? '').trim(),
    );
  }
}

class FilterTranslationService {
  FilterTranslationService._();

  static final FilterTranslationService instance = FilterTranslationService._();

  final Map<String, Map<String, String>> _byKindEnToAr = {};
  final Map<String, String> _allEnToAr = {};
  final Map<String, String> _allArToEn = {};

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Built-in fallback translations for core systems and common parts
  static const Map<String, String> _fallbackSystems = {
    'engine system': 'نظام المحرك',
    'electrical system': 'النظام الكهربائي',
    'cooling system': 'نظام التبريد',
    'braking system': 'نظام الفرامل',
    'brake system': 'نظام الفرامل',
    'lighting system': 'نظام الإضاءة',
    'safety system': 'نظام الأمان',
    'ignition system': 'نظام الإشعال',
    'fuel system': 'نظام الوقود',
    'transmission system': 'نظام ناقل الحركة',
    'exhaust system': 'نظام العادم',
    'airbag system': 'نظام الوسائد الهوائية',
    'suspension system': 'نظام التعليق والتوجيه',
    'suspension & steering system': 'نظام التعليق والتوجيه',
  };

  static const Map<String, String> _fallbackParts = {
    'oxygen sensor': 'حساس شكمان',
    'oxygn sensor': 'حساس شكمان',
    'ignition wire': 'سلوك بوجيهات',
    'spark plug wires': 'سلوك بوجيهات',
    'alternator regulator': 'كتاوت',
    'alternator voltage regulator': 'كتاوت دينامو',
    'thermostat': 'ترموستات',
    'vvt sensor': 'حساس VVT',
    'water temperature sensor': 'حساس حرارة المياه',
    'coolant temperature sensor': 'حساس حرارة مياه',
    'temperature switch': 'صباع حرارة',
    'oil pressure sensor': 'مكنة زيت',
    'map sensor': 'حساس الماب',
    'manifold absolute pressure sensor': 'حساس ماب',
    'intake air temperature sensor': 'حساس IATS',
    'speed sensor': 'حساس سرعة',
    'vehicle speed sensor': 'حساس سرعة',
    'valve cover': 'غطاء وش سلندر',
    'valve cover gasket': 'جوان غطاء التيكهات',
    'brake light switch': 'ماكينة ستوب',
    'reverse light switch': 'ماكينة مارشيدير',
    'reverse switch sensor': 'ماكينة مارشدير',
    'crankshaft position sensor': 'حساس كرنك',
    'camshaft position sensor': 'حساس كامة',
    'idle air control valve': 'حساس ايدول',
    'throttle position sensor': 'حساس بوابة TPS',
    'ignition coil': 'موبينة',
    'pcv': 'بلف تبخير',
    'canister': 'كانستر',
    'canister sensor': 'حساس كانستر',
    'clutch master cylinder': 'طلمبة كلتش',
    'airbag clock spring': 'شريط الإيرباج',
    'brake pedal sensor': 'حساس دواسة الفرامل',
    'cmc sensor': 'حساس CMC',
    'dhb sensor': 'حساس DHB',
    'headlamp': 'كشاف امامي',
    'knock sensor': 'حساس نوك',
    'mass air flow sensor': 'حساس الايرماس',
    'radiator fan': 'مروحة رديتر',
    'tpms sensor': 'حساس TPMS',
    'exhaust manifold': 'مانيفولد',
    'manifold gasket set': 'طقم جوانات مانيفولد',
    'ac pressure sensor': 'حساس ضغط التكييف',
    'diesel pressure sensor': 'حساس ضغط الديزيل',
    'abs sensor': 'حساس اي بي اس',
    'ignition switch': 'كونتاكت',
  };

  void _seedFallbacks() {
    for (final entry in _fallbackSystems.entries) {
      _byKindEnToAr.putIfAbsent('system', () => {})[entry.key] = entry.value;
      _allEnToAr[entry.key] = entry.value;
      _allArToEn[entry.value] = entry.key;
    }
    for (final entry in _fallbackParts.entries) {
      _byKindEnToAr.putIfAbsent('item_type', () => {})[entry.key] = entry.value;
      _allEnToAr[entry.key] = entry.value;
      _allArToEn[entry.value] = entry.key;
    }
  }

  /// Initialize and load all translations from Supabase table `translations`.
  Future<void> init() async {
    _seedFallbacks();

    if (!SupabaseService.isInitialized) return;

    try {
      final List<dynamic> data = await SupabaseService.instance.client
          .from(SupabaseTables.translations)
          .select()
          .limit(2000);

      for (final row in data) {
        if (row is Map<String, dynamic>) {
          final t = FilterTranslation.fromJson(row);
          if (t.termEn.isNotEmpty && t.termAr.isNotEmpty) {
            final key = t.termEn.toLowerCase();
            _byKindEnToAr.putIfAbsent(t.kind, () => {})[key] = t.termAr;
            _allEnToAr[key] = t.termAr;
            _allArToEn[t.termAr.toLowerCase()] = t.termEn;
          }
        }
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('FilterTranslationService init error: $e');
    }
  }

  /// Translates a given filter term into Arabic if [isArabic] is true.
  String translate(String term, {String? kind, required bool isArabic}) {
    if (!isArabic) return term;
    final clean = term.trim();
    if (clean.isEmpty) return clean;

    final key = clean.toLowerCase();

    // 1. Check specific kind match
    if (kind != null && _byKindEnToAr.containsKey(kind)) {
      final match = _byKindEnToAr[kind]![key];
      if (match != null && match.isNotEmpty) return match;
    }

    // 2. Check general match
    final generalMatch = _allEnToAr[key];
    if (generalMatch != null && generalMatch.isNotEmpty) return generalMatch;

    // 3. Smart system fuzzy match (e.g. "Braking System" -> "braking system" / "brake system")
    if (kind == 'system' || kind == null) {
      final sysKeyword = key.replaceAll(RegExp(r'\s+system$'), '').trim();
      final systemMap = _byKindEnToAr['system'] ?? _fallbackSystems;
      for (final entry in systemMap.entries) {
        final entryKeyword = entry.key.replaceAll(RegExp(r'\s+system$'), '').trim();
        if (sysKeyword == entryKeyword ||
            (sysKeyword.contains('brak') && entryKeyword.contains('brak'))) {
          return entry.value;
        }
      }
    }

    // 4. Smart part name fuzzy match
    if (kind == 'item_type' || kind == null) {
      final partMap = _byKindEnToAr['item_type'] ?? _fallbackParts;
      if (key.contains('oxygen') || key.contains('oxygn')) {
        return partMap['oxygen sensor'] ?? 'حساس شكمان';
      }
      if (key.contains('water temperature') || key.contains('coolant temperature')) {
        return partMap['water temperature sensor'] ?? 'حساس حرارة المياه';
      }
      if (key.contains('alternator')) {
        return partMap['alternator regulator'] ?? 'كتاوت';
      }
      if (key.contains('manifold absolute pressure') || key == 'map sensor' || key == 'map') {
        return partMap['map sensor'] ?? 'حساس الماب';
      }
      if (key == 'abs sensor') {
        return partMap['abs sensor'] ?? 'حساس اي بي اس';
      }
    }

    return clean;
  }

  /// If user searched in Arabic, looks up the corresponding English term.
  String? getEnglishTermForArabic(String arabicQuery) {
    final clean = arabicQuery.trim().toLowerCase();
    if (clean.isEmpty) return null;
    return _allArToEn[clean];
  }
}
