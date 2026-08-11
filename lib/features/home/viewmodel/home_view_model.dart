import 'package:flutter/foundation.dart';

import '../../../core/data/catalog_repository.dart';
import '../../../core/models/auto_part.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    _applyFilters();
  }

  CatalogFilters _filters = const CatalogFilters();
  List<AutoPart> _filteredParts = catalogParts;

  CatalogFilters get filters => _filters;
  List<AutoPart> get filteredParts => _filteredParts;

  void updateFilters(CatalogFilters filters) {
    _filters = filters;
    _applyFilters();
  }

  void applySearch() {
    _applyFilters();
  }

  void selectMake(String make) {
    _filters = _filters.copyWith(make: make, clearModel: true);
    _applyFilters();
  }

  void selectSystem(String system, {String? category}) {
    _filters = _filters.copyWith(
      system: system,
      category: category,
      clearCategory: category == null,
    );
    _applyFilters();
  }

  void clearFilters() {
    _filters = const CatalogFilters();
    _applyFilters();
  }

  void _applyFilters() {
    _filteredParts = filterParts(_filters);
    notifyListeners();
  }
}
