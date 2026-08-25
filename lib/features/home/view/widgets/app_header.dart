import '../../../../core/localization/app_strings.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../auth/view/auth_screen.dart';
import '../../../cart/cubit/cart_cubit.dart';
import '../../../cart/cubit/cart_state.dart';
import '../../../cart/view/cart_screen.dart';
import '../../../orders/view/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.onNavigate,
    this.isMobile = false,
    this.drawerKey,
  });

  final void Function(String section) onNavigate;
  final bool isMobile;
  final GlobalKey<ScaffoldState>? drawerKey;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  void _openCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  void _openAuth(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  void _openOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrdersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 72,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.tr(context, 'app_title'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              Text(
                AppStrings.tr(context, 'app_subtitle'),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        BlocSelector<LocaleCubit, Locale, bool>(
          selector: (state) => state.languageCode == 'ar',
          builder: (context, isAr) {
            return TextButton.icon(
              onPressed: () => context.read<LocaleCubit>().toggleLocale(),
              icon: const Icon(Icons.language, color: Colors.white, size: 20),
              label: Text(
                isAr ? 'English' : 'العربية',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
        BlocSelector<CartCubit, CartState, int>(
          selector: (state) => state.itemCount,
          builder: (context, itemCount) {
            return IconButton(
              tooltip: AppStrings.tr(context, 'cart'),
              onPressed: () => _openCart(context),
              icon: Badge(
                isLabelVisible: itemCount > 0,
                label: Text('$itemCount'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            );
          },
        ),
        BlocBuilder<AuthCubit, AppAuthState>(
          builder: (context, authState) {
            if (authState.isAuthenticated) {
              return PopupMenuButton<String>(
                tooltip: 'Account',
                icon: const Icon(Icons.account_circle_outlined),
                onSelected: (value) {
                  if (value == 'signout') {
                    context.read<AuthCubit>().signOut();
                  } else if (value == 'orders') {
                    _openOrders(context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(
                      authState.displayName ?? 'Account',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'orders',
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long, size: 18),
                        const SizedBox(width: 8),
                        Text(AppStrings.tr(context, 'my_orders')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'signout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, size: 18),
                        const SizedBox(width: 8),
                        Text(AppStrings.tr(context, 'sign_out')),
                      ],
                    ),
                  ),
                ],
              );
            }
            return IconButton(
              tooltip: AppStrings.tr(context, 'sign_in'),
              onPressed: () => _openAuth(context),
              icon: const Icon(Icons.login),
            );
          },
        ),
        if (isMobile)
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => drawerKey?.currentState?.openEndDrawer(),
          )
        else ...[
          _NavButton(
            label: AppStrings.tr(context, 'nav_catalog'),
            onTap: () => onNavigate('catalog'),
          ),
          _NavButton(
            label: AppStrings.tr(context, 'nav_makes'),
            onTap: () => onNavigate('makes'),
          ),
          _NavButton(
            label: AppStrings.tr(context, 'nav_systems'),
            onTap: () => onNavigate('systems'),
          ),
          _NavButton(
            label: AppStrings.tr(context, 'nav_about'),
            onTap: () => onNavigate('about'),
          ),
          _NavButton(
            label: AppStrings.tr(context, 'nav_contact'),
            onTap: () => onNavigate('contact'),
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: ElevatedButton.icon(
              onPressed: () => onNavigate('catalog'),
              icon: const Icon(Icons.search, size: 18),
              label: Text(AppStrings.tr(context, 'browse_parts')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class MobileDrawer extends StatelessWidget {
  const MobileDrawer({super.key, required this.onNavigate});

  final void Function(String section) onNavigate;

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LocaleCubit>().isArabic;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.settings, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text(
                  AppStrings.tr(context, 'app_title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  AppStrings.tr(context, 'app_subtitle'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primary),
            title: Text(isAr ? 'English' : 'العربية'),
            onTap: () => context.read<LocaleCubit>().toggleLocale(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.chevron_right, color: AppColors.primary),
            title: Text(AppStrings.tr(context, 'nav_catalog')),
            onTap: () {
              Navigator.pop(context);
              onNavigate('catalog');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chevron_right, color: AppColors.primary),
            title: Text(AppStrings.tr(context, 'nav_makes')),
            onTap: () {
              Navigator.pop(context);
              onNavigate('makes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chevron_right, color: AppColors.primary),
            title: Text(AppStrings.tr(context, 'nav_systems')),
            onTap: () {
              Navigator.pop(context);
              onNavigate('systems');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chevron_right, color: AppColors.primary),
            title: Text(AppStrings.tr(context, 'nav_about')),
            onTap: () {
              Navigator.pop(context);
              onNavigate('about');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chevron_right, color: AppColors.primary),
            title: Text(AppStrings.tr(context, 'nav_contact')),
            onTap: () {
              Navigator.pop(context);
              onNavigate('contact');
            },
          ),
        ],
      ),
    );
  }
}
