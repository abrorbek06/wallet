import 'package:flutter/material.dart';

class ThemeProvider {
  static ThemeData getTheme(String themeName) {
    switch (themeName) {
      case 'light':
        return ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
        );
      case 'blue':
        return ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Color(0xFF0D1B2A),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF0D1B2A),
            elevation: 0,
          ),
        );
      case 'green':
        return ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Color(0xFF0F2027),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF0F2027),
            elevation: 0,
          ),
        );
      case 'purple':
        return ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Color(0xFF1A0E2E),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1A0E2E),
            elevation: 0,
          ),
        );
      default: // dark
        return ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Color(0xFF1A1A1A),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1A1A1A),
            elevation: 0,
          ),
        );
    }
  }

  static String currentTheme = 'blue';

  static void updateTheme(String theme) {

    currentTheme = theme;
  }

  static Color getBackgroundColor() {
    switch (currentTheme) {
      case 'light':
        return Color(0xFFF5F5F5);
      case 'dark':
        return Color(0xFF1A1A1A);
      case 'blue':
        return Color(0xFF0D1B2A);
      case 'green':
        return Color(0xFF0F2027);
      case 'purple':
        return Color(0xFF1A0B2E);
      case 'orange':
        return Color(0xFF2D1B0F);
      default:
        return Color(0xFF1A1A1A);
    }
  }

  static Color getCardColor() {
    switch (currentTheme) {
      case 'light':
        return Colors.white;
      case 'dark':
        return Color(0xFF2D2D2D);
      case 'blue':
        return Color(0xFF1B263B);
      case 'green':
        return Color(0xFF2C5530);
      case 'purple':
        return Color(0xFF2E1A47);
      case 'orange':
        return Color(0xFF4A2C1A);
      default:
        return Color(0xFF2D2D2D);
    }
  }

  static Color getTextColor() {
    switch (currentTheme) {
      case 'light':
        return Color(0xFF2D2D2D);
      case 'dark':
        return Colors.white;
      case 'blue':
        return Color(0xFFE0E1DD);
      case 'green':
        return Color(0xFFE8F5E8);
      case 'purple':
        return Color(0xFFF0E6FF);
      case 'orange':
        return Color(0xFFFFF2E6);
      default:
        return Colors.white;
    }
  }

  static Color getPrimaryColor() {
    switch (currentTheme) {
      case 'light':
        return Color(0xFF2196F3); // Blue for light theme
      case 'dark':
        return Color(0xFF64B5F6); // Light blue for dark theme
      case 'blue':
        return Color(0xFF415A77); // Navy blue
      case 'green':
        return Color(0xFF4CAF50); // Green
      case 'purple':
        return Color(0xFF9C27B0); // Purple
      case 'orange':
        return Color(0xFFFF9800); // Orange
      default:
        return Color(0xFF64B5F6); // Default light blue
    }
  }

  // Additional helper function for accent colors
  static Color getAccentColor() {
    switch (currentTheme) {
      case 'light':
        return Color(0xFFFF5722);
      case 'dark':
        return Color(0xFFFF7043);
      case 'blue':
        return Color(0xFF778DA9);
      case 'green':
        return Color(0xFF81C784);
      case 'purple':
        return Color(0xFFBA68C8);
      case 'orange':
        return Color(0xFFFFB74D);
      default:
        return Color(0xFFFF7043);
    }
  }

  // Helper function for card gradients
  static List<Color> getCardGradient([bool isPrimary = false]) {
    if (isPrimary) {
      switch (currentTheme) {
        case 'light':
          return [Color(0xFF2196F3), Color(0xFF1976D2)];
        case 'dark':
          return [Color(0xFF64B5F6), Color(0xFF42A5F5)];
        case 'blue':
          return [Color(0xFF415A77), Color(0xFF2D3748)];
        case 'green':
          return [Color(0xFF4CAF50), Color(0xFF388E3C)];
        case 'purple':
          return [Color(0xFF9C27B0), Color(0xFF7B1FA2)];
        case 'orange':
          return [Color(0xFFFF9800), Color(0xFFF57C00)];
        default:
          return [Color(0xFF64B5F6), Color(0xFF42A5F5)];
      }
    } else {
      // Secondary gradient for cards
      switch (currentTheme) {
        case 'light':
          return [Colors.white, Color(0xFFF8F9FA)];
        case 'dark':
          return [Color(0xFF2D2D2D), Color(0xFF3D3D3D)];
        case 'blue':
          return [Color(0xFF1B263B), Color(0xFF2B3A4F)];
        case 'green':
          return [Color(0xFF2C5530), Color(0xFF3C6540)];
        case 'purple':
          return [Color(0xFF2E1A47), Color(0xFF3E2A57)];
        case 'orange':
          return [Color(0xFF4A2C1A), Color(0xFF5A3C2A)];
        default:
          return [Color(0xFF2D2D2D), Color(0xFF3D3D3D)];
      }
    }
  }

  // Helper function for success color
  static Color getSuccessColor() {
    return Color(0xFF4CAF50);
  }

  // Helper function for error color
  static Color getErrorColor() {
    return Color(0xFFF44336);
  }

  // Helper function for warning color
  static Color getWarningColor() {
    return Color(0xFFFF9800);
  }

  // Helper function for info color
  static Color getInfoColor() {
    return Color(0xFF2196F3);
  }

  // Helper function for income color
  static Color getIncomeColor() {
    return Color(0xFF4CAF50);
  }

  // Helper function for expense color
  static Color getExpenseColor() {
    return Color(0xFFF44336);
  }

  // Helper function for shadow color based on theme
  static Color getShadowColor() {
    switch (currentTheme) {
      case 'light':
        return Colors.black.withOpacity(0.1);
      case 'dark':
        return Colors.black;
      case 'blue':
        return Color(0xFF0D1B2A).withOpacity(0.4);
    // case 'green':
    //   return Color(0xFF0F2027).withOpacity(0.4);
    // case 'purple':
    //   return Color(0xFF1A0B2E).withOpacity(0.4);
    // case 'orange':
    //   return Color(0xFF2D1B0F).withOpacity(0.4);
      default:
        return Colors.black;
    }
  }

  // Helper function to get theme-specific border color
  static Color getBorderColor() {
    switch (currentTheme) {
      case 'light':
        return Colors.grey.withOpacity(0.3);
      case 'dark':
        return Colors.black;
      case 'blue':
        return Color(0xFF415A77).withOpacity(0.3);
    // case 'green':
    //   return Color(0xFF4CAF50).withOpacity(0.3);
    // case 'purple':
    //   return Color(0xFF9C27B0).withOpacity(0.3);
    // case 'orange':
    //   return Color(0xFFFF9800).withOpacity(0.3);
      default:
        return Colors.black;
    }
  }

  // Helper function to get disabled color
  static Color getDisabledColor() {
    switch (currentTheme) {
      case 'light':
        return Colors.grey[400]!;
      case 'dark':
        return Colors.grey[600]!;
      default:
        return Colors.grey[500]!;
    }
  }

  // Helper function to get hint text color
  static Color getHintColor() {
    switch (currentTheme) {
      case 'light':
        return Colors.grey[600]!;
      case 'dark':
        return Colors.grey[400]!;
      default:
        return Colors.grey[500]!;
    }
  }

  static void setTheme(String theme) {
    // Validate the theme before setting it
    List<String> validThemes = ['light', 'dark', 'blue'];

    if (validThemes.contains(theme)) {
      currentTheme = theme;
    } else {
      // If invalid theme is provided, default to dark theme
      currentTheme = 'dark';
    }
  }

  // Enhanced updateTheme function with validation
  // static void updateTheme(String theme) {
  //   setTheme(theme); // Use setTheme for consistency and validation
  // }

  // Function to get all available themes
  static List<String> getAvailableThemes() {
    return ['light', 'dark', 'blue'];
  }

  // Function to get theme display names
  static Map<String, String> getThemeDisplayNames() {
    return {
      'light': 'Light Theme',
      'dark': 'Dark Theme',
      'blue': 'Ocean Blue',
      // 'green': 'Forest Green',
      // 'purple': 'Royal Purple',
      // 'orange': 'Sunset Orange',
    };
  }

  // Function to get theme icons
  static Map<String, IconData> getThemeIcons() {
    return {
      'light': Icons.light_mode,
      'dark': Icons.dark_mode,
      'blue': Icons.water,
      // 'green': Icons.nature,
      // 'purple': Icons.auto_awesome,
      // 'orange': Icons.wb_sunny,
    };
  }

  // Function to check if theme is dark
  static bool isDarkTheme() {
    return currentTheme != 'light';
  }

  // Function to toggle between light and dark theme
  static void toggleLightDark() {
    if (currentTheme == 'light') {
      setTheme('dark');
    } else {
      setTheme('light');
    }
  }

  // Function to reset to default theme
  static void resetToDefault() {
    setTheme('dark');
  }

  // Function to get current theme display name
  static String getCurrentThemeDisplayName() {
    return getThemeDisplayNames()[currentTheme] ?? 'Unknown Theme';
  }

  // Function to get current theme icon
  static IconData getCurrentThemeIcon() {
    return getThemeIcons()[currentTheme] ?? Icons.help;
  }

  // Function to check if a specific theme is currently active
  static bool isThemeActive(String theme) {
    return currentTheme == theme;
  }

  // Function to get theme information as a map
  static Map<String, dynamic> getThemeInfo() {
    return {
      'name': currentTheme,
      'displayName': getCurrentThemeDisplayName(),
      'icon': getCurrentThemeIcon(),
      'isDark': isDarkTheme(),
      'primaryColor': getPrimaryColor(),
      'backgroundColor': getBackgroundColor(),
      'cardColor': getCardColor(),
      'textColor': getTextColor(),
    };
  }

  // Function to get theme colors as a map
  static Map<String, Color> getThemeColors() {
    return {
      'primary': getPrimaryColor(),
      'accent': getAccentColor(),
      'background': getBackgroundColor(),
      'card': getCardColor(),
      'text': getTextColor(),
      'success': getSuccessColor(),
      'error': getErrorColor(),
      'warning': getWarningColor(),
      'info': getInfoColor(),
      'income': getIncomeColor(),
      'expense': getExpenseColor(),
      'shadow': getShadowColor(),
      'border': getBorderColor(),
      'disabled': getDisabledColor(),
      'hint': getHintColor(),
    };
  }
}