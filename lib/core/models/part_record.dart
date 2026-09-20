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
    final displayName = (itemType?.isNotEmpty == true)
        ? itemType!
        : ((system?.isNotEmpty == true)
            ? system!
            : (oem?.isNotEmpty == true ? 'OEM $oem' : 'Auto Part'));

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

    final displaySystem = system?.isNotEmpty == true ? system! : 'General';
    final displayCategory = itemType?.isNotEmpty == true ? itemType! : displaySystem;
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


