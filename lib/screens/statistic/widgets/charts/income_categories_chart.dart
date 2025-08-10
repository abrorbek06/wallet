import 'package:app/functions/category_managment.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app/models/models.dart';

import 'package:app/models/themes.dart';

class IncomeCategoriesChart extends StatelessWidget {
  final Map<String, double> incomeByCategory;

  const IncomeCategoriesChart({super.key, required this.incomeByCategory});

  @override
  Widget build(BuildContext context) {
    if (incomeByCategory.isEmpty) {
      return _buildEmptyState();
    }

    final totalIncome = incomeByCategory.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ThemeProvider.getCardColor(),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              SizedBox(height: 200, child: PieChart(_buildChartData())),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No income data available',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.category, color: Colors.green, size: 24),
        SizedBox(width: 12),
        Text(
          'Income by Category',
          style: TextStyle(
            color: ThemeProvider.getTextColor(),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  PieChartData _buildChartData() {
    return PieChartData(
      sections:
          incomeByCategory.entries.map((entry) {
            final category =
                CategoryManager.getCategoryById(entry.key) ??
                Category(
                  id: '',
                  name: 'Other',
                  icon: Icons.category,
                  color: Colors.grey,
                  type: 'income',
                );
            final total = incomeByCategory.values.fold(
              0.0,
              (sum, amount) => sum + amount,
            );
            final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;

            return PieChartSectionData(
              value: entry.value,
              color: category.color,
              title: '${percentage.toStringAsFixed(1)}%',
              radius: 60,
              titleStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          }).toList(),
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      pieTouchData: PieTouchData(enabled: true),
    );
  }
}
