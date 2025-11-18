import 'package:flutter/material.dart';
import '../../../models/themes.dart';
import 'package:app/l10n/app_localizations.dart';
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
            children: [
              Icon(Icons.palette, size: 24),
              SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).t('theme_selection'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).t('choose_theme'),
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 20),
          ThemeOptionTile(
            title: AppLocalizations.of(context).t('light_theme'),
            value: 'light',
            icon: Icons.light_mode,
            iconColor: Colors.orange,
            currentTheme: currentTheme,
            onThemeChanged: onThemeChanged,
          ),
          const SizedBox(height: 12),
          ThemeOptionTile(
            title: AppLocalizations.of(context).t('dark_theme'),
            value: 'dark',
            icon: Icons.dark_mode,
            iconColor: Colors.grey,
            currentTheme: currentTheme,
            onThemeChanged: onThemeChanged,
          ),
          const SizedBox(height: 12),
          ThemeOptionTile(
            title: AppLocalizations.of(context).t('blue_theme'),
            value: 'blue',
            icon: Icons.water_drop,
            iconColor: Colors.blue,
            currentTheme: currentTheme,
            onThemeChanged: onThemeChanged,
          ),
        ],
      ),
    );
  }
}
