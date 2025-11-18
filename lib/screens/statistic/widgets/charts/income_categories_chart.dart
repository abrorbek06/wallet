import 'package:app/functions/category_managment.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app/models/models.dart';

import 'package:app/models/themes.dart';
import '../../../../l10n/app_localizations.dart';

class IncomeCategoriesChart extends StatelessWidget {
  final Map<String, double> incomeByCategory;

  const IncomeCategoriesChart({super.key, required this.incomeByCategory});

  @override
  Widget build(BuildContext context) {
    if (incomeByCategory.isEmpty) {
      return _buildEmptyState(context);
    }

    // total computed inside chart builder to keep scope local

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
              _buildHeader(context),
              SizedBox(height: 20),
              SizedBox(height: 200, child: PieChart(_buildChartData(context))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            AppLocalizations.of(context).t('no_income_data'),
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.category, color: Colors.green, size: 24),
        SizedBox(width: 12),
        Text(
          AppLocalizations.of(context).t('income_by_category'),
          style: TextStyle(
            color: ThemeProvider.getTextColor(),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  PieChartData _buildChartData(BuildContext context) {
    final totalIncome = incomeByCategory.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    return PieChartData(
      sections:
          incomeByCategory.entries.map((entry) {
            final category =
                CategoryManager.getCategoryById(entry.key) ??
                Category(
                  id: '',
                  name: AppLocalizations.of(context).t('other'),
                  icon: Icons.category,
                  color: Colors.grey,
                  type: 'income',
                );
            final percentage =
                totalIncome > 0 ? (entry.value / totalIncome) * 100 : 0.0;

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
