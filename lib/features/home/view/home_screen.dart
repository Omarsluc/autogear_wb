import 'widgets/catalog_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/auto_part.dart';
import '../../catalog/view/catalog_screen.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import 'widgets/app_header.dart';
import 'widgets/hero_section.dart';
import 'widgets/info_sections.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();

  final _heroKey = GlobalKey();
  final _makesKey = GlobalKey();
  final _systemsKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _contactKey = GlobalKey();

  void _handleNavigation(String section) {
    if (section == 'catalog') {
      _openCatalog();
      return;
    }

    GlobalKey? key;
    switch (section) {
      case 'makes':
        key = _makesKey;
      case 'systems':
        key = _systemsKey;
      case 'about':
        key = _aboutKey;
      case 'contact':
        key = _contactKey;
      default:
        key = _heroKey;
    }

    final targetContext = key.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openCatalog([CatalogFilters? filters]) {
    if (filters != null) {
      context.read<HomeCubit>().updateFilters(filters);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogScreen(initialFilters: filters),
      ),
    );
  }

  void _selectMake(String make) {
    final currentFilters = context.read<HomeCubit>().state.filters;
    final updatedFilters = currentFilters.copyWith(
      make: make,
      clearModel: true,
      clearCategory: true,
    );
    _openCatalog(updatedFilters);
  }

  void _selectSystem(String system, {String? category}) {
    final currentFilters = context.read<HomeCubit>().state.filters;
    final updatedFilters = currentFilters.copyWith(
      system: system,
      category: category,
      clearCategory: category == null,
    );
    _openCatalog(updatedFilters);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 900;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: isMobile ? MobileDrawer(onNavigate: _handleNavigation) : null,
      appBar: AppHeader(
        onNavigate: _handleNavigation,
        isMobile: isMobile,
        drawerKey: _scaffoldKey,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            KeyedSubtree(
              key: _heroKey,
              child: RepaintBoundary(
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    return HeroSection(
                      filters: state.filters,
                      onFiltersChanged: (f) => context.read<HomeCubit>().updateFilters(f),
                      onSearch: () {
                        _openCatalog(state.filters);
                      },
                      resultCount: state.parts.length,
                    );
                  },
                ),
              ),
            ),
            const RepaintBoundary(child: StatsSection()),
            const RepaintBoundary(child: PackagingSection()),
            KeyedSubtree(
              key: _makesKey,
              child: RepaintBoundary(
                child: MakesSection(onMakeSelected: _selectMake),
              ),
            ),
            KeyedSubtree(
              key: _systemsKey,
              child: RepaintBoundary(
                child: SystemsSection(
                  onSystemSelected: _selectSystem,
                  onCategorySelected: (system, category) =>
                      _selectSystem(system, category: category),
                ),
              ),
            ),
            KeyedSubtree(
              key: _aboutKey,
              child: const RepaintBoundary(child: AboutSection()),
            ),
            KeyedSubtree(
              key: _contactKey,
              child: const RepaintBoundary(child: ContactSection()),
            ),
            const RepaintBoundary(child: FooterSection()),
          ],
        ),
      ),
    );
  }
}
