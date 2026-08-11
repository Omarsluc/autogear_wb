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
      snNumber: json['sn_number'] as String,
      oePartNumbers: oeNumbers is List
          ? oeNumbers.map((e) => e.toString()).toList()
          : const [],
      partType: json['part_type'] as String,
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
}
