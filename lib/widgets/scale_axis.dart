import 'package:flutter/material.dart';

import '../theme.dart';

/// Eine Skala als Achse zwischen zwei Polen, mit einem Marker an der Stelle,
/// an der man gelandet ist.
///
/// Ein Balken würde suggerieren „mehr ist mehr". Hier geht es aber um eine
/// Position zwischen zwei Haltungen — und die Pole müssen mit dranstehen,
/// sonst ist die Zahl bedeutungslos.
class ScaleAxis extends StatelessWidget {
  /// Position 0–100, gemessen vom linken Pol aus.
  final double percent;
  final String leftLabel;
  final String rightLabel;
  final Color markerColor;

  const ScaleAxis({
    super.key,
    required this.percent,
    required this.leftLabel,
    required this.rightLabel,
    required this.markerColor,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final position = (percent / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const markerSize = 14.0;
            final travel = constraints.maxWidth - markerSize;

            return SizedBox(
              height: markerSize,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.healthy.withValues(alpha: 0.35),
                            AppColors.risk.withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: travel * position,
                    child: Container(
                      width: markerSize,
                      height: markerSize,
                      decoration: BoxDecoration(
                        color: markerColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(leftLabel, style: text.labelSmall),
            Text(rightLabel, style: text.labelSmall),
          ],
        ),
      ],
    );
  }
}
