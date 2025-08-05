import 'package:flutter/material.dart';
import '../../../models/themes.dart';

class ThemeOptionTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String currentTheme;
  final Function(String) onThemeChanged;

  const ThemeOptionTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onThemeChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: currentTheme == value
              ? ThemeProvider.getPrimaryColor().withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: currentTheme == value
                ? ThemeProvider.getPrimaryColor()
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: ThemeProvider.getTextColor(),
                  fontSize: 16,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: currentTheme,
              onChanged: (val) => onThemeChanged(val!),
              activeColor: ThemeProvider.getPrimaryColor(),
            ),
          ],
        ),
      ),
    );
  }
}
