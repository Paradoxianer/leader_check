import 'package:flutter/material.dart';

import '../theme.dart';

/// Eine Antwortstufe als kompakter Chip: Label über Zahl, in einer Reihe mit
/// den anderen Stufen. Zwingt zur Wahl einer Richtung, weil keine Stufe als
/// "die mittlere" hervorgehoben ist.
class AnswerChip extends StatelessWidget {
  final String label;
  final int value;
  final bool selected;
  final VoidCallback? onTap;

  const AnswerChip({
    super.key,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accent : AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 68,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? AppColors.accent
                  : AppColors.ink.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.2,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
