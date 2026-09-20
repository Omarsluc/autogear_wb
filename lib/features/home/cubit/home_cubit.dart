import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/catalog_repository.dart';
import '../../../core/models/auto_part.dart';
import '../../../core/models/part_record.dart';
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
        final service = SupabaseService.instance;

        final results = await Future.wait([
          service.fetchMakes(),
          service.fetchModels(make: activeFilters.make),
          service.fetchYears(make: activeFilters.make, model: activeFilters.model),
          service.fetchSystems(
            make: activeFilters.make,
            model: activeFilters.model,
            year: activeFilters.year,
          ),
          service.fetchPartNames(
            make: activeFilters.make,
            model: activeFilters.model,
            year: activeFilters.year,
            system: activeFilters.system,
          ),
          service.searchParts(
            make: activeFilters.make,
            model: activeFilters.model,
            year: activeFilters.year,
            system: activeFilters.system,
            partName: activeFilters.category,
            searchQuery: activeFilters.searchQuery,
          ),
        ]);

        final supaMakes = results[0] as List<String>;
        final supaModels = results[1] as List<String>;
        final supaYears = results[2] as List<int>;
        final supaSystems = results[3] as List<String>;
        final supaPartNames = results[4] as List<String>;
        final records = results[5] as List<PartRecord>;

        final autoParts = records.map((r) => r.toAutoPart()).toList();

        emit(state.copyWith(
          parts: autoParts,
          isLoading: false,
          availableMakes: supaMakes.isNotEmpty ? supaMakes : makes,
          availableModels: supaModels.isNotEmpty ? supaModels : availableModels(activeFilters.make),
          availableYears: supaYears.isNotEmpty ? supaYears : years,
          availableSystems: supaSystems.isNotEmpty ? supaSystems : systems,
          availablePartNames: supaPartNames.isNotEmpty
              ? supaPartNames
              : availableCategories(activeFilters.system),
        ));
        return;
      } catch (_) {
        // Fallback to local catalog repository filtering on network failure
      }
    }

    final localParts = filterParts(activeFilters);
    emit(state.copyWith(
      parts: localParts,
      isLoading: false,
      availableMakes: makes,
      availableModels: availableModels(activeFilters.make),
      availableYears: years,
      availableSystems: systems,
      availablePartNames: availableCategories(activeFilters.system),
    ));
  }

  void updateFilters(CatalogFilters filters) {
    loadParts(filters);
  }

  void selectMake(String make) {
    final newFilters = state.filters.copyWith(
      make: make,
      clearModel: true,
      clearCategory: true,
    );
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
