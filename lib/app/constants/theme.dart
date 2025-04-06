import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _loadTheme();
  }

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleTheme() async {
    setDarkMode(!isDarkMode);
    // Save the theme preference to shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  void _loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the stored preference value for dark mode
    bool? isDarkMode = prefs.getBool('isDarkMode');

    // If `isDarkMode` is null, fallback to the system theme
    if (isDarkMode == null) {
      debugPrint('User has not set a theme preference');
      debugPrint('Falling back to the system theme');
      // Fallback to the system's theme mode
      final Brightness brightness =
          WidgetsBinding.instance.window.platformBrightness;
      debugPrint('System theme mode: $brightness');
      isDarkMode = brightness == Brightness.dark;
    } else {
      debugPrint('User has set a theme preference: $isDarkMode');
    }

    // Apply the theme based on the value of `isDarkMode`
    setDarkMode(isDarkMode);
  }

  ThemeData get currentTheme {
    return lightTheme;
  }

  ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    textTheme: textTheme,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      onPrimary: AppColors.onPrimaryLight,
      surface: AppColors.surfaceLight,
      // background: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      outline: AppColors.outlineLight,
    ),
    scaffoldBackgroundColor: AppColors.surfaceLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceLight,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: textTheme.bodyLarge,
      border: OutlineInputBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors
                  .outlineLight; // Custom background color for disabled state
            }
            return AppColors.primaryLight;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors
                  .surfaceLight; // Custom text color for disabled state
            }
            return AppColors.surfaceLight;
          },
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.bodyLarge!.copyWith(
          color: AppColors.onPrimaryLight,
        ),
        iconColor: AppColors.onPrimaryLight),
  );

  ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    textTheme: textTheme,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      onPrimary: AppColors.onPrimaryDark,
      surface: AppColors.surfaceDark,
      // background: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      outline: AppColors.outlineDark,
    ),
    scaffoldBackgroundColor: AppColors.surfaceDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: textTheme.bodyLarge,
      border: OutlineInputBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors
                  .outlineDark; // Custom background color for disabled state
            }
            return AppColors.primaryDark;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors
                  .surfaceDark; // Custom text color for disabled state
            }
            return AppColors.surfaceDark;
          },
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.bodyLarge!.copyWith(
          color: AppColors.onPrimaryDark,
        ),
        iconColor: AppColors.onPrimaryDark),
  );
}

// TextTheme
const TextTheme textTheme = TextTheme(
  displayLarge: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 57,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.25,
  ),
  displayMedium: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 45,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  ),
  displaySmall: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 36,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  ),
  headlineLarge: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 32,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  ),
  headlineMedium: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 28,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  ),
  headlineSmall: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 24,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  ),
  titleLarge: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  ),
  titleMedium: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  titleSmall: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  labelLarge: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  labelMedium: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  ),
  labelSmall: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  ),
  bodyLarge: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  ),
  bodyMedium: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  ),
  bodySmall: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  ),
);
