import 'package:flutter/material.dart';

import '../data/item_bank_loader.dart';
import '../models/leader_scale.dart';
import '../theme.dart';
import '../widgets/content_frame.dart';
import 'test_screen.dart';

/// Einstieg: erklärt in drei Sätzen, worum es geht, und startet den Test.
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late Future<ItemBank> _bank;

  @override
  void initState() {
    super.initState();
    _bank = ItemBankLoader.load();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: ContentFrame(
          child: FutureBuilder<ItemBank>(
            future: _bank,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'Die Fragen konnten nicht geladen werden. '
                  'Lade die Seite neu.',
                  style: text.bodyLarge,
                );
              }

              final bank = snapshot.data;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LEITERSCHAFTSKURS', style: text.labelSmall),
                  const SizedBox(height: 12),
                  Text('Welcher Leiter bin ich\ngerade?',
                      style: text.displaySmall),
                  const SizedBox(height: 24),
                  Text(
                    'Jeder Leitungsstil bringt eine bestimmte Sorte '
                    'Mitarbeiter hervor. Dieser Kurz-Check zeigt dir, welche '
                    'Muster bei dir gerade am stärksten wirken — und was der '
                    'nächste konkrete Schritt wäre.',
                    style: text.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  _Facts(itemCount: bank?.itemCount),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: bank == null
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => TestScreen(bank: bank),
                              ),
                            ),
                    child: const Text('Check starten'),
                  ),
                  const SizedBox(height: 40),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Text(
                    'Antworte spontan und so, wie es tatsächlich ist — nicht '
                    'so, wie es sein sollte. Das Ergebnis bleibt auf deinem '
                    'Gerät; es wird nichts gespeichert und nichts gesendet.',
                    style: text.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ein Selbstreflexions-Werkzeug für den Kursgebrauch, kein '
                    'geprüftes psychologisches Testverfahren. Die Typologie '
                    'ist angelehnt an den Craig Groeschel Leadership Podcast, '
                    'Folgen 1 und 2.',
                    style: text.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Facts extends StatelessWidget {
  final int? itemCount;

  const _Facts({this.itemCount});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: AppColors.muted);

    return Row(
      children: [
        Text('${itemCount ?? '–'} Aussagen', style: style),
        const SizedBox(width: 16),
        Text('·', style: style),
        const SizedBox(width: 16),
        Text('rund 4 Minuten', style: style),
      ],
    );
  }
}
