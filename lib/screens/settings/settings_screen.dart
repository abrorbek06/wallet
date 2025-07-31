import 'package:flutter/material.dart';

import '../../functions/category_managment.dart';
import '../../models/models.dart';
import '../../models/themes.dart';
import 'fixed/fixed_category_dialog.dart';

// Enhanced Settings Screen with Category Management
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
        padding: EdgeInsets.all(20),
        children: [
          // Theme Selection
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ThemeProvider.getCardColor(),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Theme Selection',
                      style: TextStyle(
                        color: ThemeProvider.getTextColor(),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Choose your preferred app theme',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 20),
                _buildThemeOption('Light Theme', 'light', Icons.light_mode, Colors.orange),
                SizedBox(height: 12),
                _buildThemeOption('Dark Theme', 'dark', Icons.dark_mode, Colors.grey[800]!),
                SizedBox(height: 12),
                _buildThemeOption('Blue Theme', 'blue', Icons.water_drop, Colors.blue),
                // SizedBox(height: 12),
                // _buildThemeOption('Green Theme', 'green', Icons.eco, Colors.green),
                // SizedBox(height: 12),
                // _buildThemeOption('Purple Theme', 'purple', Icons.auto_awesome, Colors.purple),
                // SizedBox(height: 12),
                // _buildThemeOption('Orange Theme', 'orange', Icons.local_fire_department, Colors.orange),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Category Management
          GestureDetector(
            onTap: () => _showCategoryManagementDialog(context),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeProvider.getCardColor(),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: Colors.green,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Category Management',
                            style: TextStyle(
                              color: ThemeProvider.getTextColor(),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage your income and expense categories',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${CategoryManager.incomeCategories.length} Income',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${CategoryManager.expenseCategories.length} Expense',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // SizedBox(height: 24),

          // Data Management
          // Container(
          //   padding: EdgeInsets.all(20),
          //   decoration: BoxDecoration(
          //     color: ThemeProvider.getCardColor(),
          //     borderRadius: BorderRadius.circular(16),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         children: [
          //           Icon(
          //             Icons.storage,
          //             color: Colors.blue,
          //             size: 24,
          //           ),
          //           SizedBox(width: 12),
          //           Text(
          //             'Data Management',
          //             style: TextStyle(
          //               color: ThemeProvider.getTextColor(),
          //               fontSize: 20,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ],
          //       ),
          //       SizedBox(height: 16),
          //
          //       _buildDataOption(
          //         'Export Data',
          //         'Export your transactions to CSV',
          //         Icons.file_download,
          //         Colors.green,
          //             () => _exportData(),
          //       ),
          //       SizedBox(height: 12),
          //       _buildDataOption(
          //         'Import Data',
          //         'Import transactions from CSV',
          //         Icons.file_upload,
          //         Colors.blue,
          //             () => _importData(),
          //       ),
          //       SizedBox(height: 12),
          //       _buildDataOption(
          //         'Backup Data',
          //         'Create a backup of your data',
          //         Icons.backup,
          //         Colors.orange,
          //             () => _backupData(),
          //       ),
          //       SizedBox(height: 12),
          //       _buildDataOption(
          //         'Clear All Data',
          //         'Delete all transactions and reset app',
          //         Icons.delete_forever,
          //         Colors.red,
          //             () => _showClearDataDialog(),
          //       ),
          //     ],
          //   ),
          // ),
          //
          // SizedBox(height: 24),

          // Notifications

          // Container(
          //   padding: EdgeInsets.all(20),
          //   decoration: BoxDecoration(
          //     color: ThemeProvider.getCardColor(),
          //     borderRadius: BorderRadius.circular(16),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         children: [
          //           Icon(
          //             Icons.notifications,
          //             color: Colors.purple,
          //             size: 24,
          //           ),
          //           SizedBox(width: 12),
          //           Text(
          //             'Notifications',
          //             style: TextStyle(
          //               color: ThemeProvider.getTextColor(),
          //               fontSize: 20,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ],
          //       ),
          //       SizedBox(height: 16),
          //
          //       _buildNotificationOption(
          //         'Budget Alerts',
          //         'Get notified when you exceed budget limits',
          //         true,
          //             (value) => {},
          //       ),
          //       SizedBox(height: 12),
          //       _buildNotificationOption(
          //         'Daily Reminders',
          //         'Remind me to log daily expenses',
          //         false,
          //             (value) => {},
          //       ),
          //       SizedBox(height: 12),
          //       _buildNotificationOption(
          //         'Weekly Reports',
          //         'Send weekly spending summary',
          //         true,
          //             (value) => {},
          //       ),
          //     ],
          //   ),
          // ),

          SizedBox(height: 24),

          // App Info
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ThemeProvider.getCardColor(),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'App Information',
                      style: TextStyle(
                        color: ThemeProvider.getTextColor(),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildInfoRow('Versiyasi', '1.0.0'),
                _buildInfoRow('Developer', 'Isayev Abrorbek'),
                _buildInfoRow('Last Updated', 'June 2025'),
                // _buildInfoRow('Features', 'Advanced Charts & Categories'),
                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAboutDialog(),
                        icon: Icon(Icons.help_outline, size: 18),
                        label: Text('Help & Support', style: TextStyle(fontSize: 11),),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ThemeProvider.getTextColor(),
                          side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rateApp(),
                        icon: Icon(Icons.star_outline, size: 18),
                        label: Text('Rate App'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ThemeProvider.getTextColor(),
                          side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String title, String value, IconData icon, Color iconColor) {
    return GestureDetector(
      onTap: () {
        widget.onThemeChanged(value);
        ThemeProvider.setTheme(value);
        setState(() {}); // Refresh UI with new theme
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.currentTheme == value
              ? ThemeProvider.getPrimaryColor().withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.currentTheme == value
                ? ThemeProvider.getPrimaryColor()
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: ThemeProvider.getTextColor(),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: widget.currentTheme,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  widget.onThemeChanged(newValue);
                  ThemeProvider.setTheme(newValue);
                  setState(() {});
                }
              },
              activeColor: ThemeProvider.getPrimaryColor(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildDataOption(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       padding: EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: color.withOpacity(0.05),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: color.withOpacity(0.2)),
  //       ),
  //       child: Row(
  //         children: [
  //           Container(
  //             padding: EdgeInsets.all(8),
  //             decoration: BoxDecoration(
  //               color: color.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: Icon(icon, color: color, size: 20),
  //           ),
  //           SizedBox(width: 16),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   title,
  //                   style: TextStyle(
  //                     color: ThemeProvider.getTextColor(),
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //                 Text(
  //                   subtitle,
  //                   style: TextStyle(
  //                     color: Colors.grey[400],
  //                     fontSize: 12,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Icon(
  //             Icons.arrow_forward_ios,
  //             color: Colors.grey[400],
  //             size: 16,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildNotificationOption(String title, String subtitle, bool value, Function(bool) onChanged) {
  //   return Container(
  //     padding: EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.purple.withOpacity(0.05),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.purple.withOpacity(0.2)),
  //     ),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 title,
  //                 style: TextStyle(
  //                   color: ThemeProvider.getTextColor(),
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //               Text(
  //                 subtitle,
  //                 style: TextStyle(
  //                   color: Colors.grey[400],
  //                   fontSize: 12,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Switch(
  //           value: value,
  //           onChanged: onChanged,
  //           activeColor: Colors.purple,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: ThemeProvider.getTextColor(),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CategoryManagementDialog(
        onAddCategory: (category) {
          widget.onAddCategory(category);
          setState(() {}); // Refresh the category counts
        },
        onRemoveCategory: (categoryId, isIncome) {
          widget.onRemoveCategory(categoryId, isIncome);
          CategoryManager.removeCategory(categoryId, isIncome);
          setState(() {}); // Refresh the category counts
        },
      ),
    );
  }

  void _exportData() {
    // TODO: Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export functionality coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _importData() {
    // TODO: Implement data import functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Import functionality coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // void _backupData() {
  //   // TODO: Implement data backup functionality
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Backup functionality coming soon!'),
  //       backgroundColor: Colors.orange,
  //     ),
  //   );
  // }

  // void _showClearDataDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: ThemeProvider.getCardColor(),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: Text(
  //         'Clear All Data',
  //         style: TextStyle(
  //           color: ThemeProvider.getTextColor(),
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(
  //             Icons.warning_amber_rounded,
  //             color: Colors.red,
  //             size: 48,
  //           ),
  //           SizedBox(height: 16),
  //           Text(
  //             'This will permanently delete all your transactions, categories, and settings. This action cannot be undone.',
  //             style: TextStyle(
  //               color: ThemeProvider.getTextColor(),
  //               fontSize: 16,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'Cancel',
  //             style: TextStyle(color: Colors.grey[400]),
  //           ),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             // TODO: Implement clear all data functionality
  //             Navigator.pop(context);
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(
  //                 content: Text('Clear data functionality coming soon!'),
  //                 backgroundColor: Colors.red,
  //               ),
  //             );
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.red,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //           child: Text(
  //             'Clear All',
  //             style: TextStyle(color: Colors.white),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeProvider.getCardColor(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'About Finance Pro',
          style: TextStyle(
            color: ThemeProvider.getTextColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Finance Pro is a comprehensive expense tracking app designed to help you manage your finances effectively.',
              style: TextStyle(
                color: ThemeProvider.getTextColor(),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(
                color: ThemeProvider.getTextColor(),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Track income and expenses\n• Categorize transactions\n• Visual charts and statistics\n• Multiple themes\n• Card management\n• Budget tracking',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    // TODO: Implement app rating functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for your interest! Rating functionality coming soon.'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}