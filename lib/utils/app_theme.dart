import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary    = Color(0xFF6C63FF);
  static const Color secondary  = Color(0xFFFF6584);
  static const Color accent     = Color(0xFF43B97F);
  static const Color background = Color(0xFFF8F9FE);
  static const Color cardBg     = Colors.white;
  static const Color textDark   = Color(0xFF2D3142);
  static const Color textMid    = Color(0xFF6B7280);
  static const Color textLight  = Color(0xFF9CA3AF);

  static const Color statusEnProceso = Color(0xFF43B97F);
  static const Color statusCompletada = Color(0xFF9CA3AF);
  static const Color statusCancelada  = Color(0xFFEF4444);

  static Color getStatusColor(int estatus) {
    switch (estatus) {
      case 0:  return statusEnProceso;
      case 1:  return statusCompletada;
      case 2:  return statusCancelada;
      default: return textMid;
    }
  }

  static IconData getStatusIcon(int estatus) {
    switch (estatus) {
      case 0:  return Icons.hourglass_empty_rounded;
      case 1:  return Icons.check_circle_rounded;
      case 2:  return Icons.cancel_rounded;
      default: return Icons.help_rounded;
    }
  }

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
  color: cardBg,
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );
}

Color hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}

String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
}

extension ColorDarken on Color {
  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
