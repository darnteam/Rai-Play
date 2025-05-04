import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Map<String, Color> raiffeisen = {
    'primary': Color(0xFFFFED00), // Raiffeisen Yellow
    'secondary': Color(0xFF000000), // Black
    'background': Color(0xFFFFFDF5), // Very Light Yellow
    'surface': Color(0xFFFFFFFF), // White
    'textPrimary': Color(0xFF000000), // Black
    'textSecondary': Color(0xFF666666), // Dark Gray
    'divider': Color(0xFFE0E0E0), // Light Gray for borders
    'success': Color(0xFF4CAF50), // Green
    'error': Color(0xFFE53935), // Error Red
    'warning': Color(0xFFFFA000), // Warning Orange
    'accent': Color(0xFF000000), // Black as accent
    'cardBackground': Color(0xFFFFFDF5), // Very Light Yellow for cards
  };

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        primary: raiffeisen['primary']!,
        secondary: raiffeisen['secondary']!,
        surface: raiffeisen['surface']!,
        background: raiffeisen['background']!,
        error: raiffeisen['error']!,
        onPrimary: raiffeisen['secondary']!, // Black on Yellow
        onSecondary: raiffeisen['surface']!, // White on Black
        onSurface: raiffeisen['textPrimary']!,
        onBackground: raiffeisen['textPrimary']!,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: raiffeisen['background'],
      appBarTheme: AppBarTheme(
        backgroundColor: raiffeisen['primary'],
        foregroundColor: raiffeisen['secondary'],
        elevation: 0,
        iconTheme: IconThemeData(
          color: raiffeisen['secondary'],
        ),
        actionsIconTheme: IconThemeData(
          color: raiffeisen['secondary'],
        ),
      ),
      cardTheme: CardTheme(
        color: raiffeisen['surface'],
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        buttonColor: raiffeisen['primary'],
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: raiffeisen['primary'],
          foregroundColor: raiffeisen['secondary'],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: raiffeisen['secondary'],
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: raiffeisen['secondary'],
          side: BorderSide(color: raiffeisen['secondary']!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: raiffeisen['divider']!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: raiffeisen['divider']!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: raiffeisen['secondary']!,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: raiffeisen['error']!,
          ),
        ),
        filled: true,
        fillColor: raiffeisen['surface'],
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: raiffeisen['textPrimary'],
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: raiffeisen['textPrimary'],
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: raiffeisen['textPrimary'],
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: raiffeisen['textPrimary'],
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: raiffeisen['textPrimary'],
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: raiffeisen['textPrimary'],
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: raiffeisen['textPrimary'],
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: raiffeisen['textPrimary'],
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: raiffeisen['textSecondary'],
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: raiffeisen['textPrimary'],
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: raiffeisen['divider'],
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: raiffeisen['surface'],
        selectedItemColor: raiffeisen['secondary'],
        unselectedItemColor: raiffeisen['textSecondary'],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Dark color scheme
  static final ColorScheme darkColorScheme = const ColorScheme(
    primary: Color(0xFF9E7DFF), // Light Purple
    onPrimary: Colors.black,
    secondary: Color(0xFF4CD964), // Green
    onSecondary: Colors.black,
    tertiary: Color(0xFFFFB340), // Light Orange
    onTertiary: Colors.black,
    background: Color(0xFF121212),
    onBackground: Colors.white,
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white,
    error: Color(0xFFFF6B5B),
    onError: Colors.black,
    brightness: Brightness.dark,
  );

  // Text theme
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.nunito(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.nunito(
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: GoogleFonts.nunito(
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: GoogleFonts.nunito(
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: GoogleFonts.nunito(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: GoogleFonts.nunito(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.nunito(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.nunito(
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: GoogleFonts.nunito(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: GoogleFonts.nunito(
      fontSize: 10,
      fontWeight: FontWeight.w500,
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: darkColorScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.background,
      foregroundColor: darkColorScheme.onBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: darkColorScheme.onBackground,
      ),
    ),
    cardTheme: CardTheme(
      color: darkColorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkColorScheme.primary,
        foregroundColor: darkColorScheme.onPrimary,
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkColorScheme.primary,
        textStyle: textTheme.labelLarge,
        side: BorderSide(color: darkColorScheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkColorScheme.primary,
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkColorScheme.surface,
      selectedItemColor: darkColorScheme.primary,
      unselectedItemColor: darkColorScheme.onBackground.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
