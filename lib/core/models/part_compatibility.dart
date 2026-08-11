import 'brand.dart';

class PartCompatibility {
  const PartCompatibility({
    required this.id,
    required this.partId,
    required this.brandId,
    required this.model,
    this.engine,
    this.yearFrom,
    this.yearTo,
    this.rawText,
    this.brand,
  });

  final int id;
  final int partId;
  final int brandId;
  final String model;
  final String? engine;
  final int? yearFrom;
  final int? yearTo;
  final String? rawText;
  final Brand? brand;

  factory PartCompatibility.fromJson(Map<String, dynamic> json) {
    final brandJson = json['brands'];
    return PartCompatibility(
      id: json['id'] as int,
      partId: json['part_id'] as int,
      brandId: json['brand_id'] as int,
      model: json['model'] as String,
      engine: json['engine'] as String?,
      yearFrom: json['year_from'] as int?,
      yearTo: json['year_to'] as int?,
      rawText: json['raw_text'] as String?,
      brand: brandJson is Map<String, dynamic> ? Brand.fromJson(brandJson) : null,
    );
  }

  bool matchesYear(int? year) {
    if (year == null) return true;
    if (yearFrom != null && year < yearFrom!) return false;
    if (yearTo != null && year > yearTo!) return false;
    return true;
  }
}
