import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/catalog_repository.dart';
import '../../../core/models/auto_part.dart';
import '../../../core/networking/supabase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState(parts: catalogParts)) {
    loadParts();
  }

  Future<void> loadParts([CatalogFilters? filters]) async {
    final activeFilters = filters ?? state.filters;
    emit(state.copyWith(filters: activeFilters, isLoading: true, clearError: true));

    if (SupabaseService.isInitialized) {
      try {
        final queryFilters = PartQueryFilters(
          brandName: activeFilters.make,
          model: activeFilters.model,
          year: activeFilters.year,
          partType: activeFilters.category ?? activeFilters.system,
          searchQuery: activeFilters.searchQuery,
        );
        final records = await SupabaseService.instance.fetchParts(queryFilters);
        if (records.isNotEmpty) {
          final autoParts = records.map((r) => r.toAutoPart()).toList();
          emit(state.copyWith(parts: autoParts, isLoading: false));
          return;
        }
      } catch (_) {
        // Fallback to local catalog repository filtering on network failure
      }
    }

    final localParts = filterParts(activeFilters);
    emit(state.copyWith(parts: localParts, isLoading: false));
  }

  void updateFilters(CatalogFilters filters) {
    loadParts(filters);
  }

  void selectMake(String make) {
    final newFilters = state.filters.copyWith(make: make, clearModel: true);
    loadParts(newFilters);
  }

  void selectSystem(String system, {String? category}) {
    final newFilters = state.filters.copyWith(
      system: system,
      category: category,
      clearCategory: category == null,
    );
    loadParts(newFilters);
  }

  void clearFilters() {
    loadParts(const CatalogFilters());
  }
}
