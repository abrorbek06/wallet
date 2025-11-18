import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app/models/themes.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:app/services/currency_service.dart';

class IncomeExpensePieChart extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const IncomeExpensePieChart({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalIncome + totalExpense;
    final incomePercentage = total > 0 ? (totalIncome / total) * 100 : 0.0;
    final expensePercentage = total > 0 ? (totalExpense / total) * 100 : 0.0;

    return Container(
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
              Icon(Icons.pie_chart, color: Colors.purple, size: 24),
              SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).t('income_vs_expenses'),
                style: TextStyle(
                  color: ThemeProvider.getTextColor(),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        if (totalIncome > 0)
                          PieChartSectionData(
                            value: totalIncome,
                            color: Colors.green,
                            title: '${incomePercentage.toStringAsFixed(1)}%',
                            radius: 80,
                            titleStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        if (totalExpense > 0)
                          PieChartSectionData(
                            value: totalExpense,
                            color: Colors.red,
                            title: '${expensePercentage.toStringAsFixed(1)}%',
                            radius: 80,
                            titleStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      pieTouchData: PieTouchData(enabled: true),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (totalIncome > 0)
                _buildLegendItem(
                  context,
                  AppLocalizations.of(context).t('income'),
                  Colors.green,
                  totalIncome,
                ),
              if (totalIncome > 0 && totalExpense > 0) SizedBox(height: 12),
              if (totalExpense > 0)
                _buildLegendItem(
                  context,
                  AppLocalizations.of(context).t('expenses'),
                  Colors.red,
                  totalExpense,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    double amount,
  ) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: ThemeProvider.getTextColor(),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              CurrencyService.instance.formatAmount(amount),
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
