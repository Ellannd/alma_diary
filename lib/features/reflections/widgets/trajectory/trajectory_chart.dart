import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:alma_diary/features/reflections/engine/trajectory_engine.dart';

class TrajectoryChart extends StatelessWidget {
  final TrajectoryStats stats;

  const TrajectoryChart({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 190,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) {
              return FlLine(
                color: primary.withValues(alpha: 0.08),
                strokeWidth: 1,
              );
            },
          ),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 25,
                getTitlesWidget: (value, _) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.45),
                    ),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) {
                  final labels = [
                    'Consciencia',
                    'Agencia',
                    'Sombra',
                    'Rumiación',
                  ];

                  if (value.toInt() >= labels.length) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[value.toInt()],
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          borderData: FlBorderData(show: false),

          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              barWidth: 4,
              color: primary,

              spots: [
                FlSpot(0, stats.conscienciaDeSi),
                FlSpot(1, stats.agenciaPersonal),
                FlSpot(2, stats.integracionSombra),
                FlSpot(3, stats.rumiacion),
              ],

              dotData: FlDotData(
                show: true,
              ),

              belowBarData: BarAreaData(
                show: true,
                color: primary.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}