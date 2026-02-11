import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// App Colors untuk Light Mode (Feminim Aesthetic)
class LightColors {
  // Gradien utama feminim
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFFFFB6C1), Color(0xFFE6E6FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Warna utama
  static const primary = Color(0xFFFFB6C1); // Light Pink
  static const secondary = Color(0xFFE6E6FA); // Lavender
  static const accent = Color(0xFFFFD1DC); // Baby Pink
  static const softPurple = Color(0xFFD8BFD8); // Thistle

  // Status colors
  static const success = Color(0xFFA7C7E7); // Soft Blue
  static const warning = Color(0xFFFFD700); // Gold
  static const error = Color(0xFFFF6B6B); // Coral Red
  static const info = Color(0xFF98D8D8); // Tiffany Blue

  // Background & Surface
  static const background = Color(0xFFFFFAFA); // Snow White
  static const surface = Color(0xFFFFFFFF); // Pure White
  static const card = Color(0xFFFDF5E6); // Old Lace

  // Text colors
  static const textPrimary = Color(0xFF6D6875); // Rose Quartz Grey
  static const textSecondary = Color(0xFFB5838D); // Rose Dust
  static const textAccent = Color(0xFFE5989B); // English Lavender

  // Border & Divider
  static const border = Color(0xFFFFF0F5); // Lavender Blush
}

// App Colors untuk Dark Mode (Galaxy Theme)
class DarkColors {
  // Gradien galaksi
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Warna galaksi
  static const primary = Color(0xFF302B63); // Deep Purple
  static const secondary = Color(0xFF0F0C29); // Dark Blue
  static const accent = Color(0xFF6A11CB); // Purple
  static const nebula = Color(0xFF2575FC); // Blue

  // Status colors dengan efek glowing
  static const success = Color(0xFF00B4DB); // Cyan
  static const warning = Color(0xFFFDC830); // Yellow
  static const error = Color(0xFFFF416C); // Pink Red
  static const info = Color(0xFF24FE41); // Green

  // Background & Surface
  static const background = Color(0xFF0A0A1A); // Space Black
  static const surface = Color(0xFF1A1A2E); // Dark Blue
  static const card = Color(0xFF16213E); // Navy Blue

  // Text colors dengan efek bintang
  static const textPrimary = Color(0xFFE6E6FA); // Ghost White
  static const textSecondary = Color(0xFFB19CD9); // Light Pastel Purple
  static const textAccent = Color(0xFF9370DB); // Medium Purple

  // Border & Divider (seperti cahaya bintang)
  static const border = Color(0xFF2D2D5A); // Deep Space Purple
}

// App Theme Manager
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: LightColors.primary,
        secondary: LightColors.secondary,
        surface: LightColors.surface,
        background: LightColors.background,
        error: LightColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: LightColors.textPrimary,
        onBackground: LightColors.textPrimary,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          color: LightColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: GoogleFonts.poppins(
          color: LightColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: LightColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: LightColors.textSecondary,
          fontSize: 14,
        ),
      ),
      scaffoldBackgroundColor: LightColors.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: LightColors.background,
        foregroundColor: LightColors.textPrimary,
        iconTheme: const IconThemeData(color: LightColors.textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: LightColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: LightColors.card,
        margin: const EdgeInsets.all(8),
        shadowColor: LightColors.primary.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: LightColors.primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LightColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LightColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(
          color: LightColors.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(
          color: LightColors.textSecondary.withOpacity(0.7),
        ),
      ),
      iconTheme: const IconThemeData(
        color: LightColors.textSecondary,
      ),
      dividerTheme: DividerThemeData(
        color: LightColors.border.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: LightColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: DarkColors.primary,
        secondary: DarkColors.secondary,
        surface: DarkColors.surface,
        background: DarkColors.background,
        error: DarkColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: DarkColors.textPrimary,
        onBackground: DarkColors.textPrimary,
        onError: Colors.white,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          color: DarkColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: GoogleFonts.poppins(
          color: DarkColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: DarkColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: DarkColors.textSecondary,
          fontSize: 14,
        ),
      ),
      scaffoldBackgroundColor: DarkColors.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: DarkColors.background,
        foregroundColor: DarkColors.textPrimary,
        iconTheme: const IconThemeData(color: DarkColors.textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: DarkColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: DarkColors.card,
        margin: const EdgeInsets.all(8),
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: DarkColors.accent,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shadowColor: DarkColors.accent.withOpacity(0.3),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DarkColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DarkColors.accent, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(
          color: DarkColors.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(
          color: DarkColors.textSecondary.withOpacity(0.7),
        ),
      ),
      iconTheme: const IconThemeData(
        color: DarkColors.textSecondary,
      ),
      dividerTheme: DividerThemeData(
        color: DarkColors.border.withOpacity(0.5),
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: DarkColors.accent,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DarkColors.surface,
        selectedItemColor: DarkColors.accent,
        unselectedItemColor: DarkColors.textSecondary,
      ),
    );
  }

  // Helper untuk mendapatkan tema berdasarkan mode
  static ThemeData getTheme(bool isDarkMode) {
    return isDarkMode ? darkTheme : lightTheme;
  }

  // Helper untuk mendapatkan colors berdasarkan tema
  static dynamic getColors(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? DarkColors : LightColors;
  }

  // Helper untuk mendapatkan background berdasarkan tema
  static Color getBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? DarkColors.background
        : LightColors.background;
  }

  // Helper untuk mendapatkan gradient berdasarkan tema
  static LinearGradient getGradient(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? DarkColors.primaryGradient
        : LightColors.primaryGradient;
  }
}

