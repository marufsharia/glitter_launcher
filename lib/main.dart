import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bindings/app_binding.dart';
import 'controllers/theme_controller.dart';
import 'views/home_screen.dart';

void main() {
  runApp( GlitterLauncherApp());
}

class GlitterLauncherApp extends StatelessWidget {
   GlitterLauncherApp({super.key});

  final themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    Get.put(ThemeController());
    return Obx(() {
      return GetMaterialApp(
        title: 'Glitter Launcher',
        theme: Get.find<ThemeController>().lightTheme,
        darkTheme: themeController.darkTheme,
        //themeMode: themeController.toggleThemeMode(),
        initialBinding: AppBinding(),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
