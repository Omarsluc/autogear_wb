import '../../../core/models/auto_part.dart';

class HomeState {
  const HomeState({
    this.filters = const CatalogFilters(),
    this.parts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.availableMakes = const [],
    this.availableModels = const [],
    this.availableYears = const [],
    this.availableSystems = const [],
    this.availablePartNames = const [],
  });

  final CatalogFilters filters;
  final List<AutoPart> parts;
  final bool isLoading;
  final String? errorMessage;

  final List<String> availableMakes;
  final List<String> availableModels;
  final List<int> availableYears;
  final List<String> availableSystems;
  final List<String> availablePartNames;

  HomeState copyWith({
    CatalogFilters? filters,
    List<AutoPart>? parts,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<String>? availableMakes,
    List<String>? availableModels,
    List<int>? availableYears,
    List<String>? availableSystems,
    List<String>? availablePartNames,
  }) {
    return HomeState(
      filters: filters ?? this.filters,
      parts: parts ?? this.parts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      availableMakes: availableMakes ?? this.availableMakes,
      availableModels: availableModels ?? this.availableModels,
      availableYears: availableYears ?? this.availableYears,
      availableSystems: availableSystems ?? this.availableSystems,
      availablePartNames: availablePartNames ?? this.availablePartNames,
    );
  }
}

