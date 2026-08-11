import 'package:flutter/material.dart';
import '../data/catalog_data.dart';
import '../models/auto_part.dart';
import '../widgets/app_header.dart';
import '../widgets/catalog_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/info_sections.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();

  final _heroKey = GlobalKey();
  final _catalogKey = GlobalKey();
  final _makesKey = GlobalKey();
  final _systemsKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _contactKey = GlobalKey();

  CatalogFilters _filters = const CatalogFilters();
  List<AutoPart> _filteredParts = catalogParts;

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredParts = filterParts(_filters);
    });
  }

  void _scrollToSection(String section) {
    GlobalKey? key;
    switch (section) {
      case 'catalog':
        key = _catalogKey;
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

    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectMake(String make) {
    setState(() {
      _filters = _filters.copyWith(make: make, clearModel: true);
    });
    _applyFilters();
    _scrollToSection('catalog');
  }

  void _selectSystem(String system, {String? category}) {
    setState(() {
      _filters = _filters.copyWith(
        system: system,
        category: category,
        clearCategory: category == null,
      );
    });
    _applyFilters();
    _scrollToSection('catalog');
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
      endDrawer: isMobile ? MobileDrawer(onNavigate: _scrollToSection) : null,
      appBar: AppHeader(
        onNavigate: _scrollToSection,
        isMobile: isMobile,
        drawerKey: _scaffoldKey,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            KeyedSubtree(
              key: _heroKey,
              child: HeroSection(
                filters: _filters,
                onFiltersChanged: (f) {
                  setState(() => _filters = f);
                  _applyFilters();
                },
                onSearch: () {
                  _applyFilters();
                  _scrollToSection('catalog');
                },
                resultCount: _filteredParts.length,
              ),
            ),
            const StatsSection(),
            KeyedSubtree(
              key: _catalogKey,
              child: CatalogSection(
                parts: _filteredParts,
                filters: _filters,
                onFiltersChanged: (f) {
                  setState(() => _filters = f);
                  _applyFilters();
                },
              ),
            ),
            KeyedSubtree(
              key: _makesKey,
              child: MakesSection(onMakeSelected: _selectMake),
            ),
            KeyedSubtree(
              key: _systemsKey,
              child: SystemsSection(
                onSystemSelected: _selectSystem,
                onCategorySelected: (system, category) =>
                    _selectSystem(system, category: category),
              ),
            ),
            KeyedSubtree(
              key: _aboutKey,
              child: const AboutSection(),
            ),
            KeyedSubtree(
              key: _contactKey,
              child: const ContactSection(),
            ),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}
