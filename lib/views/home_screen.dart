import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:glitter_launcher/controllers/app_controller.dart';
import 'package:glitter_launcher/controllers/theme_controller.dart';
import 'package:glitter_launcher/widgets/settings_drawer.dart';

import '../widgets/app_grid_item.dart';
import '../widgets/frequent_apps_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final appCtrl = Get.find<AppController>();
  final themeCtrl = Get.find<ThemeController>();
  final ScrollController _scrollController = ScrollController();

  // final ScrollController _gridCtrl = ScrollController(); // Not used in current setup

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: appCtrl.categories.length,
      vsync: this,
    );
    // Listen to tab changes and update selectedCategory in controller
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        appCtrl.selectedCategory.value =
            appCtrl.categories[_tabController.index];
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = themeCtrl.primaryColor.value;
    // Removed appNames for AlphabetScrollbar as it's commented out
    // final appNames = appCtrl.allApps.map((a) => a.appName).toList()..sort();

    return Scaffold(
      drawer: const SettingsDrawer(),
      body: Stack(
        children: [
          // Wallpaper background
          Obx(
            () => appCtrl.wallpaperPath.value.isNotEmpty
                ? Image.file(
                    File(appCtrl.wallpaperPath.value),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary.withOpacity(0.4),
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
          ),

          // Blurred overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 100,
                floating: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  title: const Text(
                    'Glitter Launcher ✨',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black45,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                ),
              ),

              // Search + Filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      // Search bar
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        child: TextField(
                          onChanged: appCtrl.updateSearch,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            hintText: 'Search apps...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),

                      const SizedBox(height: 14),

                      // Category Tabs
                      Obx(
                        () => TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          indicator: BoxDecoration(
                            color: primary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          // The listener in initState handles the onTap logic now
                          tabs: appCtrl.categories
                              .map(
                                (cat) => Text(
                                  cat,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                              .toList(),
                        ).animate().fadeIn(duration: 100.ms).slideY(begin: 0.2),
                      ),
                    ],
                  ),
                ),
              ),

              // Grid or Frequent Section
              SliverFillRemaining(
                child: Obx(() {
                  if (appCtrl.isLoading.value && appCtrl.allApps.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (appCtrl.selectedCategory.value == 'Frequent') {
                    return const FrequentAppsSection();
                  }

                  // Use the pre-filtered and sorted list from the controller
                  final filteredApps = appCtrl.filteredAndSortedApps;

                  if (filteredApps.isEmpty && !appCtrl.isLoading.value) {
                    return Center(
                      child: Text(
                        appCtrl.searchQuery.value.isNotEmpty
                            ? 'No apps found matching "${appCtrl.searchQuery.value}"'
                            : 'No apps in this category.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: MasonryGridView.count(
                      crossAxisCount: appCtrl.gridCount.value,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                      itemCount: filteredApps.length,
                      itemBuilder: (context, index) {
                        final app = filteredApps[index];
                        return AppGridItem(app: app);
                        //.animate()
                        // .fadeIn(delay: (index * 40).ms)
                        // .slideY(begin: 0.2, duration: 100.ms);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),

          // Floating alphabet index - Re-enable and adapt if needed
          /*
          // You would need to make sure _gridCtrl is correctly attached to the MasonryGridView
          // and the MasonryGridView is inside a Scrollable or using a CustomScrollView to integrate it.
          // This also assumes appNames is available and sorted.
          AlphabetScrollbar(
            scrollController: _scrollController, // Or a dedicated scroll controller for the grid
            appNames: appNames, // Make sure appNames is updated correctly with filtered apps
          ),
          */
        ],
      ),
    );
  }
}
