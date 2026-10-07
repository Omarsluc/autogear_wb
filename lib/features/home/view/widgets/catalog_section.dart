import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/catalog_repository.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/models/auto_part.dart';
import '../../../../core/models/cart_item.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cart/cubit/cart_cubit.dart';
import '../../../cart/cubit/cart_state.dart';
import '../../../cart/view/cart_screen.dart';

class CatalogSection extends StatelessWidget {
  const CatalogSection({
    super.key,
    required this.parts,
    required this.filters,
    required this.onFiltersChanged,
    this.isLoading = false,
    this.showHeader = true,
    this.currentPage,
    this.totalPages,
    this.startIndex,
    this.endIndex,
    this.totalItems,
    this.onPageChanged,
  });

  final List<AutoPart> parts;
  final CatalogFilters filters;
  final ValueChanged<CatalogFilters> onFiltersChanged;
  final bool isLoading;
  final bool showHeader;
  final int? currentPage;
  final int? totalPages;
  final int? startIndex;
  final int? endIndex;
  final int? totalItems;
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width > 1200 ? 3 : (width > 700 ? 2 : 1);

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: width > 900 ? 64 : 24,
        vertical: showHeader ? 64 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
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
                Text(
                  AppStrings.tr(context, 'parts_catalog'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.tr(context, 'browse_count').replaceAll(
                '{count}',
                (totalItems ?? parts.length).toString(),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          if (filters.hasActiveFilters) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (filters.make != null)
                  CatalogFilterChip(
                    label: 'Make: ${filters.make}',
                    onRemove: () =>
                        onFiltersChanged(filters.copyWith(clearMake: true, clearModel: true)),
                  ),
                if (filters.model != null)
                  CatalogFilterChip(
                    label: 'Model: ${filters.model}',
                    onRemove: () => onFiltersChanged(filters.copyWith(clearModel: true)),
                  ),
                if (filters.year != null)
                  CatalogFilterChip(
                    label: 'Year: ${filters.year}',
                    onRemove: () => onFiltersChanged(filters.copyWith(clearYear: true)),
                  ),
                if (filters.system != null)
                  CatalogFilterChip(
                    label: 'System: ${filters.system}',
                    onRemove: () => onFiltersChanged(
                      filters.copyWith(clearSystem: true, clearCategory: true),
                    ),
                  ),
                if (filters.category != null)
                  CatalogFilterChip(
                    label: 'Part: ${filters.category}',
                    onRemove: () => onFiltersChanged(filters.copyWith(clearCategory: true)),
                  ),
                if (filters.searchQuery.isNotEmpty)
                  CatalogFilterChip(
                    label: 'Search: "${filters.searchQuery}"',
                    onRemove: () => onFiltersChanged(filters.copyWith(searchQuery: '')),
                  ),
                ActionChip(
                  label: Text(
                    AppStrings.tr(context, 'clear_all'),
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  backgroundColor: Colors.red.shade50,
                  onPressed: () => onFiltersChanged(const CatalogFilters()),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(64),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (parts.isEmpty)
            CatalogEmptyState(onClear: () => onFiltersChanged(const CatalogFilters()))
          else ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: width > 1200 ? 0.84 : (width > 700 ? 0.76 : 0.72),
              ),
              itemCount: parts.length,
              itemBuilder: (context, index) => PartCard(part: parts[index]),
            ),
            if (currentPage != null && totalPages != null && onPageChanged != null) ...[
              const SizedBox(height: 40),
              CatalogPaginationBar(
                currentPage: currentPage!,
                totalPages: totalPages!,
                startIndex: startIndex ?? 1,
                endIndex: endIndex ?? parts.length,
                totalItems: totalItems ?? parts.length,
                onPageChanged: onPageChanged!,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class CatalogFilterChip extends StatelessWidget {
  const CatalogFilterChip({super.key, required this.label, required this.onRemove});

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

class CatalogEmptyState extends StatelessWidget {
  const CatalogEmptyState({super.key, required this.onClear});

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

class CatalogPaginationBar extends StatelessWidget {
  const CatalogPaginationBar({
    super.key,
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

class PartCard extends StatefulWidget {
  const PartCard({super.key, required this.part});

  final AutoPart part;

  @override
  State<PartCard> createState() => _PartCardState();
}

class _PartCardState extends State<PartCard> {
  int _quantity = 1;

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

  void _addToCart(BuildContext context, AutoPart part, int quantity) {
    context.read<CartCubit>().addPart(part, quantity: quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$quantity x ${part.name} added to cart'),
        duration: const Duration(seconds: 2),
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
              PartInfoRow(label: 'SKU', value: part.sku),
              // PartInfoRow(label: 'OEM Number', value: part.oemNumber),
              PartInfoRow(label: 'Make', value: part.make),
              PartInfoRow(label: 'Model', value: part.model),
              PartInfoRow(label: 'Years', value: part.years.join(', ')),
              PartInfoRow(label: 'System', value: part.system),
              PartInfoRow(label: 'Category', value: part.category),
              const SizedBox(height: 10),
              _buildPriceSection(context, part),
              const SizedBox(height: 10),
              if (part.country != null && part.country!.isNotEmpty)
                PartInfoRow(label: 'Country', value: part.country!),
              if (part.englishNotes != null && part.englishNotes!.isNotEmpty)
                PartInfoRow(label: 'Notes (EN)', value: part.englishNotes!),
              if (part.compatNotesAr != null && part.compatNotesAr!.isNotEmpty)
                PartInfoRow(label: 'مناسب لموديلات', value: part.compatNotesAr!),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          if (part.inStock)
            ElevatedButton.icon(
              onPressed: () {
                _addToCart(context, part, _quantity);
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: Text('Add $_quantity to cart'),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context, AutoPart part) {
    final hasWholesale = part.wholesalePrice != null && part.wholesalePrice! > 0;
    final hasRetail = part.retailPrice != null && part.retailPrice! > 0;
    final displayPrice = hasWholesale ? part.wholesalePrice! : (hasRetail ? part.retailPrice! : null);

    if (displayPrice == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.lightBlue.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.request_quote_outlined, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Price on Request',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'QUOTE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // int? discountPercent;
    // if (hasRetail && hasWholesale && part.retailPrice! > part.wholesalePrice!) {
    //   discountPercent = (((part.retailPrice! - part.wholesalePrice!) / part.retailPrice!) * 100).round();
    // }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.lightBlue.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hasWholesale ? 'WHOLESALE PRICE' : 'PRICE',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'EGP ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                displayPrice.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final part = widget.part;
    final inStockLabel = AppStrings.tr(context, 'in_stock');
    final outStockLabel = AppStrings.tr(context, 'out_of_stock');
    final skuLabel = AppStrings.tr(context, 'sku');
    final vehicleLabel = AppStrings.tr(context, 'vehicle');
    final yearsLabel = AppStrings.tr(context, 'years');
    final addToCartLabel = AppStrings.tr(context, 'add_to_cart');

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        CartItem? cartItem;
        for (final item in cartState.items) {
          if (item.part.id == part.id) {
            cartItem = item;
            break;
          }
        }
        final isInCart = cartItem != null;
        final displayQuantity = isInCart ? cartItem.quantity : _quantity;

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
                      if (part.pictureUrl != null && part.pictureUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            part.pictureUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.lightBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_iconForSystem(part.system), color: AppColors.primary, size: 24),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_iconForSystem(part.system), color: AppColors.primary, size: 28),
                        ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
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
                          if (part.wholesalePrice != null || part.retailPrice != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                              ),
                              child: Text(
                                'EGP ${(part.wholesalePrice ?? part.retailPrice!).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
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
                  const SizedBox(height: 6),
                  Text(part.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  _buildPriceSection(context, part),
                  const Spacer(),
                  const Divider(height: 20),
                  PartInfoRow(label: skuLabel, value: part.sku),
                  if (part.oemNumber.isNotEmpty)
                    // PartInfoRow(label: oemLabel, value: part.oemNumber),
                  PartInfoRow(label: vehicleLabel, value: '${part.make} ${part.model}'),
                  PartInfoRow(
                    label: yearsLabel,
                    value: part.years.isNotEmpty ? '${part.years.first}–${part.years.last}' : 'N/A',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        height: 38,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                              onPressed: !part.inStock
                                  ? null
                                  : () {
                                      if (isInCart) {
                                        context.read<CartCubit>().updateQuantity(
                                              part,
                                              cartItem!.quantity - 1,
                                            );
                                      } else {
                                        if (_quantity > 1) {
                                          setState(() => _quantity--);
                                        }
                                      }
                                    },
                              icon: const Icon(Icons.remove, size: 16),
                              tooltip: 'Decrease quantity',
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              alignment: Alignment.center,
                              child: Text(
                                '$displayQuantity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                              onPressed: !part.inStock
                                  ? null
                                  : () {
                                      if (isInCart) {
                                        context.read<CartCubit>().updateQuantity(
                                              part,
                                              cartItem!.quantity + 1,
                                            );
                                      } else {
                                        setState(() => _quantity++);
                                      }
                                    },
                              icon: const Icon(Icons.add, size: 16),
                              tooltip: 'Increase quantity',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: part.inStock
                              ? () {
                                  if (isInCart) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const CartScreen()),
                                    );
                                  } else {
                                    _addToCart(context, part, _quantity);
                                  }
                                }
                              : null,
                          icon: Icon(
                            isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                            size: 18,
                          ),
                          label: Text(
                            isInCart ? 'In Cart (${cartItem.quantity})' : addToCartLabel,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            backgroundColor: isInCart ? AppColors.lightBlue : null,
                          ),
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
      },
    );
  }
}

class PartInfoRow extends StatelessWidget {
  const PartInfoRow({super.key, required this.label, required this.value});

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
