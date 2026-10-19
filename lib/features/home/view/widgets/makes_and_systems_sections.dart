import 'package:flutter/material.dart';

import '../../../../core/data/catalog_repository.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';

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
          Text(AppStrings.tr(context, 'featured_makes'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            AppStrings.tr(context, 'makes_sub'),
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
                        AppStrings.translateFilter(context, make, 'make'),
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
    this.systemsList,
  });

  final ValueChanged<String> onSystemSelected;
  final void Function(String system, String category) onCategorySelected;
  final List<String>? systemsList;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final itemsToDisplay = (systemsList != null && systemsList!.isNotEmpty) ? systemsList! : systems;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: width > 900 ? 64 : 24, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.tr(context, 'browse_by_system'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            AppStrings.tr(context, 'systems_sub'),
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
                children: itemsToDisplay.map((system) {
                  List<String> categories = categoriesBySystem[system] ?? [];
                  if (categories.isEmpty) {
                    final sysLower = system.toLowerCase();
                    for (final entry in categoriesBySystem.entries) {
                      if (sysLower.contains(entry.key.toLowerCase().replaceAll(' system', ''))) {
                        categories = entry.value;
                        break;
                      }
                    }
                  }

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
    final s = system.toLowerCase();
    if (s.contains('engine')) return Icons.settings;
    if (s.contains('electric')) return Icons.electric_bolt;
    if (s.contains('brak')) return Icons.disc_full;
    if (s.contains('suspension')) return Icons.tire_repair;
    if (s.contains('cool')) return Icons.ac_unit;
    if (s.contains('ignit')) return Icons.local_fire_department;
    if (s.contains('exhaust')) return Icons.air;
    return Icons.build;
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
                    child: Text(
                      AppStrings.translateFilter(context, system, 'system'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: categories.take(6).map((cat) {
                  return ActionChip(
                    label: Text(
                      AppStrings.translateFilter(context, cat, 'item_type'),
                      style: const TextStyle(fontSize: 11),
                    ),
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
