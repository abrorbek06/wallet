import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../models/themes.dart';

class AddCategoryDialog extends StatefulWidget {
  final Function(Category) onAddCategory;
  final bool isIncome;

  const AddCategoryDialog({
    super.key,
    required this.onAddCategory,
    this.isIncome = true,
  });

  @override
  _AddCategoryDialogState createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = Colors.blue;

  final List<IconData> _availableIcons = [
    Icons.category, Icons.work, Icons.business, Icons.computer, Icons.trending_up,
    Icons.restaurant, Icons.directions_car, Icons.shopping_bag, Icons.receipt,
    Icons.movie, Icons.local_hospital, Icons.school, Icons.home, Icons.flight,
    Icons.fitness_center, Icons.pets, Icons.music_note, Icons.book,
    Icons.sports_esports, Icons.coffee, Icons.local_gas_station, Icons.phone,
  ];

  final List<Color> _availableColors = [
    Colors.blue, Colors.green, Colors.red, Colors.purple, Colors.orange,
    Colors.pink, Colors.teal, Colors.indigo, Colors.amber, Colors.cyan,
    Colors.lime, Colors.deepOrange, Colors.brown, Colors.blueGrey,
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ThemeProvider.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add ${widget.isIncome ? 'Income' : 'Expense'} Category',
                      style: TextStyle(
                        color: ThemeProvider.getTextColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[400]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Preview
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _selectedColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _selectedColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(_selectedIcon, color: _selectedColor, size: 24),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _nameController.text.isEmpty ? 'Category Preview' : _nameController.text,
                              style: TextStyle(
                                color: ThemeProvider.getTextColor(),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Category Name Input
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: ThemeProvider.getTextColor()),
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.label, color: Colors.grey),
                        hintText: 'Enter category name',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: ThemeProvider.getPrimaryColor()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Icon Selection
                    Text(
                      'Select Icon',
                      style: TextStyle(
                        color: ThemeProvider.getTextColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),

                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: GridView.count(
                          crossAxisCount: 6,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          children: _availableIcons.map((icon) {
                            final isSelected = icon == _selectedIcon;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedIcon = icon),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? _selectedColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? _selectedColor : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  color: isSelected ? _selectedColor : Colors.grey[400],
                                  size: 20,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Color Selection
                    Text(
                      'Select Color',
                      style: TextStyle(
                        color: ThemeProvider.getTextColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),

                    Container(
                      height: 85,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: GridView.count(
                          crossAxisCount: 7,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          children: _availableColors.map((color) {
                            final isSelected = color == _selectedColor;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColor = color),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ] : null,
                                ),
                                child: isSelected ? Icon(Icons.check, color: Colors.white, size: 16) : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.trim().isNotEmpty) {
                        final category = Category(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _nameController.text.trim(),
                          icon: _selectedIcon,
                          color: _selectedColor,
                          type: widget.isIncome ? 'income' : 'expense',
                        );

                        widget.onAddCategory(category);
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a category name'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Add Category',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}