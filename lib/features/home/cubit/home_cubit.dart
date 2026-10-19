import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/filter_translation_service.dart';
import '../../../core/models/auto_part.dart';
import '../../../core/models/part_record.dart';
import '../../../core/networking/supabase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState()) {
    loadParts();
  }

  Future<void> loadParts([CatalogFilters? filters]) async {
    final activeFilters = filters ?? state.filters;
    emit(state.copyWith(filters: activeFilters, isLoading: true, clearError: true));

    if (SupabaseService.isInitialized) {
      if (!FilterTranslationService.instance.isInitialized) {
        FilterTranslationService.instance.init();
      }
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
          availableMakes: supaMakes,
          availableModels: supaModels,
          availableYears: supaYears,
          availableSystems: supaSystems,
          availablePartNames: supaPartNames,
        ));
        return;
      } catch (e) {
        emit(state.copyWith(
          parts: const [],
          isLoading: false,
          errorMessage: e.toString(),
        ));
        return;
      }
    }

    emit(state.copyWith(
      parts: const [],
      isLoading: false,
      availableMakes: const [],
      availableModels: const [],
      availableYears: const [],
      availableSystems: const [],
      availablePartNames: const [],
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
