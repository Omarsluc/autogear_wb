import '../../../core/models/auto_part.dart';

class HomeState {
  const HomeState({
    this.filters = const CatalogFilters(),
    this.parts = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final CatalogFilters filters;
  final List<AutoPart> parts;
  final bool isLoading;
  final String? errorMessage;

  HomeState copyWith({
    CatalogFilters? filters,
    List<AutoPart>? parts,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      filters: filters ?? this.filters,
      parts: parts ?? this.parts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
