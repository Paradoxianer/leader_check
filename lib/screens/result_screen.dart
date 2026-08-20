import 'package:flutter/material.dart';

import '../logic/scoring.dart';
import '../theme.dart';
import '../widgets/content_frame.dart';
import '../widgets/scale_axis.dart';

/// Ergebnisansicht: erst die Einordnung in einem Satz, dann die einzelnen
/// Skalen, zuletzt genau ein nächster Schritt.
class ResultScreen extends StatelessWidget {
  final TestResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final primary = result.primaryRisk;

    return Scaffold(
      body: SingleChildScrollView(
        child: ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DEIN ERGEBNIS', style: text.labelSmall),
              const SizedBox(height: 12),
              Text(_headline(), style: text.displaySmall),
              const SizedBox(height: 20),
              Text(_summary(), style: text.bodyLarge),
              const SizedBox(height: 40),

              Text('Die vier Muster', style: text.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Je weiter rechts, desto stärker wirkt das Muster gerade.',
                style: text.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 24),

              for (final scaleResult in result.ranked) ...[
                _ScaleBlock(result: scaleResult),
                const SizedBox(height: 28),
              ],

              const Divider(height: 40),

              Text('Die Stufe darüber', style: text.titleMedium),
              const SizedBox(height: 12),
              _EmpowermentBlock(result: result.empowermentResult),

              const Divider(height: 40),

              if (primary != null) ...[
                Text('Dein nächster Schritt', style: text.titleMedium),
                const SizedBox(height: 12),
                _NextStepCard(
                  scaleName: primary.scale.name,
                  step: primary.scale.nextStep,
                ),
              ] else ...[
                Text('Dein nächster Schritt', style: text.titleMedium),
                const SizedBox(height: 12),
                _NextStepCard(
                  scaleName: result.empowermentResult.scale.name,
                  step: result.empowermentResult.scale.nextStep,
                ),
              ],

              const SizedBox(height: 32),
              Text(
                'Der ehrlichste Test ist der nächste Schritt: Stell drei '
                'Leuten aus deinem Team dieselben Fragen über dich. Die '
                'Differenz zwischen beiden Bildern ist das eigentliche '
                'Ergebnis.',
                style: text.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 28),
              OutlinedButton(
                onPressed: () => Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                ),
                child: const Text('Noch einmal'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _headline() {
    switch (result.level) {
      case LeaderLevel.empowering:
        return 'Du machst\nandere zu Leitern.';
      case LeaderLevel.healthy:
        return 'Ein gesunder\nLeitungsstil.';
      case LeaderLevel.development:
        return 'Ein Muster\nsticht heraus.';
    }
  }

  String _summary() {
    switch (result.level) {
      case LeaderLevel.empowering:
        return 'Keines der vier Risikomuster ist bei dir stark ausgeprägt, '
            'und du gibst Entscheidungsspielraum wirklich ab. Genau daran '
            'erkennt man eine Kultur, in der auch andere Ja sagen dürfen.';
      case LeaderLevel.healthy:
        return 'Keines der vier Muster ist bei dir stark ausgeprägt. Deine '
            'Leute können dir folgen, ohne sich absichern zu müssen. Die '
            'Stufe darüber wäre, dass aus deinen Mitarbeitern selbst Leiter '
            'werden.';
      case LeaderLevel.development:
        final top = result.ranked.first;
        return 'Am deutlichsten wirkt bei dir gerade das Muster '
            '„${top.scale.riskLabel}". Es bringt tendenziell '
            '${top.scale.followerEffect} hervor. Das ist kein Urteil über '
            'dich, sondern eine Momentaufnahme — und eine gute Grundlage für '
            'ein ehrliches Gespräch mit deinem Team.';
    }
  }
}

class _ScaleBlock extends StatelessWidget {
  final ScaleResult result;

  const _ScaleBlock({required this.result});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = AppColors.forRisk(result.percent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(result.scale.name, style: text.titleMedium),
            Text(
              '${result.percent.round()} %',
              style: text.titleMedium?.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ScaleAxis(
          percent: result.percent,
          leftLabel: result.scale.healthyLabel.toUpperCase(),
          rightLabel: result.scale.riskLabel.toUpperCase(),
          markerColor: color,
        ),
        const SizedBox(height: 12),
        Text(result.text, style: text.bodyMedium),
      ],
    );
  }
}

class _EmpowermentBlock extends StatelessWidget {
  final ScaleResult result;

  const _EmpowermentBlock({required this.result});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(result.scale.name, style: text.titleMedium),
            Text(
              '${result.percent.round()} %',
              style: text.titleMedium?.copyWith(color: AppColors.accent),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ScaleAxis(
          percent: result.percent,
          leftLabel: result.scale.riskLabel.toUpperCase(),
          rightLabel: result.scale.healthyLabel.toUpperCase(),
          markerColor: AppColors.accent,
        ),
        const SizedBox(height: 12),
        Text(result.text, style: text.bodyMedium),
      ],
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final String scaleName;
  final String step;

  const _NextStepCard({required this.scaleName, required this.step});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(color: AppColors.accent, width: 3),
          top: BorderSide(color: AppColors.ink.withValues(alpha: 0.08)),
          right: BorderSide(color: AppColors.ink.withValues(alpha: 0.08)),
          bottom: BorderSide(color: AppColors.ink.withValues(alpha: 0.08)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(scaleName.toUpperCase(), style: text.labelSmall),
          const SizedBox(height: 8),
          Text(step, style: text.bodyLarge),
        ],
      ),
    );
  }
}