// Helper Functions
class Helpers {
  static String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Fungsi ini sekarang menggunakan BuildContext untuk mendapatkan tema
  static Color getStatusColor(String status, BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    switch (status.toLowerCase()) {
      case 'pending':
        return isDarkMode ? DarkColors.warning : LightColors.warning;
      case 'proses':
        return isDarkMode ? DarkColors.info : LightColors.info;
      case 'selesai':
        return isDarkMode ? DarkColors.success : LightColors.success;
      case 'ditolak':
        return isDarkMode ? DarkColors.error : LightColors.error;
      default:
        return isDarkMode
            ? DarkColors.textSecondary
            : LightColors.textSecondary;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'proses':
        return Icons.sync_rounded;
      case 'selesai':
        return Icons.check_circle_rounded;
      case 'ditolak':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    final backgroundColor = isError
        ? (isDarkMode ? DarkColors.error : LightColors.error)
        : (isDarkMode ? DarkColors.success : LightColors.success);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// Constants
class AppConstants {
  static const appName = 'SISAPRA';
  static const appFullName = 'Sistem Informasi Sarana dan Prasarana';

  static const kategoris = [
    'Ruang Kelas',
    'Laboratorium',
    'Toilet',
    'Perpustakaan',
    'Lapangan',
    'Kantin',
    'Lainnya',
  ];

  static const kelas = [
    'XII RPL 1',
    'XII RPL 2',
    'XII TKJ 1',
    'XII TKJ 2',
    'XII MM 1',
    'XII MM 2',
  ];
}

// Theme Provider
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme {
    return _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}

// AppColors - CONST dari Light Colors (untuk backward compatibility)
class AppColors {
  static const primaryGradient = LightColors.primaryGradient;
  static const primary = LightColors.primary;
  static const secondary = LightColors.secondary;
  static const success = LightColors.success;
  static const warning = LightColors.warning;
  static const error = LightColors.error;
  static const info = LightColors.info;
  static const background = LightColors.background;
  static const surface = LightColors.surface;
  static const textPrimary = LightColors.textPrimary;
  static const textSecondary = LightColors.textSecondary;
}

// Helpers - untuk akses dynamic colors berdasarkan tema
class DynamicAppColors {
  static Color primary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkColors.primary
        : LightColors.primary;
  }

  static Color secondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkColors.secondary
        : LightColors.secondary;
  }

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkColors.background
        : LightColors.background;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkColors.surface
        : LightColors.surface;
  }

  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkColors.textPrimary
        : LightColors.textPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkColors.textSecondary
        : LightColors.textSecondary;
  }

  static LinearGradient primaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkColors.primaryGradient
        : LightColors.primaryGradient;
  }

  // ✨ Warna dinamis untuk card/surface yang transparan di dark mode
  static Color cardBackground(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Colors.black.withOpacity(0.3); // Hitam transparan 30% - elegan!
    }
    return LightColors.card; // Full opaque di light mode
  }

  // ✨ Warna untuk input field
  static Color inputBackground(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Colors.black
          .withOpacity(0.25); // Hitam transparan - seperti tab widget
    }
    return Colors.white; // Putih di light mode
  }

  // ✨ Warna untuk dialog/overlay
  static Color overlayBackground(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Colors.black.withOpacity(0.4); // Hitam transparan - lebih visible
    }
    return Colors.white; // Full white di light mode
  }
}
