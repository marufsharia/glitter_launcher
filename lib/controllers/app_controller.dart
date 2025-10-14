import 'dart:io';

import 'package:drift/drift.dart'
    as drift; // Alias to avoid conflict with GetX's Value
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glitter_launcher/database/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

class AppController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  var allApps = <App>[].obs;

  var categories = <String>[
    'All',
    'Frequent',
    'Games',
    'Social',
    'Productivity',
    'Uncategorized',
  ].obs;
  var selectedCategory = 'All'.obs;
  var gridCount = 4.obs; // Customizable grid columns
  var isLoading = true.obs;
  var searchQuery = ''.obs;
  var sortBy = 'Name'.obs; // 'Name', 'Usage', 'Last Used'
  var wallpaperPath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _requestPermissions();
    loadInstalledApps();
    //debugLoadApps();

    _loadWallpaperPath();
  }

  Future<void> debugLoadApps() async {
    isLoading.value = true;
    try {
      final installedApps = await InstalledApps.getInstalledApps(false, true);
      //print('Found ${installedApps.length} apps');

      if (installedApps.isEmpty) {
        Get.snackbar(
          'Warning',
          'No apps found. Check AndroidManifest.xml <queries> tag.',
        );
      }

      // ... rest of your logic
    } catch (e, stack) {
      print('Error loading apps: $e\n$stack');
      Get.snackbar('Error', 'Failed to load apps: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadInstalledApps() async {
    isLoading.value = true;
    try {
      // Only user-installed apps
      final installedApps = await InstalledApps.getInstalledApps(
        false, // include system apps? false = no
        false, // include launch intent? true = yes (we still want)
      );

      if (installedApps.isEmpty) {
        Get.snackbar(
          'No Apps Found',
          'Check AndroidManifest.xml for <queries> tag',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      int inserted = 0, updated = 0;
      for (var appInfo in installedApps) {
        final existing =
            await (db.select(db.apps)
                  ..where((a) => a.packageName.equals(appInfo.packageName)))
                .getSingleOrNull();

        if (existing == null) {
          await db
              .into(db.apps)
              .insert(
                AppsCompanion.insert(
                  packageName: appInfo.packageName,
                  appName: appInfo.name,
                  category: drift.Value(
                    _categorizeApp(appInfo.name.toLowerCase()),
                  ),
                  icon: drift.Value(appInfo.icon ?? drift.Uint8List(0)),
                ),
              );
          inserted++;
        } else if (existing.icon == null && appInfo.icon != null) {
          await (db.update(db.apps)
                ..where((a) => a.packageName.equals(appInfo.packageName)))
              .write(AppsCompanion(icon: drift.Value(appInfo.icon)));
          updated++;
        }
      }

      allApps.value = await db.getAllApps();
      print(
        "✅ Database updated: $inserted new, $updated icons updated. Total apps: ${allApps.length}",
      );

      selectedCategory.refresh();
    } catch (e, stack) {
      print("❌ Error in loadInstalledApps: $e\n$stack");
      Get.snackbar(
        'Load Failed',
        'Could not load apps: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
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
        name.contains('messenger')) {
      return 'Social';
    }
    if (name.contains('notes') ||
        name.contains('todo') ||
        name.contains('office') ||
        name.contains('calculator') ||
        name.contains('document') ||
        name.contains('pdf')) {
      return 'Productivity';
    }

    return 'Uncategorized';
  }

  Future<void> launchApp(String packageName) async {
    final result = await InstalledApps.startApp(packageName);
    if (result == true) {
      await db.updateUsage(packageName);
      loadInstalledApps(); // Refresh usage
    }
  }

  Future<void> pickCustomIcon(String packageName) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await db.updateCustomIcon(packageName, pickedFile.path);
      loadInstalledApps();
    }
  }

  Future<void> changeCategory(String packageName, String? category) async {
    await db.updateCategory(packageName, category);
    loadInstalledApps();
  }

  Future<void> toggleHide(String packageName) async {
    final app = allApps.firstWhere((a) => a.packageName == packageName);
    await db.hideApp(packageName, !app.isHidden);
    loadInstalledApps();
  }

  // In AppController, replace these methods:

  List<App> getAppsInCategory() {
    // Ensure allApps is never null and handle empty case
    final appsList = allApps.value;
    if (appsList.isEmpty) {
      return [];
    }

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

  List<App> getFilteredApps() {
    try {
      var apps = getAppsInCategory();
      if (apps.isEmpty) {
        return [];
      }

      // Search filter
      if (searchQuery.value.isNotEmpty) {
        apps = apps
            .where(
              (a) => a.appName.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
            )
            .toList();
      }

      // Sort with null safety
      switch (sortBy.value) {
        case 'Usage':
          apps.sort((a, b) => (b.usageCount).compareTo(a.usageCount));
          break;
        case 'Last Used':
          apps.sort(
            (a, b) => (b.lastUsed ?? DateTime(2000)).compareTo(
              a.lastUsed ?? DateTime(2000),
            ),
          );
          break;
        default:
          apps.sort((a, b) => a.appName.compareTo(b.appName));
      }

      return apps;
    } catch (e) {
      print('Error in getFilteredApps: $e');
      return [];
    }
  }

  Future<List<App>> getFrequentApps() async {
    return await db.getFrequentApps(10);
  }

  void changeGridCount(int count) {
    gridCount.value = count;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void updateSort(String sortOption) {
    sortBy.value = sortOption;
  }

  Future<void> pickWallpaper() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await setWallpaper(pickedFile.path);
    }
  }

  Future<void> setWallpaper(String imagePath) async {
    try {
      final result = await WallpaperManagerFlutter().setWallpaper(
        File(imagePath),
        WallpaperManagerFlutter.homeScreen,
      );
      if (result) {
        wallpaperPath.value = imagePath;
        Get.snackbar('Success', 'Wallpaper set successfully!');
      } else {
        Get.snackbar('Error', 'Failed to set wallpaper');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to set wallpaper: $e');
    }
  }

  Future<void> _loadWallpaperPath() async {
    // Load from shared prefs if needed; for now, default empty
  }

  void _requestPermissions() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request(); // For wallpapers
  }

  /// Try to uninstall an app. If programmatic uninstall fails, remove from
  /// launcher DB (so it stops showing) and instruct the user.
  Future<void> uninstallApp(String packageName) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Uninstall App'),
        content: const Text('Are you sure you want to uninstall this app?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(Get.context!).pop,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(true),
            child: const Text('Uninstall'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Try to uninstall using installed_apps (some devices/packages may support it)
      // If InstalledApps.uninstallApp doesn't exist in your version, this will throw and go to catch.
      final result = await InstalledApps.uninstallApp(packageName);
      if (result == true) {
        // If uninstall succeeded, also remove from DB to keep launcher clean
        await removeAppFromDb(packageName);
        Get.snackbar('Uninstalled', 'App removed from device.');
      } else {
        // Programmatic uninstall didn't succeed; fallback
        await removeAppFromDb(packageName);
        Get.snackbar(
          'Removed from launcher',
          'Could not uninstall programmatically. Please uninstall from device settings if desired.',
        );
      }
    } catch (e, st) {
      print('Uninstall fallback: $e\n$st');
      // Fallback: remove entry from database so it won't show in launcher,
      // because some devices don't allow silent / direct uninstall.
      await removeAppFromDb(packageName);
      Get.snackbar(
        'Removed from launcher',
        'Could not uninstall automatically. Entry removed from launcher. Uninstall via system settings if needed.',
      );
    }
  }

  /// Remove an app record from the launcher DB and refresh list.
  Future<void> removeAppFromDb(String packageName) async {
    try {
      await (db.delete(
        db.apps,
      )..where((a) => a.packageName.equals(packageName))).go();
    } catch (e) {
      print('Error deleting app from DB: $e');
    } finally {
      allApps.value = await db.getAllApps();
      selectedCategory.refresh();
    }
  }
}
