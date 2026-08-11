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

  bool matchesYear(int? year) {
    if (year == null) return true;
    return years.contains(year);
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
