import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/catalog_repository.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/models/auto_part.dart';
import '../../../../core/theme/app_theme.dart';
import '../../cubit/home_cubit.dart';
import '../../cubit/home_state.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
    required this.onSearch,
    required this.resultCount,
  });

  final CatalogFilters filters;
  final ValueChanged<CatalogFilters> onFiltersChanged;
  final VoidCallback onSearch;
  final int resultCount;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > 900;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/hero.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.35),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryDark.withValues(alpha: 0.85),
                    AppColors.primary.withValues(alpha: 0.75),
                    AppColors.primaryDark.withValues(alpha: 0.90),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 64 : 24,
              vertical: isWide ? 72 : 48,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    AppStrings.tr(context, 'hero_tag'),
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.tr(context, 'hero_headline'),
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        fontSize: isWide ? 46 : 32,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: isWide ? 640 : double.infinity,
                  child: Text(
                    AppStrings.tr(context, 'hero_subheadline'),
                    style: TextStyle(
                      fontSize: isWide ? 18 : 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _FilterPanel(
                  filters: filters,
                  onFiltersChanged: onFiltersChanged,
                  onSearch: onSearch,
                  isWide: isWide,
                ),
                const SizedBox(height: 16),
                Text(
                  '$resultCount ${AppStrings.tr(context, 'match_count')}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterPanel extends StatefulWidget {
  const _FilterPanel({
    required this.filters,
    required this.onFiltersChanged,
    required this.onSearch,
    required this.isWide,
  });

  final CatalogFilters filters;
  final ValueChanged<CatalogFilters> onFiltersChanged;
  final VoidCallback onSearch;
  final bool isWide;

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.filters.searchQuery);
  }

  @override
  void didUpdateWidget(covariant _FilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filters.searchQuery != _controller.text && _debounceTimer?.isActive != true) {
      _controller.text = widget.filters.searchQuery;
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
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

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: AppStrings.tr(context, 'search_placeholder'),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                ),
                onChanged: _onSearchChanged,
                onSubmitted: (_) {
                  _debounceTimer?.cancel();
                  widget.onFiltersChanged(widget.filters.copyWith(searchQuery: _controller.text));
                  widget.onSearch();
                },
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _FilterDropdown(
                    label: AppStrings.tr(context, 'select_make'),
                    value: widget.filters.make,
                    items: makesList,
                    width: widget.isWide ? 180 : (width > 500 ? 160 : null),
                    enabled: true,
                    onChanged: (v) => widget.onFiltersChanged(
                      widget.filters.copyWith(
                        make: v,
                        clearMake: v == null,
                      ),
                    ),
                  ),
                  _FilterDropdown(
                    label: AppStrings.tr(context, 'select_model'),
                    value: widget.filters.model,
                    items: modelsList,
                    width: widget.isWide ? 180 : (width > 500 ? 160 : null),
                    enabled: true,
                    onChanged: (v) => widget.onFiltersChanged(
                      widget.filters.copyWith(
                        model: v,
                        clearModel: v == null,
                      ),
                    ),
                  ),
                  _FilterDropdown<int>(
                    label: AppStrings.tr(context, 'select_year'),
                    value: widget.filters.year,
                    items: yearsList,
                    width: widget.isWide ? 140 : (width > 500 ? 120 : null),
                    enabled: true,
                    itemLabel: (y) => y.toString(),
                    onChanged: (v) => widget.onFiltersChanged(
                      widget.filters.copyWith(
                        year: v,
                        clearYear: v == null,
                      ),
                    ),
                  ),
                  _FilterDropdown(
                    label: AppStrings.tr(context, 'select_system'),
                    value: widget.filters.system,
                    items: systemsList,
                    width: widget.isWide ? 220 : (width > 500 ? 200 : null),
                    enabled: true,
                    onChanged: (v) => widget.onFiltersChanged(
                      widget.filters.copyWith(
                        system: v,
                        clearSystem: v == null,
                      ),
                    ),
                  ),
                  _FilterDropdown(
                    label: AppStrings.tr(context, 'select_part'),
                    value: widget.filters.category,
                    items: partNamesList,
                    width: widget.isWide ? 200 : (width > 500 ? 180 : null),
                    enabled: true,
                    onChanged: (v) => widget.onFiltersChanged(
                      widget.filters.copyWith(
                        category: v,
                        clearCategory: v == null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _debounceTimer?.cancel();
                      widget.onFiltersChanged(widget.filters.copyWith(searchQuery: _controller.text));
                      widget.onSearch();
                    },
                    icon: const Icon(Icons.filter_list),
                    label: Text(AppStrings.tr(context, 'apply_filters')),
                  ),
                  if (widget.filters.hasActiveFilters)
                    OutlinedButton.icon(
                      onPressed: () {
                        _debounceTimer?.cancel();
                        _controller.clear();
                        widget.onFiltersChanged(const CatalogFilters());
                      },
                      icon: const Icon(Icons.clear),
                      label: Text(AppStrings.tr(context, 'clear_all')),
                    ),
                ],
              ),
            ],
          ),
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
      key: ValueKey('$label-${items.contains(value) ? value : 'none'}-$enabled'),
      initialValue: items.contains(value) ? value : null,
      isExpanded: true,
      isDense: true,
      decoration: InputDecoration(
        labelText: label,
        enabled: enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
        filled: !enabled,
        labelStyle: TextStyle(
          color: enabled ? AppColors.textSecondary : Colors.grey.shade400,
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      hint: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: enabled ? null : Colors.grey.shade400,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      items: enabled
          ? items
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
              .toList()
          : null,
      onChanged: enabled ? onChanged : null,
    );

    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return SizedBox(width: double.infinity, child: child);
  }
}

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > 900;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 48),
      child: isWide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: companyStats.map((s) => _StatItem(value: s.$1, label: s.$2)).toList(),
            )
          : Wrap(
              alignment: WrapAlignment.center,
              spacing: 32,
              runSpacing: 24,
              children: companyStats
                  .map((s) => SizedBox(width: 140, child: _StatItem(value: s.$1, label: s.$2)))
                  .toList(),
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
