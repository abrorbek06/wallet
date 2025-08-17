import 'package:app/screens/settings/dialogs/about_dialog.dart';
import 'package:app/screens/settings/widgets/category_section.dart';
import 'package:app/screens/settings/widgets/info_section.dart';
import 'package:app/screens/settings/widgets/theme_section.dart';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../models/themes.dart';
import '../../functions/category_managment.dart';

class SettingsScreen extends StatefulWidget {
  final String currentTheme;
  final Function(String) onThemeChanged;
  final Function(Category) onAddCategory;
  final Function(String, bool) onRemoveCategory;

  const SettingsScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.onAddCategory,
    required this.onRemoveCategory,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    CategoryManager.loadSavedCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: ThemeProvider.getBackgroundColor(),
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: ThemeProvider.getTextColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ThemeSection(
            currentTheme: widget.currentTheme,
            onThemeChanged: (val) {
              widget.onThemeChanged(val);
              ThemeProvider.setTheme(val);
              setState(() {});
            },
          ),
          const SizedBox(height: 24),
          CategorySection(
            onAddCategory: (cat) {
              widget.onAddCategory(cat);
              setState(() {});
            },
            onRemoveCategory: (id, isIncome) {
              widget.onRemoveCategory(id, isIncome);
              setState(() {});
            },
          ),
          const SizedBox(height: 24),
          InfoSection(onRateApp: _rateApp, onHelpPressed: _showAboutDialog),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutAppDialog(context);
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rating functionality coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
