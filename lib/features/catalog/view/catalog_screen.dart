import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/catalog_repository.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/models/auto_part.dart';
import '../../../../core/theme/app_theme.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/view/cart_screen.dart';
import '../../home/cubit/home_cubit.dart';
import '../../home/cubit/home_state.dart';
import '../../home/view/widgets/app_header.dart';
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

          final crossAxisCount = width > 1200 ? 3 : (width > 700 ? 2 : 1);

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
                          _FilterChip(
                            label: 'Make: ${filters.make}',
                            onRemove: () => _onFilterChanged(
                              filters.copyWith(clearMake: true, clearModel: true),
                            ),
                          ),
                        if (filters.model != null)
                          _FilterChip(
                            label: 'Model: ${filters.model}',
                            onRemove: () => _onFilterChanged(
                              filters.copyWith(clearModel: true),
                            ),
                          ),
                        if (filters.year != null)
                          _FilterChip(
                            label: 'Year: ${filters.year}',
                            onRemove: () => _onFilterChanged(
                              filters.copyWith(clearYear: true),
                            ),
                          ),
                        if (filters.system != null)
                          _FilterChip(
                            label: 'System: ${filters.system}',
                            onRemove: () => _onFilterChanged(
                              filters.copyWith(clearSystem: true, clearCategory: true),
                            ),
                          ),
                        if (filters.category != null)
                          _FilterChip(
                            label: 'Part: ${filters.category}',
                            onRemove: () => _onFilterChanged(
                              filters.copyWith(clearCategory: true),
                            ),
                          ),
                        if (filters.searchQuery.isNotEmpty)
                          _FilterChip(
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

                // Parts Grid Section
                RepaintBoundary(
                  child: Container(
                    color: AppColors.background,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 24 : 64,
                      vertical: 32,
                    ),
                    child: parts.isEmpty
                        ? _EmptyState(
                            onClear: () => _onFilterChanged(const CatalogFilters()),
                          )
                        : Column(
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: width > 1200 ? 0.92 : (width > 700 ? 0.85 : 0.80),
                                ),
                                itemCount: paginatedParts.length,
                                itemBuilder: (context, index) =>
                                    _PartCard(part: paginatedParts[index]),
                              ),

                              const SizedBox(height: 40),

                              // Pagination Control Bar
                              _PaginationBar(
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
                            ],
                          ),
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
    final models = availableModels(widget.filters.make);
    final categories = availableCategories(widget.filters.system);

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
              items: makes,
              width: widget.isWide ? 180 : (width > 500 ? 160 : null),
              onChanged: (v) => widget.onFiltersChanged(
                widget.filters.copyWith(make: v, clearModel: true, clearCategory: true),
              ),
            ),
            _FilterDropdown(
              label: AppStrings.tr(context, 'select_model'),
              value: widget.filters.model,
              items: models,
              width: widget.isWide ? 180 : (width > 500 ? 160 : null),
              enabled: widget.filters.make != null,
              onChanged: (v) => widget.onFiltersChanged(widget.filters.copyWith(model: v)),
            ),
            _FilterDropdown<int>(
              label: AppStrings.tr(context, 'select_year'),
              value: widget.filters.year,
              items: years,
              width: widget.isWide ? 140 : (width > 500 ? 120 : null),
              itemLabel: (y) => y.toString(),
              onChanged: (v) => widget.onFiltersChanged(widget.filters.copyWith(year: v)),
            ),
            _FilterDropdown(
              label: AppStrings.tr(context, 'select_system'),
              value: widget.filters.system,
              items: systems,
              width: widget.isWide ? 200 : (width > 500 ? 180 : null),
              onChanged: (v) => widget.onFiltersChanged(
                widget.filters.copyWith(system: v, clearCategory: true),
              ),
            ),
            _FilterDropdown(
              label: AppStrings.tr(context, 'select_part'),
              value: widget.filters.category,
              items: categories,
              width: widget.isWide ? 200 : (width > 500 ? 180 : null),
              enabled: widget.filters.system != null,
              onChanged: (v) => widget.onFiltersChanged(widget.filters.copyWith(category: v)),
            ),
          ],
        ),
      ],
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

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.startIndex,
    required this.endIndex,
    required this.totalItems,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int startIndex;
  final int endIndex;
  final int totalItems;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $startIndex–$endIndex of $totalItems parts',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (isMobile) const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
                icon: const Icon(Icons.chevron_left, size: 18),
                label: const Text('Prev'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              for (int i = 1; i <= totalPages; i++) ...[
                if (totalPages <= 7 ||
                    i == 1 ||
                    i == totalPages ||
                    (i >= currentPage - 1 && i <= currentPage + 1))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ElevatedButton(
                      onPressed: () => onPageChanged(i),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            i == currentPage ? AppColors.primary : Colors.grey.shade100,
                        foregroundColor:
                            i == currentPage ? Colors.white : AppColors.textPrimary,
                        elevation: i == currentPage ? 2 : 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(36, 36),
                      ),
                      child: Text('$i', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                else if (i == currentPage - 2 || i == currentPage + 2)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('...', style: TextStyle(color: AppColors.textSecondary)),
                  ),
              ],
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
                icon: const Icon(Icons.chevron_right, size: 18),
                label: const Text('Next'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
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
          Text(AppStrings.tr(context, 'no_parts_found'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            AppStrings.tr(context, 'no_parts_sub'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: onClear, child: Text(AppStrings.tr(context, 'clear_all'))),
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
    final inStockLabel = AppStrings.tr(context, 'in_stock');
    final outStockLabel = AppStrings.tr(context, 'out_of_stock');
    final skuLabel = AppStrings.tr(context, 'sku');
    final oemLabel = AppStrings.tr(context, 'oem');
    final vehicleLabel = AppStrings.tr(context, 'vehicle');
    final yearsLabel = AppStrings.tr(context, 'years');
    final addToCartLabel = AppStrings.tr(context, 'add_to_cart');

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
                      part.inStock ? inStockLabel : outStockLabel,
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
              _InfoRow(label: skuLabel, value: part.sku),
              _InfoRow(label: oemLabel, value: part.oemNumber),
              _InfoRow(label: vehicleLabel, value: '${part.make} ${part.model}'),
              _InfoRow(
                label: yearsLabel,
                value: part.years.isNotEmpty ? '${part.years.first}–${part.years.last}' : 'N/A',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: part.inStock ? () => _addToCart(context, part) : null,
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: Text(addToCartLabel),
                    ),
                  ),
                ],
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

  void _addToCart(BuildContext context, AutoPart part) {
    context.read<CartCubit>().addPart(part);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${part.name} added to cart'),
        action: SnackBarAction(
          label: 'View cart',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
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
          if (part.inStock)
            ElevatedButton.icon(
              onPressed: () {
                _addToCart(context, part);
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('Add to cart'),
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
