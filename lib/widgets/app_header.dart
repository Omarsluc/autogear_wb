import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
              const Text(
                'AUTO GEAR',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              Text(
                'Aftermarket Auto Parts Catalog',
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
        if (isMobile)
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => drawerKey?.currentState?.openEndDrawer(),
          )
        else
          ...[
            _NavButton(label: 'Catalog', onTap: () => onNavigate('catalog')),
            _NavButton(label: 'Makes', onTap: () => onNavigate('makes')),
            _NavButton(label: 'Systems', onTap: () => onNavigate('systems')),
            _NavButton(label: 'About', onTap: () => onNavigate('about')),
            _NavButton(label: 'Contact', onTap: () => onNavigate('contact')),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: ElevatedButton.icon(
                onPressed: () => onNavigate('catalog'),
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Browse Parts'),
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
                const Text(
                  'AUTO GEAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Auto Parts E-Catalog',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          for (final item in ['Catalog', 'Makes', 'Systems', 'About', 'Contact'])
            ListTile(
              leading: const Icon(Icons.chevron_right, color: AppColors.primary),
              title: Text(item),
              onTap: () {
                Navigator.pop(context);
                onNavigate(item.toLowerCase());
              },
            ),
        ],
      ),
    );
  }
}
