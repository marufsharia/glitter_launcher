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
  final ScrollController _gridCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: appCtrl.categories.length,
      vsync: this,
    );
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
    final appNames = appCtrl.allApps.map((a) => a.appName).toList()..sort();
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
                      TabBar(
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
                        onTap: (i) => appCtrl.selectedCategory.value =
                            appCtrl.categories[i],
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
                    ],
                  ),
                ),
              ),

              // Grid or Frequent Section
              SliverFillRemaining(
                child: Obx(() {
                  if (appCtrl.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (appCtrl.selectedCategory.value == 'Frequent') {
                    return const FrequentAppsSection();
                  }

                  final filteredApps = appCtrl.getFilteredApps();
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
                        return AppGridItem(app: app)
                            .animate()
                            .fadeIn(delay: (index * 40).ms)
                            .slideY(begin: 0.2, duration: 400.ms);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),

          // Floating alphabet index
          /*   Stack(
            children: [
              GridView.builder(
                controller: _gridCtrl,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: appCtrl.allApps.length,
                itemBuilder: (context, index) =>
                    AppGridItem(app: appCtrl.allApps[index]),
              ),
              AlphabetScrollbar(
                scrollController: _gridCtrl,
                appNames: appNames,
              ),
            ],
          ),*/
        ],
      ),
    );
  }
}
