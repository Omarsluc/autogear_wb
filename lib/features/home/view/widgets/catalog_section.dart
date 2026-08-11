import 'package:flutter/material.dart';
import '../../../../core/data/catalog_repository.dart';
import '../../../../core/models/auto_part.dart';
import '../../../../core/theme/app_theme.dart';

class CatalogSection extends StatelessWidget {
  const CatalogSection({
    super.key,
    required this.parts,
    required this.filters,
    required this.onFiltersChanged,
  });

  final List<AutoPart> parts;
  final CatalogFilters filters;
  final ValueChanged<CatalogFilters> onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width > 1200 ? 3 : (width > 700 ? 2 : 1);

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: width > 900 ? 64 : 24, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text('Parts Catalog', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Browse ${parts.length} auto parts matching your criteria',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (filters.hasActiveFilters) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (filters.make != null)
                  _FilterChip(
                    label: 'Make: ${filters.make}',
                    onRemove: () => onFiltersChanged(filters.copyWith(clearMake: true, clearModel: true)),
                  ),
                if (filters.model != null)
                  _FilterChip(
                    label: 'Model: ${filters.model}',
                    onRemove: () => onFiltersChanged(filters.copyWith(clearModel: true)),
                  ),
                if (filters.year != null)
                  _FilterChip(
                    label: 'Year: ${filters.year}',
                    onRemove: () => onFiltersChanged(filters.copyWith(clearYear: true)),
                  ),
                if (filters.system != null)
                  _FilterChip(
                    label: 'System: ${filters.system}',
                    onRemove: () =>
                        onFiltersChanged(filters.copyWith(clearSystem: true, clearCategory: true)),
                  ),
                if (filters.category != null)
                  _FilterChip(
                    label: 'Part: ${filters.category}',
                    onRemove: () => onFiltersChanged(filters.copyWith(clearCategory: true)),
                  ),
                if (filters.searchQuery.isNotEmpty)
                  _FilterChip(
                    label: 'Search: "${filters.searchQuery}"',
                    onRemove: () => onFiltersChanged(filters.copyWith(searchQuery: '')),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          if (parts.isEmpty)
            _EmptyState(onClear: () => onFiltersChanged(const CatalogFilters()))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: width > 1200 ? 0.95 : (width > 700 ? 0.88 : 0.82),
              ),
              itemCount: parts.length,
              itemBuilder: (context, index) => _PartCard(part: parts[index]),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppColors.lightBlue,
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No parts found', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters or search terms to find what you need.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: onClear, child: const Text('Clear All Filters')),
        ],
      ),
    );
  }
}

class _PartCard extends StatelessWidget {
  const _PartCard({required this.part});

  final AutoPart part;

  IconData _iconForSystem(String system) {
    switch (system) {
      case 'Engine System':
        return Icons.settings;
      case 'Electrical System':
        return Icons.electric_bolt;
      case 'Braking System':
        return Icons.disc_full;
      case 'Suspension & Steering System':
        return Icons.tire_repair;
      case 'Cooling System':
        return Icons.ac_unit;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showPartDetail(context, part),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_iconForSystem(part.system), color: AppColors.primary, size: 28),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: part.inStock ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      part.inStock ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: part.inStock ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                part.name,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(part.description, maxLines: 2, overflow: TextOverflow.ellipsis),
              const Spacer(),
              const Divider(height: 24),
              _InfoRow(label: 'SKU', value: part.sku),
              _InfoRow(label: 'OEM', value: part.oemNumber),
              _InfoRow(label: 'Vehicle', value: '${part.make} ${part.model}'),
              _InfoRow(
                label: 'Years',
                value: '${part.years.first}–${part.years.last}',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      part.system,
                      style: const TextStyle(fontSize: 11, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    part.category,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPartDetail(BuildContext context, AutoPart part) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(part.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(part.description),
              const SizedBox(height: 16),
              _InfoRow(label: 'SKU', value: part.sku),
              _InfoRow(label: 'OEM Number', value: part.oemNumber),
              _InfoRow(label: 'Make', value: part.make),
              _InfoRow(label: 'Model', value: part.model),
              _InfoRow(label: 'Years', value: part.years.join(', ')),
              _InfoRow(label: 'System', value: part.system),
              _InfoRow(label: 'Category', value: part.category),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Request Quote'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class MakesSection extends StatelessWidget {
  const MakesSection({super.key, required this.onMakeSelected});

  final ValueChanged<String> onMakeSelected;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: width > 900 ? 64 : 24, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Featured Makes', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Auto Gear provides parts for a wide range of prominent car manufacturers.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: makes.map((make) {
              return InkWell(
                onTap: () => onMakeSelected(make),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_car, size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
                      const SizedBox(width: 8),
                      Text(
                        make,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SystemsSection extends StatelessWidget {
  const SystemsSection({
    super.key,
    required this.onSystemSelected,
    required this.onCategorySelected,
  });

  final ValueChanged<String> onSystemSelected;
  final void Function(String system, String category) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: width > 900 ? 64 : 24, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Browse By System', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Find the exact auto parts you require across all major vehicle systems.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth > 900
                  ? (constraints.maxWidth - 48) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: systems.map((system) {
                  final categories = categoriesBySystem[system] ?? [];
                  return SizedBox(
                    width: cardWidth > 400 ? (constraints.maxWidth - 32) / 2 : cardWidth,
                    child: _SystemCard(
                      system: system,
                      categories: categories,
                      onTap: () => onSystemSelected(system),
                      onCategoryTap: (cat) => onCategorySelected(system, cat),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  const _SystemCard({
    required this.system,
    required this.categories,
    required this.onTap,
    required this.onCategoryTap,
  });

  final String system;
  final List<String> categories;
  final VoidCallback onTap;
  final ValueChanged<String> onCategoryTap;

  IconData get _icon {
    switch (system) {
      case 'Engine System':
        return Icons.settings;
      case 'Electrical System':
        return Icons.electric_bolt;
      case 'Braking System':
        return Icons.disc_full;
      case 'Suspension & Steering System':
        return Icons.tire_repair;
      case 'Cooling System':
        return Icons.ac_unit;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_icon, color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(system, style: Theme.of(context).textTheme.titleLarge),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: categories.take(6).map((cat) {
                  return ActionChip(
                    label: Text(cat, style: const TextStyle(fontSize: 11)),
                    backgroundColor: AppColors.lightBlue,
                    onPressed: () => onCategoryTap(cat),
                  );
                }).toList(),
              ),
              if (categories.length > 6)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${categories.length - 6} more parts',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
