import 'auto_part.dart';
import 'part_compatibility.dart';

class PartRecord {
  const PartRecord({
    required this.id,
    this.sn,
    this.snStr = '',
    this.oem,
    this.pictureUrl,
    this.system,
    this.arabicNotes,
    this.englishNotes,
    this.country,
    this.make,
    this.model,
    this.years = const [],
    this.itemType,
    this.wholesalePrice,
    this.retailPrice,
    this.createdAt,
    this.updatedAt,
    this.compatibilities = const [],
  });

  final String id;
  final String? sn;
  final String snStr;
  final String? oem;
  final String? pictureUrl;
  final String? system;
  final String? arabicNotes;
  final String? englishNotes;
  final String? country;
  final String? make;
  final String? model;
  final List<int> years;
  final String? itemType;
  final double? wholesalePrice;
  final double? retailPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<PartCompatibility> compatibilities;

  // Backwards compatibility getters
  String? get compatNotesAr => arabicNotes;
  String? get partName => itemType;
  String get partType => (itemType?.isNotEmpty == true)
      ? itemType!
      : (system?.isNotEmpty == true ? system! : 'Part');
  String get snNumber => (sn?.isNotEmpty == true)
      ? sn!
      : (snStr.isNotEmpty ? snStr : (oem?.isNotEmpty == true ? oem! : id));
  int? get year => years.isNotEmpty ? years.first : null;

