import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glitter_launcher/database/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

class AppController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  var allApps = <App>[].obs;

  // ✅ FIXED: Proper persistent RxList (was getter returning new instance!)
  final RxList<App> filteredAndSortedApps = <App>[].obs;

  // In-memory cache for app icons
  final Map<String, ImageProvider> _appIconCache = {};

  var categories = <String>[
    'All',
    'Frequent',
    'Games',
    'Social',
    'Productivity',
    'Uncategorized',
  ].obs;
  var selectedCategory = 'All'.obs;
  var gridCount = 4.obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;
  var sortBy = 'Name'.obs;
  var wallpaperPath = ''.obs;

  // Debouncer for search input
  final _searchDebouncer = Debouncer(milliseconds: 300);

  @override
  void onInit() {
    super.onInit();
    _requestPermissions();
    _loadWallpaperPath();

    // ✅ Listen to DB stream for automatic allApps updates
    db.getAllAppsStream().listen((data) {
      allApps.assignAll(data);
      _appIconCache.clear(); // Clear icon cache on full reload
      _applyFiltersAndSort();
    });

    loadInstalledApps(); // Initial load
  }

  @override
  void onReady() {
    super.onReady();
    // ✅ React to changes in dependencies
    everAll([allApps, selectedCategory, searchQuery, sortBy], (_) {
      _applyFiltersAndSort();
    });
  }

  // --- ICON CACHING ---
  ImageProvider getAppIcon(
    String packageName,
    Uint8List? iconBytes,
    String? customIconPath,
  ) {
    if (_appIconCache.containsKey(packageName)) {
      return _appIconCache[packageName]!;
    }

    ImageProvider imageProvider;
    if (customIconPath?.isNotEmpty ?? false) {
      imageProvider = FileImage(File(customIconPath!));
    } else if (iconBytes != null && iconBytes.isNotEmpty) {
      imageProvider = MemoryImage(iconBytes);
    } else {
      imageProvider = const AssetImage('assets/default_app_icon.png');
    }
    _appIconCache[packageName] = imageProvider;
    return imageProvider;
  }

  void clearAppIconCache(String packageName) {
    _appIconCache.remove(packageName);
  }

  // --- APP LOADING & SYNC ---
  Future<void> loadInstalledApps() async {
    if (!isLoading.value) isLoading.value = true;
    try {
      final installedApps =
          await InstalledApps.getInstalledApps(
            excludeNonLaunchableApps: true,
            excludeSystemApps: true,
            withIcon: true,
            platformType: PlatformType.nativeOrOthers,
          ).catchError((error, stack) {
            print("❌ InstalledApps error: $error");
            return <AppInfo>[];
          });

      final existingDbApps = await db.getAllApps();
      final existingDbMap = {
        for (var app in existingDbApps) app.packageName: app,
      };
      final packageNamesFromPackageManager = installedApps
          .map((e) => e.packageName)
          .toSet();

      final appsToInsert = <AppsCompanion>[];
      final appsToUpdate = <String, AppsCompanion>{};

      // Process installed apps
      for (final appInfo in installedApps) {
        final existing = existingDbMap[appInfo.packageName];
        final Uint8List iconData = appInfo.icon ?? Uint8List(0);

        if (existing == null) {
          appsToInsert.add(
            AppsCompanion.insert(
              packageName: appInfo.packageName,
              appName: appInfo.name,
              category: drift.Value(_categorizeApp(appInfo.name.toLowerCase())),
              icon: drift.Value(iconData),
            ),
          );
        } else {
          final updatedCompanion = AppsCompanion(
            appName: drift.Value(appInfo.name),
            icon:
                (existing.icon == null || existing.icon!.isEmpty) &&
                    iconData.isNotEmpty
                ? drift.Value(iconData)
                : const drift.Value.absent(),
          );

          if (updatedCompanion.appName.value != existing.appName ||
              updatedCompanion.icon.present) {
            appsToUpdate[appInfo.packageName] = updatedCompanion;
          }
        }
      }

      // Remove uninstalled apps
      final appsToDelete = existingDbApps
          .where(
            (dbApp) =>
                !packageNamesFromPackageManager.contains(dbApp.packageName),
          )
          .toList();

      if (appsToDelete.isNotEmpty) {
        for (final app in appsToDelete) {
          await db.deleteAppByPackage(app.packageName);
          clearAppIconCache(app.packageName);
        }
      }

      // Batch operations
      if (appsToInsert.isNotEmpty) {
        await db.batchInsertApps(appsToInsert);
      }
      if (appsToUpdate.isNotEmpty) {
        for (var entry in appsToUpdate.entries) {
          await (db.update(
            db.apps,
          )..where((a) => a.packageName.equals(entry.key))).write(entry.value);
          if (entry.value.icon.present) {
            clearAppIconCache(entry.key);
          }
        }
      }
    } catch (e, stack) {
      print("❌ Critical error: $e\n$stack");
      Get.snackbar(
        'Load Error',
        'Failed to load apps. Showing cached data.',
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _categorizeApp(String name) {
    if (name.contains('game')) return 'Games';
    if (name.contains('facebook') ||
        name.contains('instagram') ||
        name.contains('twitter') ||
        name.contains('whatsapp') ||
        name.contains('messenger') ||
        name.contains('telegram') ||
        name.contains('tiktok')) {
      return 'Social';
    }
    if (name.contains('notes') ||
        name.contains('todo') ||
        name.contains('office') ||
        name.contains('calendar') ||
        name.contains('mail') ||
        name.contains('drive') ||
        name.contains('docs') ||
        name.contains('calculator') ||
        name.contains('document') ||
        name.contains('pdf')) {
      return 'Productivity';
    }
    return 'Uncategorized';
  }

  // --- USER ACTIONS (NO FULL RELOADS!) ---
  Future<void> launchApp(String packageName) async {
    final result = await InstalledApps.startApp(packageName);
    if (result == true) {
      await db.updateUsage(packageName);
      // Stream auto-updates UI
    }
  }

  Future<void> pickCustomIcon(String packageName) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await db.updateCustomIcon(packageName, picked.path);
      clearAppIconCache(packageName);
    }
  }

  Future<void> changeCategory(String packageName, String? category) async {
    await db.updateCategory(packageName, category);
  }

  Future<void> toggleHide(String packageName) async {
    final app = allApps.firstWhereOrNull((a) => a.packageName == packageName);
    if (app != null) {
      await db.hideApp(packageName, !app.isHidden);
    }
  }

  // --- FILTERING & SORTING ---
  List<App> getAppsInCategory() {
    final appsList = allApps.value;
    if (appsList.isEmpty) return [];

    if (selectedCategory.value == 'All') {
      return appsList.where((a) => !a.isHidden).toList();
    } else if (selectedCategory.value == 'Frequent') {
      return []; // Handled separately
    } else if (selectedCategory.value == 'Uncategorized') {
      return appsList
          .where(
            (a) =>
                (a.category == null || a.category == 'Uncategorized') &&
                !a.isHidden,
          )
          .toList();
    } else {
      return appsList
          .where((a) => a.category == selectedCategory.value && !a.isHidden)
          .toList();
    }
  }

  void _applyFiltersAndSort() {
    if (isLoading.value) {
      filteredAndSortedApps.assignAll([]);
      return;
    }

    var apps = getAppsInCategory();

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      apps = apps
          .where(
            (a) => a.appName.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }

    // Apply sorting
    switch (sortBy.value) {
      case 'Usage':
        apps.sort((a, b) => b.usageCount.compareTo(a.usageCount));
        break;
      case 'Last Used':
        apps.sort(
          (a, b) => (b.lastUsed ?? DateTime(2000)).compareTo(
            a.lastUsed ?? DateTime(2000),
          ),
        );
        break;
      default: // Name
        apps.sort((a, b) => a.appName.compareTo(b.appName));
    }

    filteredAndSortedApps.assignAll(apps); // ✅ Use assignAll for RxList
  }

  // --- FREQUENT APPS ---
  Future<List<App>> getFrequentApps() async {
    return await db.getFrequentApps(10);
  }

  // --- UI CONTROLS ---
  void changeGridCount(int count) => gridCount.value = count;

  void updateSearch(String query) {
    _searchDebouncer.run(() => searchQuery.value = query);
  }

  void updateSort(String sortOption) => sortBy.value = sortOption;

  // --- WALLPAPER ---
  Future<void> pickWallpaper() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) await setWallpaper(picked.path);
  }

  Future<void> setWallpaper(String imagePath) async {
    try {
      if (await WallpaperManagerFlutter().setWallpaper(
        File(imagePath),
        WallpaperManagerFlutter.homeScreen,
      )) {
        wallpaperPath.value = imagePath;
        Get.snackbar('Success', 'Wallpaper set!');
      } else {
        Get.snackbar('Error', 'Failed to set wallpaper');
      }
    } catch (e) {
      Get.snackbar('Error', 'Wallpaper error: $e');
    }
  }

  Future<void> _loadWallpaperPath() async {
    // TODO: Load from SharedPreferences
  }

  void _requestPermissions() async {
    await [Permission.storage, Permission.manageExternalStorage].request();
  }

  // --- UNINSTALL ---
  Future<void> uninstallApp(String packageName) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Uninstall App'),
        content: Text('Uninstall $packageName?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Uninstall'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await InstalledApps.uninstallApp(packageName);
        if (result == true) {
          Get.snackbar('Success', 'App uninstalled');
        } else if (result == false) {
          Get.snackbar('Warning', 'Manual uninstall required');
        } else {
          // result == null → e.g., user canceled system dialog, or not supported
          Get.snackbar('Info', 'Uninstall not completed');
        }
      } catch (e) {
        Get.snackbar('Error', 'Uninstall failed: $e');
      } finally {
        loadInstalledApps(); // Re-sync to remove from DB if truly uninstalled
      }
    }
  }

  Future<void> removeAppFromDb(String packageName) async {
    try {
      await (db.delete(
        db.apps,
      )..where((a) => a.packageName.equals(packageName))).go();
      clearAppIconCache(packageName);
    } catch (e) {
      Get.snackbar('DB Error', 'Failed to remove app');
    }
  }
}

// Debouncer for search
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() => _timer?.cancel();
}
