import 'package:flutter/material.dart';
import '../../../../core/data/catalog_repository.dart';
import '../../../../core/models/auto_part.dart';
import '../../../../core/theme/app_theme.dart';

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

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
      ),
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
              child: const Text(
                'Making Hard-To-Find Auto Parts A Thing Of The Past',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Reliable Aftermarket Auto Parts\nfor Your Business Success',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontSize: isWide ? 46 : 32,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: isWide ? 640 : double.infinity,
              child: Text(
                'Browse our comprehensive e-catalog of 40,000+ aftermarket auto parts. '
                'Filter by make, model, year, and system to find exactly what you need.',
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
              '$resultCount parts match your filters',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final models = availableModels(filters.make);
    final categories = availableCategories(filters.system);

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
            decoration: const InputDecoration(
              hintText: 'Search by part name, SKU, or OEM number...',
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
            ),
            onChanged: (value) =>
                onFiltersChanged(filters.copyWith(searchQuery: value)),
            onSubmitted: (_) => onSearch(),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _FilterDropdown(
                label: 'Select Make',
                value: filters.make,
                items: makes,
                width: isWide ? 180 : (width > 500 ? 160 : null),
                onChanged: (v) => onFiltersChanged(
                  filters.copyWith(make: v, clearModel: true, clearCategory: true),
                ),
              ),
              _FilterDropdown(
                label: 'Select Model',
                value: filters.model,
                items: models,
                width: isWide ? 180 : (width > 500 ? 160 : null),
                enabled: filters.make != null,
                onChanged: (v) => onFiltersChanged(filters.copyWith(model: v)),
              ),
              _FilterDropdown<int>(
                label: 'Select Year',
                value: filters.year,
                items: years,
                width: isWide ? 140 : (width > 500 ? 120 : null),
                itemLabel: (y) => y.toString(),
                onChanged: (v) => onFiltersChanged(filters.copyWith(year: v)),
              ),
              _FilterDropdown(
                label: 'Select System',
                value: filters.system,
                items: systems,
                width: isWide ? 220 : (width > 500 ? 200 : null),
                onChanged: (v) => onFiltersChanged(
                  filters.copyWith(system: v, clearCategory: true),
                ),
              ),
              _FilterDropdown(
                label: 'Select Part',
                value: filters.category,
                items: categories,
                width: isWide ? 200 : (width > 500 ? 180 : null),
                enabled: filters.system != null,
                onChanged: (v) => onFiltersChanged(filters.copyWith(category: v)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.filter_list),
                label: const Text('Apply Filters'),
              ),
              if (filters.hasActiveFilters)
                OutlinedButton.icon(
                  onPressed: () => onFiltersChanged(const CatalogFilters()),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear All'),
                ),
            ],
          ),
        ],
      ),
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
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      hint: Text(label, style: const TextStyle(fontSize: 14)),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                itemLabel != null ? itemLabel!(item) : item.toString(),
                overflow: TextOverflow.ellipsis,
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