  factory PartRecord.fromJson(Map<String, dynamic> json) {
    final idVal = json['id']?.toString() ?? '';
    final snVal = json['sn'] ?? json['sn_number'];
    final String? parsedSn = snVal?.toString();
    final String parsedSnStr = snVal?.toString() ?? '';

    final oemVal = json['oem'];
    final oeNumbers = json['oe_part_numbers'];
    final String parsedOem = oemVal is String
        ? oemVal
        : (oeNumbers is List ? oeNumbers.map((e) => e.toString()).join(', ') : '');

    final pictureUrl = json['picture_url'] as String? ?? json['image_url'] as String?;
    final systemVal = json['system'] as String? ?? json['part_type'] as String?;
    final itemTypeVal = json['item_type'] as String? ?? json['part_name'] as String?;
    final arabicNotesVal = json['arabic_notes'] as String? ?? json['compat_notes_ar'] as String?;
    final englishNotesVal = json['english_notes'] as String? ?? json['application_raw'] as String?;

    final wholesalePrice = json['wholesale_price'] != null
        ? double.tryParse(json['wholesale_price'].toString())
        : null;

    final retailPrice = json['retail_price'] != null
        ? double.tryParse(json['retail_price'].toString())
        : (json['price'] != null ? double.tryParse(json['price'].toString()) : null);

    // Handle year column which is _int4 (int array in PostgreSQL/Supabase, e.g. [2018, 2019])
    final yearVal = json['year'];
    final List<int> parsedYears = [];
    if (yearVal is List) {
      for (final y in yearVal) {
        if (y != null) {
          final p = int.tryParse(y.toString());
          if (p != null) parsedYears.add(p);
        }
      }
    } else if (yearVal != null) {
      final p = int.tryParse(yearVal.toString());
      if (p != null) parsedYears.add(p);
    }

    if (parsedYears.isEmpty) {
      parsedYears.addAll(_extractYearsFromNotes(englishNotesVal, arabicNotesVal));
    }

    final compatJson = json['part_compatibility'];

    return PartRecord(
      id: idVal,
      sn: parsedSn,
      snStr: parsedSnStr,
      oem: parsedOem,
      pictureUrl: pictureUrl,
      system: systemVal,
      arabicNotes: arabicNotesVal,
      englishNotes: englishNotesVal,
      country: json['country'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      years: parsedYears,
      itemType: itemTypeVal,
      wholesalePrice: wholesalePrice,
      retailPrice: retailPrice,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      compatibilities: compatJson is List
          ? compatJson
              .whereType<Map<String, dynamic>>()
              .map(PartCompatibility.fromJson)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sn': sn,
        'oem': oem,
        'picture_url': pictureUrl,
        'system': system,
        'arabic_notes': arabicNotes,
        'english_notes': englishNotes,
        'country': country,
        'make': make,
        'model': model,
        'year': years,
        'item_type': itemType,
        'wholesale_price': wholesalePrice,
        'retail_price': retailPrice,
      };

  AutoPart toAutoPart() {
    String rawName = (itemType?.isNotEmpty == true)
        ? itemType!
        : ((system?.isNotEmpty == true)
            ? system!
            : (oem?.isNotEmpty == true ? 'OEM $oem' : 'Auto Part'));

    final nameLower = rawName.trim().toLowerCase();
    String displayName = rawName.trim();
    if (nameLower == 'oxygn sensor' || nameLower == 'oxygen sensor') {
      displayName = 'Oxygen Sensor';
    } else if (nameLower == 'water temperature sensor' || nameLower == 'coolant temperature sensor') {
      displayName = 'Water Temperature Sensor';
    } else if (nameLower == 'abs sensor') {
      displayName = 'ABS Sensor';
    } else if (nameLower == 'vvt sensor') {
      displayName = 'VVT Sensor';
    } else if (nameLower == 'speed sensor') {
      displayName = 'Speed Sensor';
    } else if (nameLower == 'map sensor' || nameLower == 'manifold absolute pressure sensor') {
      displayName = 'MAP Sensor';
    } else if (nameLower == 'oil pressure sensor') {
      displayName = 'Oil Pressure Sensor';
    } else if (nameLower == 'alternator regulator' || nameLower == 'alternator voltage regulator') {
      displayName = 'Alternator Regulator';
    }

    final displaySku = (sn?.isNotEmpty == true)
        ? sn!
        : (snStr.isNotEmpty ? snStr : (oem?.isNotEmpty == true ? oem! : id));

    final displayMake = (make?.isNotEmpty == true)
        ? make!.toUpperCase()
        : (compatibilities.isNotEmpty
            ? (compatibilities.first.brand?.name ??
                compatibilities.first.rawText ??
                'UNIVERSAL')
            : 'UNIVERSAL');

    final displayModel = (model?.isNotEmpty == true)
        ? model!
        : (compatibilities.isNotEmpty ? compatibilities.first.model : 'All Models');

    final yearSet = <int>{...years};
    for (final compat in compatibilities) {
      final yFrom = compat.yearFrom;
      final yTo = compat.yearTo ?? yFrom;
      if (yFrom != null && yTo != null && yFrom <= yTo) {
        for (var y = yFrom; y <= yTo; y++) {
          yearSet.add(y);
        }
      }
    }

    String rawSystem = system?.isNotEmpty == true ? system! : 'General';
    final sysLower = rawSystem.toLowerCase();
    String displaySystem;
    if (sysLower.contains('brak')) {
      displaySystem = 'Braking System';
    } else if (sysLower.contains('engine')) {
      displaySystem = 'Engine System';
    } else if (sysLower.contains('electric')) {
      displaySystem = 'Electrical System';
    } else if (sysLower.contains('cool')) {
      displaySystem = 'Cooling System';
    } else if (sysLower.contains('ignit')) {
      displaySystem = 'Ignition System';
    } else if (sysLower.contains('exhaust')) {
      displaySystem = 'Exhaust System';
    } else {
      displaySystem = rawSystem
          .split(' ')
          .map((w) => w.isNotEmpty ? (w[0].toUpperCase() + w.substring(1)) : '')
          .join(' ');
    }

    final displayCategory = displayName.isNotEmpty ? displayName : displaySystem;
    final displayDesc = englishNotes?.isNotEmpty == true
        ? englishNotes!
        : (arabicNotes?.isNotEmpty == true
            ? arabicNotes!
            : 'High quality auto part (SN: $displaySku).');

    return AutoPart(
      id: id,
      name: displayName,
      sku: displaySku,
      oemNumber: oem ?? '',
      make: displayMake,
      model: displayModel,
      years: yearSet.toList()..sort(),
      system: displaySystem,
      category: displayCategory,
      description: displayDesc,
      pictureUrl: pictureUrl,
      retailPrice: retailPrice,
      wholesalePrice: wholesalePrice,
      country: country,
      compatNotesAr: arabicNotes,
      englishNotes: englishNotes,
    );
  }
}

List<int> _extractYearsFromNotes(String? en, String? ar) {
  final text = '${en ?? ''} ${ar ?? ''}';
  if (text.trim().isEmpty) return const [];

  final yearSet = <int>{};

  // 1. Match year ranges like 2004-2011, 2004/07-2007/01, 2005–2013, 1994-2000
  final rangeRegex = RegExp(r'(19\d{2}|20\d{2})(?:/\d{2})?\s*[-–—]\s*(19\d{2}|20\d{2})(?:/\d{2})?');
  for (final match in rangeRegex.allMatches(text)) {
    final start = int.tryParse(match.group(1) ?? '');
    final end = int.tryParse(match.group(2) ?? '');
    if (start != null && end != null && start <= end && end - start <= 25) {
      for (var y = start; y <= end; y++) {
        yearSet.add(y);
      }
    }
  }

  // 2. Match open-ended year ranges like 1997-
  final openRangeRegex = RegExp(r'(19\d{2}|20\d{2})\s*[-–—]\s*(?!\d)');
  for (final match in openRangeRegex.allMatches(text)) {
    final start = int.tryParse(match.group(1) ?? '');
    if (start != null && start >= 1970) {
      final maxYear = (start + 10 < 2026) ? start + 10 : 2026;
      for (var y = start; y <= maxYear; y++) {
        yearSet.add(y);
      }
    }
  }

  // 3. Match standalone 4-digit years like 2006
  final singleYearRegex = RegExp(r'\b(19\d{2}|20\d{2})\b');
  for (final match in singleYearRegex.allMatches(text)) {
    final y = int.tryParse(match.group(1) ?? '');
    if (y != null && y >= 1970 && y <= 2026) {
      yearSet.add(y);
    }
  }

  return yearSet.toList()..sort();
}


