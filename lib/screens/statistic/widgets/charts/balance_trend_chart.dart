import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app/models/themes.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:app/services/currency_service.dart';
import 'package:intl/intl.dart';

class BalanceTrendChart extends StatelessWidget {
  final List<FlSpot> balanceTrendData;
  final DateTime Function(int index) getDateForIndex;

  const BalanceTrendChart({
    super.key,
    required this.balanceTrendData,
    required this.getDateForIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (balanceTrendData.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeProvider.getCardColor(),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.show_chart, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).t('no_trend_data'),
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final minY = balanceTrendData
        .map((spot) => spot.y)
        .reduce((a, b) => a < b ? a : b);
    final maxY = balanceTrendData
        .map((spot) => spot.y)
        .reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    final padding = range * 0.1; //
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
              Icon(
                Icons.show_chart,
                color: ThemeProvider.getPrimaryColor(),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).t('balance_trend'),
                style: TextStyle(
                  color: ThemeProvider.getTextColor(),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval:
                      maxY - minY > 0 ? (maxY - minY) / 4 : 1000,
                  verticalInterval:
                      balanceTrendData.length > 1
                          ? (balanceTrendData.length - 1).toDouble() / 4
                          : 1,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                  getDrawingVerticalLine:
                      (value) => FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval:
                          balanceTrendData.length > 1
                              ? (balanceTrendData.length - 1).toDouble() / 4
                              : 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < balanceTrendData.length) {
                          final date = getDateForIndex(value.toInt());
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${date.month}/${date.day}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY - minY > 0 ? (maxY - minY) / 4 : 1000,
                      reservedSize: 80,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final curr = CurrencyService.instance.currency;
                        String label;
                        if (curr == Currency.USD) {
                          // Compact currency with $ symbol, e.g. $1.5K
                          final fmt = NumberFormat.compactCurrency(
                            locale: 'en_US',
                            symbol: r'$',
                            decimalDigits: 0,
                          );
                          label = fmt.format(value);
                        } else {
                          // UZS: show thousands with K, e.g. 500K; for very large values use compact (M)
                          final thousands = value / 1000.0;
                          if (thousands.abs() >= 1000) {
                            // Use compact notation for millions/billions
                            final fmt = NumberFormat.compact(locale: 'en_US');
                            label = fmt.format(value);
                          } else {
                            label =
                                (thousands % 1 == 0)
                                    ? '${thousands.toInt()}K'
                                    : '${thousands.toStringAsFixed(1)}K';
                          }
                        }
                        // Ensure UZS labels do not contain any dollar sign or the word "so'm"
                        if (curr == Currency.UZS) {
                          label =
                              label.replaceAll(RegExp(r"\$|so'm"), '').trim();
                        }

                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Text(
                                label,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: (balanceTrendData.length - 1).toDouble(),
                minY: minY - padding,
                maxY: maxY + padding,
                lineBarsData: [
                  LineChartBarData(
                    spots: balanceTrendData,
                    isCurved: true,
                    color: ThemeProvider.getPrimaryColor(),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: ThemeProvider.getPrimaryColor(),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: ThemeProvider.getPrimaryColor().withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final date = getDateForIndex(barSpot.x.toInt());
                        return LineTooltipItem(
                          '${date.month}/${date.day}\n${CurrencyService.instance.formatAmount(barSpot.y)}',
                          TextStyle(
                            color: ThemeProvider.getTextColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
