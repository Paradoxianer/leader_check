// Projekt ist bewusst web-only (kein android/ios/desktop-Target), daher ist
// dart:html hier der richtige, abhängigkeitsfreie Weg für den Bild-Download.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../logic/scoring.dart';
import '../theme.dart';
import '../widgets/content_frame.dart';
import '../widgets/radar_chart.dart';
import '../widgets/scale_axis.dart';

/// Ergebnisansicht: erst die Einordnung in einem Satz, dann die einzelnen
/// Skalen, zuletzt genau ein nächster Schritt.
class ResultScreen extends StatefulWidget {
  final TestResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final GlobalKey _captureKey = GlobalKey();
  bool _isSaving = false;

  TestResult get result => widget.result;

  /// Rendert den erfassten Bereich als PNG und stößt im Browser den
  /// Download an. Nur Flutter-SDK-Bordmittel (RepaintBoundary, dart:html) —
  /// das Projekt ist bewusst web-only, daher unproblematisch.
  Future<void> _saveAsImage() async {
    setState(() => _isSaving = true);
    try {
      final boundary = _captureKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final blob = html.Blob([bytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'leitertyp-check-ergebnis.png')
        ..click();
      html.Url.revokeObjectUrl(url);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
              RepaintBoundary(
                key: _captureKey,
                child: Container(
                  color: AppColors.surface,
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

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: RadarChart(
                    labels: [
                      for (final r in result.riskResults) r.scale.name,
                    ],
                    values: [
                      for (final r in result.riskResults) r.percent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).popUntil(
                      (route) => route.isFirst,
                    ),
                    child: const Text('Noch einmal'),
                  ),
                  OutlinedButton(
                    onPressed: _isSaving ? null : _saveAsImage,
                    child: Text(
                      _isSaving ? 'Speichert …' : 'Als Bild speichern',
                    ),
                  ),
                ],
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

    // ClipRRect statt eines Border mit gemischten Seitenfarben: Flutter
    // kann bei borderRadius nur einfarbige Border zeichnen, sonst wirft
    // BoxBorder.paint() bei jedem Repaint eine Exception.
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.ink.withValues(alpha: 0.08)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: AppColors.accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scaleName.toUpperCase(), style: text.labelSmall),
                    const SizedBox(height: 8),
                    Text(step, style: text.bodyLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
