import 'package:flutter/material.dart';

import '../models/leader_scale.dart';
import '../theme.dart';
import 'answer_chip.dart';

/// Eine Aussage als Karte mit allen Antwortstufen als Chip-Reihe darunter —
/// so liegt in der scrollbaren Liste immer nur eine Aussage im Fokus.
class QuestionCard extends StatelessWidget {
  final LeaderItem item;
  final List<String> likertLabels;
  final int? selected;
  final ValueChanged<int> onAnswer;

  const QuestionCard({
    super.key,
    required this.item,
    required this.likertLabels,
    required this.selected,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: selected != null ? 3 : 1,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected != null
              ? AppColors.accent.withValues(alpha: 0.5)
              : AppColors.ink.withValues(alpha: 0.08),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.text,
              textAlign: TextAlign.center,
              style: text.titleMedium,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: List.generate(likertLabels.length, (value) {
                return AnswerChip(
                  label: likertLabels[value],
                  value: value,
                  selected: selected == value,
                  onTap: () => onAnswer(value),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
