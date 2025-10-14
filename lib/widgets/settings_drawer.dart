import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:glitter_launcher/controllers/app_controller.dart';
import 'package:glitter_launcher/controllers/theme_controller.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final appCtrl = Get.find<AppController>();

    return Obx(() {
      return Drawer(
        backgroundColor: themeCtrl.isDark.value
            ? Colors.grey[900]!.withOpacity(0.94)
            : Colors.white.withOpacity(0.96),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // === HEADER ===
            Obx(
              () => Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeCtrl.primaryColor.value,
                      themeCtrl.primaryColor.value.withOpacity(0.75),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 16,
                      left: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Glitter Launcher',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Personalize your experience',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 48,
                      right: 24,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // === APPEARANCE ===
            _sectionTitle('Appearance'),
            _switchTile(
              'Dark Mode',
              Icons.dark_mode,
              themeCtrl.isDark.value,
              () => themeCtrl.toggleThemeMode(),
            ),
            _listTile(
              'Primary Color',
              Icons.palette,
              trailing: Obx(
                () => CircleAvatar(
                  radius: 14,
                  backgroundColor: themeCtrl.primaryColor.value,
                ),
              ),
              onTap: () => _showColorPicker(context),
            ),

            // === LAYOUT ===
            _sectionTitle('Layout'),
            _listTile(
              'Grid Columns',
              Icons.grid_view,
              trailing: Obx(
                () => DropdownButton<int>(
                  value: appCtrl.gridCount.value,
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  style: const TextStyle(fontSize: 16),
                  dropdownColor: themeCtrl.isDark.value
                      ? Colors.grey[850]
                      : Colors.white,
                  items: [3, 4, 5, 6]
                      .map((c) => DropdownMenuItem(value: c, child: Text('$c')))
                      .toList(),
                  onChanged: (value) => appCtrl.changeGridCount(value!),
                ),
              ),
            ),
            _listTile(
              'Sort Apps By',
              Icons.sort,
              trailing: Obx(
                () => DropdownButton<String>(
                  value: appCtrl.sortBy.value,
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  style: const TextStyle(fontSize: 16),
                  dropdownColor: themeCtrl.isDark.value
                      ? Colors.grey[850]
                      : Colors.white,
                  items: ['Name', 'Usage', 'Last Used']
                      .map(
                        (sort) =>
                            DropdownMenuItem(value: sort, child: Text(sort)),
                      )
                      .toList(),
                  onChanged: (value) => appCtrl.updateSort(value!),
                ),
              ),
            ),

            // === MEDIA ===
            _sectionTitle('Media'),
            _listTile(
              'Set Wallpaper',
              Icons.wallpaper,
              onTap: () => appCtrl.pickWallpaper(),
            ),
            _listTile(
              'Reset Wallpaper',
              Icons.refresh,
              onTap: () {
                appCtrl.wallpaperPath.value = '';
                Get.snackbar(
                  'Wallpaper Reset',
                  'Default background restored',
                  backgroundColor: themeCtrl.primaryColor.value.withOpacity(
                    0.9,
                  ),
                  colorText: Colors.white,
                );
              },
            ),

            // === APP MANAGEMENT ===
            _sectionTitle('App Management'),
            _listTile(
              'Refresh Apps',
              Icons.sync,
              onTap: () async {
                await appCtrl.loadInstalledApps();
                Get.snackbar(
                  'Success',
                  'Apps refreshed successfully!',
                  backgroundColor: Colors.green.withOpacity(0.9),
                  colorText: Colors.white,
                );
              },
            ),
            _listTile(
              'Manage Hidden Apps',
              Icons.visibility_off,
              onTap: () => _showHiddenApps(context),
            ),

            // === INFO ===
            const Divider(height: 32),
            _listTile(
              'Gesture Controls',
              Icons.swipe,
              subtitle: 'Swipe right to open drawer',
            ),
            _listTile(
              'Animations',
              Icons.animation,
              subtitle: 'Smooth transitions enabled',
            ),
            _listTile(
              'About Glitter Launcher',
              Icons.info,
              onTap: () => _showAboutDialog(context),
            ),
          ],
        ),
      );
    });
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Get.theme.primaryColor.withOpacity(0.85),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _switchTile(
    String title,
    IconData icon,
    bool value,
    VoidCallback onChanged,
  ) {
    final themeCtrl = Get.find<ThemeController>();
    return SwitchListTile.adaptive(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      secondary: Icon(icon, color: themeCtrl.primaryColor.value),
      value: value,
      activeColor: themeCtrl.primaryColor.value,
      onChanged: (_) => onChanged(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _listTile(
    String title,
    IconData icon, {
    Widget? trailing,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    final themeCtrl = Get.find<ThemeController>();
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: themeCtrl.primaryColor.value.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: themeCtrl.primaryColor.value, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: themeCtrl.isDark.value ? Colors.white : Colors.grey[800],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: themeCtrl.isDark.value
                    ? Colors.white60
                    : Colors.grey[600],
                fontSize: 13,
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: themeCtrl.isDark.value ? Colors.white54 : Colors.grey[500],
          ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  void _showColorPicker(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    Color currentColor = themeCtrl.primaryColor.value;

    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Choose Primary Color',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: currentColor,
            onColorChanged: (color) => currentColor = color,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: currentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              themeCtrl.changePrimaryColor(currentColor);
              Get.back();
            },
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHiddenApps(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    final hiddenApps = appCtrl.allApps.where((app) => app.isHidden).toList();

    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hidden Apps (${hiddenApps.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: hiddenApps.isEmpty
              ? const Center(child: Text('No hidden apps'))
              : ListView.builder(
                  itemCount: hiddenApps.length,
                  itemBuilder: (context, index) {
                    final app = hiddenApps[index];
                    return ListTile(
                      leading: app.icon != null
                          ? ClipOval(
                              child: Image.memory(
                                app.icon!,
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.android, size: 32),
                      title: Text(app.appName),
                      trailing: IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.green),
                        onPressed: () {
                          appCtrl.toggleHide(app.packageName);
                          Get.back();
                          _showHiddenApps(context);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Glitter Launcher',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.transparent,
              child: Icon(Icons.launch, size: 60, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: themeCtrl.primaryColor.value,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A beautiful, customizable home screen for Android.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }
}
