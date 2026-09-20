import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/catalog_repository.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/models/auto_part.dart';
import '../../../../core/theme/app_theme.dart';
import '../../home/cubit/home_cubit.dart';
import '../../home/cubit/home_state.dart';
import '../../home/view/widgets/app_header.dart';
import '../../home/view/widgets/catalog_section.dart';
import '../../home/view/widgets/info_sections.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, this.initialFilters});

  final CatalogFilters? initialFilters;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  static const int _pageSize = 12;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      context.read<HomeCubit>().updateFilters(widget.initialFilters!);
    }
  }

  void _onFilterChanged(CatalogFilters filters) {
    setState(() {
      _currentPage = 1;
    });
    context.read<HomeCubit>().updateFilters(filters);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 900;

    return Scaffold(
      appBar: AppHeader(
        isMobile: isMobile,
        onNavigate: (section) {
          Navigator.pop(context);
        },
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final parts = state.parts;
          final filters = state.filters;

          final totalPages = (parts.length / _pageSize).ceil();
          final effectiveTotalPages = totalPages == 0 ? 1 : totalPages;
          if (_currentPage > effectiveTotalPages) {
            _currentPage = effectiveTotalPages;
          }

          final startIndex = (_currentPage - 1) * _pageSize;
          final endIndex = (startIndex + _pageSize) > parts.length
              ? parts.length
              : (startIndex + _pageSize);
          final paginatedParts = parts.isEmpty
              ? <AutoPart>[]
              : parts.sublist(startIndex, endIndex);

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Banner
                RepaintBoundary(
                  child: Container(
                    width: double.infinity,
                    color: AppColors.primaryDark,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 24 : 64,
                      vertical: isMobile ? 32 : 48,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              tooltip: 'Back to Home',
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.tr(context, 'parts_catalog'),
                              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                fontSize: isMobile ? 28 : 36,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 48),
                          child: Text(
                            AppStrings.tr(context, 'browse_count').replaceAll(
                              '{count}',
                              parts.length.toString(),
                            ),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Filter Controls Bar
                RepaintBoundary(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 64,
                      vertical: 24,
                    ),
                    child: _CatalogFilterBar(
                      filters: filters,
                      onFiltersChanged: _onFilterChanged,
                      isWide: !isMobile,
                    ),
                  ),
                ),

                // Active Filter Chips
                if (filters.hasActiveFilters)
                  Container(
                    width: double.infinity,
                    color: AppColors.background,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 24 : 64,
                      vertical: 12,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (filters.make != null)
                          CatalogFilterChip(
                            label: 'Make: ${filters.make}',
                            onRemove: () => _onFilterChanged(
                              filters.copyWith(clearMake: true, clearModel: true),
                            ),
                          ),
                        if (filters.model != null)
                          CatalogFilterChip(
                            label: 'Model: ${filters.model}',
                            onRemove: () => _onFilterChanged(
                              filters.copyWith(clearModel: true),
                            ),
                          ),
                        if (filters.year != null)
                          CatalogFilterChip(
                            label: 'Year: ${filters.year}',
                            onRemove: () => _onFilterChanged(
                              filters.copyWith(clearYear: true),
                            ),
                          ),
                        if (filters.system != null)
                          CatalogFilterChip(
                            label: 'System: ${filters.system}',
                            onRemove: () => _onFilterChanged(
                              filters.copyWith(clearSystem: true, clearCategory: true),
                            ),
                          ),
                        if (filters.category != null)
                          CatalogFilterChip(
                            label: 'Part: ${filters.category}',
                            onRemove: () => _onFilterChanged(
                              filters.copyWith(clearCategory: true),
                            ),
                          ),
                        if (filters.searchQuery.isNotEmpty)
                          CatalogFilterChip(
                            label: 'Search: "${filters.searchQuery}"',
                            onRemove: () => _onFilterChanged(
                              filters.copyWith(searchQuery: ''),
                            ),
                          ),
                        ActionChip(
                          label: Text(
                            AppStrings.tr(context, 'clear_all'),
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                          backgroundColor: Colors.red.shade50,
                          onPressed: () => _onFilterChanged(const CatalogFilters()),
                        ),
                      ],
                    ),
                  ),

                // Parts Grid Section (Reused CatalogSection Widget)
                RepaintBoundary(
                  child: CatalogSection(
                    parts: paginatedParts,
                    filters: filters,
                    onFiltersChanged: _onFilterChanged,
                    isLoading: state.isLoading,
                    showHeader: false,
                    currentPage: _currentPage,
                    totalPages: effectiveTotalPages,
                    startIndex: startIndex + 1,
                    endIndex: endIndex,
                    totalItems: parts.length,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                  ),
                ),

                const RepaintBoundary(child: FooterSection()),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CatalogFilterBar extends StatefulWidget {
  const _CatalogFilterBar({
    required this.filters,
    required this.onFiltersChanged,
    required this.isWide,
  });

  final CatalogFilters filters;
  final ValueChanged<CatalogFilters> onFiltersChanged;
  final bool isWide;

  @override
  State<_CatalogFilterBar> createState() => _CatalogFilterBarState();
}

class _CatalogFilterBarState extends State<_CatalogFilterBar> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.filters.searchQuery);
  }

  @override
  void didUpdateWidget(covariant _CatalogFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filters.searchQuery != _controller.text && _debounceTimer?.isActive != true) {
      _controller.text = widget.filters.searchQuery;
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      widget.onFiltersChanged(widget.filters.copyWith(searchQuery: value));
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final makesList = state.availableMakes.isNotEmpty ? state.availableMakes : makes;
        final modelsList = state.availableModels.isNotEmpty
            ? state.availableModels
            : availableModels(widget.filters.make);
        final yearsList = state.availableYears.isNotEmpty ? state.availableYears : years;
        final systemsList = state.availableSystems.isNotEmpty ? state.availableSystems : systems;
        final partNamesList = state.availablePartNames.isNotEmpty
            ? state.availablePartNames
            : availableCategories(widget.filters.system);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: AppStrings.tr(context, 'search_placeholder'),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _debounceTimer?.cancel();
                          _controller.clear();
                          widget.onFiltersChanged(widget.filters.copyWith(searchQuery: ''));
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _FilterDropdown(
                  label: AppStrings.tr(context, 'select_make'),
                  value: widget.filters.make,
                  items: makesList,
                  width: widget.isWide ? 180 : (width > 500 ? 160 : null),
                  onChanged: (v) => widget.onFiltersChanged(
                    widget.filters.copyWith(make: v, clearModel: true, clearCategory: true),
                  ),
                ),
                _FilterDropdown(
                  label: AppStrings.tr(context, 'select_model'),
                  value: widget.filters.model,
                  items: modelsList,
                  width: widget.isWide ? 180 : (width > 500 ? 160 : null),
                  onChanged: (v) => widget.onFiltersChanged(widget.filters.copyWith(model: v)),
                ),
                _FilterDropdown<int>(
                  label: AppStrings.tr(context, 'select_year'),
                  value: widget.filters.year,
                  items: yearsList,
                  width: widget.isWide ? 140 : (width > 500 ? 120 : null),
                  itemLabel: (y) => y.toString(),
                  onChanged: (v) => widget.onFiltersChanged(widget.filters.copyWith(year: v)),
                ),
                _FilterDropdown(
                  label: AppStrings.tr(context, 'select_system'),
                  value: widget.filters.system,
                  items: systemsList,
                  width: widget.isWide ? 200 : (width > 500 ? 180 : null),
                  onChanged: (v) => widget.onFiltersChanged(
                    widget.filters.copyWith(system: v, clearCategory: true),
                  ),
                ),
                _FilterDropdown(
                  label: AppStrings.tr(context, 'select_part'),
                  value: widget.filters.category,
                  items: partNamesList,
                  width: widget.isWide ? 200 : (width > 500 ? 180 : null),
                  onChanged: (v) => widget.onFiltersChanged(widget.filters.copyWith(category: v)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width,
    this.enabled = true,
    this.itemLabel,
  });

  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final double? width;
  final bool enabled;
  final String Function(T)? itemLabel;

  @override
  Widget build(BuildContext context) {
    final child = DropdownButtonFormField<T>(
      key: ValueKey('$label-${items.contains(value) ? value : 'none'}'),
      initialValue: items.contains(value) ? value : null,
      isExpanded: true,
      isDense: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      hint: Text(
        label,
        style: const TextStyle(fontSize: 14),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel != null ? itemLabel!(item) : item.toString(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
    );

    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return SizedBox(width: double.infinity, child: child);
  }
}
