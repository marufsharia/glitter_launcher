import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeController extends GetxController {
  var themeMode = ThemeMode.system.obs;
  var primaryColor = Rx<MaterialColor>(
    Colors.blue,
  ); // Explicitly typed as Rx<MaterialColor>

  ThemeData get lightTheme => _buildTheme(Brightness.light);
  ThemeData get darkTheme => _buildTheme(Brightness.dark);
  var isDark = RxBool(false);
  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final currentPrimary = primaryColor.value; // Extract value once for clarity
    return ThemeData(
      brightness: brightness,
      primarySwatch:
          currentPrimary, // Use directly since it's already MaterialColor
      scaffoldBackgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: currentPrimary,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        // Fixed: TabBarTheme, not TabBarThemeData
        labelColor: currentPrimary,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
        indicatorColor: currentPrimary,
        labelStyle: GoogleFonts.roboto(fontWeight: FontWeight.bold),
      ),
      textTheme: GoogleFonts.robotoTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      cardTheme: CardThemeData(
        // Fixed: CardTheme, not CardThemeData
        color: isDark ? Colors.grey[800] : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  MaterialColor _colorToMaterialColor(Color color) {
    final colors = <int, Color>{
      50: color.withOpacity(0.1),
      100: color.withOpacity(0.2),
      200: color.withOpacity(0.3),
      300: color.withOpacity(0.4),
      400: color.withOpacity(0.5),
      500: color, // No opacity for primary
      600: color.withOpacity(0.7),
      700: color.withOpacity(0.6),
      800: color.withOpacity(0.5),
      900: color.withOpacity(0.4),
    };
    return MaterialColor(color.value, colors);
  }

  void toggleThemeMode() {
    if (themeMode.value == ThemeMode.light) {
      themeMode.value = ThemeMode.dark;
      isDark.value = true;
    } else {
      themeMode.value = ThemeMode.light;
      isDark.value = false;
    }
    update();
  }

  void changePrimaryColor(Color color) {
    primaryColor.value = _colorToMaterialColor(color);
    update();
  }
}
