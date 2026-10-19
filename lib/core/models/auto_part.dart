class AutoPart {
  const AutoPart({
    required this.id,
    required this.name,
    required this.sku,
    required this.oemNumber,
    required this.make,
    required this.model,
    required this.years,
    required this.system,
    required this.category,
    required this.description,
    this.inStock = true,
    this.pictureUrl,
    this.retailPrice,
    this.wholesalePrice,
    this.country,
    this.compatNotesAr,
    this.englishNotes,
  });

  final String id;
  final String name;
  final String sku;
  final String oemNumber;
  final String make;
  final String model;
  final List<int> years;
  final String system;
  final String category;
  final String description;
  final bool inStock;
  final String? pictureUrl;
  final double? retailPrice;
  final double? wholesalePrice;
  final String? country;
  final String? compatNotesAr;
  final String? englishNotes;

  String? get resolvedImageUrl {
    final candidates = resolvedImageCandidates;
    return candidates.isNotEmpty ? candidates.first : null;
  }

  List<String> get resolvedImageCandidates {
    final list = <String>[];

    void addUrl(String path) {
      if (path.isEmpty) return;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        if (!list.contains(path)) list.add(path);
        return;
      }
      final clean = path.startsWith('/') ? path.substring(1) : path;

      // 1. Primary path: parts-images/items_photos/<clean>
      final url1 = clean.startsWith('items_photos/')
          ? 'https://vrwgtpbeejpnnaoflrfy.supabase.co/storage/v1/object/public/parts-images/$clean'
          : 'https://vrwgtpbeejpnnaoflrfy.supabase.co/storage/v1/object/public/parts-images/items_photos/$clean';
      if (!list.contains(url1)) list.add(url1);

      // 2. Direct path: parts-images/<clean>
      final url2 = 'https://vrwgtpbeejpnnaoflrfy.supabase.co/storage/v1/object/public/parts-images/$clean';
      if (!list.contains(url2)) list.add(url2);

      // 3. Fallback bucket: items_photos/<clean>
      final url3 = 'https://vrwgtpbeejpnnaoflrfy.supabase.co/storage/v1/object/public/items_photos/$clean';
      if (!list.contains(url3)) list.add(url3);
    }

    final raw = pictureUrl?.trim();
    if (raw != null && raw.isNotEmpty) {
      addUrl(raw);
      if (!raw.contains('.')) addUrl('$raw.png');
    }

    for (final code in [sku, oemNumber, id]) {
      final clean = code.trim();
      if (clean.isNotEmpty && !clean.contains(' ')) {
        final lower = clean.toLowerCase();
        final upper = clean.toUpperCase();

        for (final c in {clean, lower, upper}) {
          addUrl(c.contains('.') ? c : '$c.png');
          addUrl(c);
        }

        // Handle specific auto parts SKU to filename prefix mappings
        if (lower.startsWith('cb')) {
          final digits = lower.replaceAll(RegExp(r'[^0-9]'), '');
          if (digits.isNotEmpty) {
            final formatted = digits.length == 1 ? '0$digits' : digits;
            addUrl('cas$formatted.png');
            addUrl('cas$digits.png');
            addUrl('cb$formatted.png');
          }
        } else if (lower.startsWith('osg') || lower.startsWith('osk')) {
          final digits = lower.replaceAll(RegExp(r'[^0-9]'), '');
          if (digits.isNotEmpty) {
            final formatted = digits.length == 1 ? '0$digits' : digits;
            addUrl('osk$formatted.png');
            addUrl('osg$formatted.png');
            addUrl('os$formatted.png');
          }
        } else if (lower.startsWith('altr') || lower.startsWith('alt')) {
          final digits = lower.replaceAll(RegExp(r'[^0-9]'), '');
          if (digits.isNotEmpty) {
            final formatted = digits.length == 1 ? '0$digits' : digits;
            addUrl('altr$formatted.png');
            addUrl('alt$formatted.png');
          }
        } else if (lower.startsWith('bs')) {
          final digits = lower.replaceAll(RegExp(r'[^0-9]'), '');
          if (digits.isNotEmpty) {
            final formatted = digits.length == 1 ? '0$digits' : digits;
            addUrl('bs$formatted.png');
            addUrl('bs$digits.png');
          }
        }
      }
    }

    return list;
  }

  String get searchHaystack =>
      '$name $sku $oemNumber $make $model $category $system ${compatNotesAr ?? ''} ${englishNotes ?? ''}'.toLowerCase();

  bool matchesMake(String? targetMake) {
    if (targetMake == null || targetMake.trim().isEmpty) return true;
    final t = targetMake.trim().toLowerCase();

    // 1. Direct contains in make column
    if (make.toLowerCase().contains(t)) return true;

    // 2. Check english notes
    if (englishNotes?.toLowerCase().contains(t) ?? false) return true;

    // 3. Check arabic notes
    if (t == 'kia' && (compatNotesAr?.contains('كيا') ?? false)) return true;
    if (t == 'hyundai' &&
        ((compatNotesAr?.contains('هيونداي') ?? false) ||
            (compatNotesAr?.contains('هيونداى') ?? false))) {
      return true;
    }

    return false;
  }

  bool matchesModel(String? targetModel) {
    if (targetModel == null || targetModel.trim().isEmpty) return true;
    final t = targetModel.trim().toLowerCase();

    if (model.toLowerCase().contains(t)) return true;
    if (englishNotes?.toLowerCase().contains(t) ?? false) return true;
    if (compatNotesAr?.toLowerCase().contains(t) ?? false) return true;
    return false;
  }

  bool matchesYear(int? year) {
    if (year == null) return true;
    if (years.contains(year)) return true;
    final yStr = year.toString();
    if (englishNotes != null && englishNotes!.contains(yStr)) return true;
    if (compatNotesAr != null && compatNotesAr!.contains(yStr)) return true;
    return false;
  }

  bool matchesSystem(String? targetSystem) {
    if (targetSystem == null || targetSystem.trim().isEmpty) return true;
    final t = targetSystem.trim().toLowerCase();
    final keyword = t.replaceAll(RegExp(r'\s+system$'), '').trim();
    final sysLower = system.toLowerCase();
    if (keyword == 'brake' || keyword == 'braking') {
      return sysLower.contains('brak');
    }
    return sysLower.contains(keyword);
  }

  bool matchesCategory(String? targetCategory) {
    if (targetCategory == null || targetCategory.trim().isEmpty) return true;
    final t = targetCategory.trim().toLowerCase();
    final catLower = category.toLowerCase();
    final nameLower = name.toLowerCase();

    if (t.contains('oxygen') || t.contains('oxygn')) {
      return catLower.contains('oxygen') || catLower.contains('oxygn') ||
             nameLower.contains('oxygen') || nameLower.contains('oxygn');
    }
    if (t.contains('water temperature') || t.contains('coolant temperature')) {
      return catLower.contains('water temperature') || catLower.contains('coolant temperature') ||
             nameLower.contains('water temperature') || nameLower.contains('coolant temperature');
    }
    if (t.contains('manifold absolute pressure') || t == 'map sensor' || t == 'map') {
      return catLower.contains('manifold absolute pressure') || catLower.contains('map sensor') ||
             nameLower.contains('manifold absolute pressure') || nameLower.contains('map sensor');
    }
    if (t.contains('alternator')) {
      return catLower.contains('alternator') || nameLower.contains('alternator');
    }
    if (t == 'vvt sensor' || t == 'vvt') {
      return catLower.contains('vvt') || nameLower.contains('vvt');
    }
    return catLower.contains(t) || nameLower.contains(t);
  }

  bool matchesSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;

    // Handle "and" / "or" / comma separated searches like "kia and hyundai"
    if (q.contains(' and ') || q.contains(' or ') || q.contains(',')) {
      final orTerms = q.split(RegExp(r'\s+(?:and|or)\s+|,\s*')).where((t) => t.trim().isNotEmpty);
      if (orTerms.length > 1) {
        return orTerms.any((term) => matchesSearch(term.trim()));
      }
    }

    final cleanWords = q.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (cleanWords.isEmpty) return true;

    final haystack = searchHaystack;
    return cleanWords.every((w) => haystack.contains(w));
  }
}

class CatalogFilters {
  const CatalogFilters({
    this.make,
    this.model,
    this.year,
    this.system,
    this.category,
    this.searchQuery = '',
  });

  final String? make;
  final String? model;
  final int? year;
  final String? system;
  final String? category;
  final String searchQuery;

  CatalogFilters copyWith({
    String? make,
    String? model,
    int? year,
    String? system,
    String? category,
    String? searchQuery,
    bool clearMake = false,
    bool clearModel = false,
    bool clearYear = false,
    bool clearSystem = false,
    bool clearCategory = false,
  }) {
    return CatalogFilters(
      make: clearMake ? null : (make ?? this.make),
      model: clearModel ? null : (model ?? this.model),
      year: clearYear ? null : (year ?? this.year),
      system: clearSystem ? null : (system ?? this.system),
      category: clearCategory ? null : (category ?? this.category),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters =>
      make != null ||
      model != null ||
      year != null ||
      system != null ||
      category != null ||
      searchQuery.isNotEmpty;
}
