import 'package:flutter/material.dart';
import '../../../models/themes.dart';
import 'theme_option_tile.dart';

class ThemeSection extends StatelessWidget {
  final String currentTheme;
  final Function(String) onThemeChanged;

  const ThemeSection({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.palette, size: 24),
              SizedBox(width: 12),
              Text(
                'Theme Selection',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your preferred app theme',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 20),
          ThemeOptionTile(
              title: 'Light Theme',
              value: 'light',
              icon: Icons.light_mode,
              iconColor: Colors.orange,
              currentTheme: currentTheme,
              onThemeChanged: onThemeChanged),
          const SizedBox(height: 12),
          ThemeOptionTile(
              title: 'Dark Theme',
              value: 'dark',
              icon: Icons.dark_mode,
              iconColor: Colors.grey,
              currentTheme: currentTheme,
              onThemeChanged: onThemeChanged),
          const SizedBox(height: 12),
          ThemeOptionTile(
              title: 'Blue Theme',
              value: 'blue',
              icon: Icons.water_drop,
              iconColor: Colors.blue,
              currentTheme: currentTheme,
              onThemeChanged: onThemeChanged),
        ],
      ),
    );
  }
}
