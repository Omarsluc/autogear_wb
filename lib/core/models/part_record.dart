import 'auto_part.dart';
import 'part_compatibility.dart';

class PartRecord {
  const PartRecord({
    required this.id,
    required this.snNumber,
    required this.oePartNumbers,
    required this.partType,
    this.imageUrl,
    this.price,
    this.applicationRaw,
    this.createdAt,
    this.compatibilities = const [],
  });

  final int id;
  final String snNumber;
  final List<String> oePartNumbers;
  final String partType;
  final String? imageUrl;
  final double? price;
  final String? applicationRaw;
  final DateTime? createdAt;
  final List<PartCompatibility> compatibilities;

  factory PartRecord.fromJson(Map<String, dynamic> json) {
    final oeNumbers = json['oe_part_numbers'];
    final compatJson = json['part_compatibility'];

    return PartRecord(
      id: json['id'] as int,
      snNumber: json['sn_number'] as String? ?? '',
      oePartNumbers: oeNumbers is List
          ? oeNumbers.map((e) => e.toString()).toList()
          : const [],
      partType: json['part_type'] as String? ?? 'General',
      imageUrl: json['image_url'] as String?,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      applicationRaw: json['application_raw'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
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
        'sn_number': snNumber,
        'oe_part_numbers': oePartNumbers,
        'part_type': partType,
        if (imageUrl != null) 'image_url': imageUrl,
        if (price != null) 'price': price,
        if (applicationRaw != null) 'application_raw': applicationRaw,
      };

  AutoPart toAutoPart() {
    final firstCompat = compatibilities.isNotEmpty ? compatibilities.first : null;
    final makeName = firstCompat?.brand?.name ??
        (firstCompat?.rawText?.isNotEmpty == true ? firstCompat!.rawText! : 'UNIVERSAL');
    final modelName = firstCompat?.model ?? 'All Models';

    final yearSet = <int>{};
    for (final compat in compatibilities) {
      final yFrom = compat.yearFrom;
      final yTo = compat.yearTo ?? yFrom;
      if (yFrom != null && yTo != null && yFrom <= yTo) {
        for (var y = yFrom; y <= yTo; y++) {
          yearSet.add(y);
        }
      }
    }

    return AutoPart(
      id: id.toString(),
      name: '$partType ${oePartNumbers.isNotEmpty ? oePartNumbers.first : snNumber}',
      sku: snNumber,
      oemNumber: oePartNumbers.join(', '),
      make: makeName.toUpperCase(),
      model: modelName,
      years: yearSet.toList()..sort(),
      system: partType,
      category: partType,
      description: applicationRaw ?? 'High quality auto part (SN: $snNumber).',
    );
  }
}

