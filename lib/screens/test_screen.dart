import 'package:flutter/material.dart';

import '../logic/scoring.dart';
import '../models/leader_scale.dart';
import '../theme.dart';
import '../widgets/content_frame.dart';
import '../widgets/likert_option.dart';
import 'result_screen.dart';

/// Der Test selbst: eine Aussage pro Bildschirm, fünf Antwortstufen.
///
/// Bewusst ohne State-Management-Paket — der gesamte Zustand sind zwanzig
/// Zahlen, die nur in diesem Screen leben. Die Auswertung liegt getrennt
/// davon in `logic/scoring.dart`.
class TestScreen extends StatefulWidget {
  final ItemBank bank;

  const TestScreen({super.key, required this.bank});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final Map<String, int> _answers = {};
  int _index = 0;

  List<LeaderItem> get _items => widget.bank.allItems;
  LeaderItem get _current => _items[_index];

  void _answer(int value) {
    setState(() {
      _answers[_current.id] = value;
    });

    // Kurze Pause, damit die Auswahl sichtbar wird, bevor es weitergeht.
    Future<void>.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      if (_index < _items.length - 1) {
        setState(() => _index++);
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    final result = calculateResult(widget.bank, _answers);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(result: result),
      ),
    );
  }

  void _back() {
    if (_index == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _index--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final bank = widget.bank;
    final selected = _answers[_current.id];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Progress(current: _index + 1, total: _items.length),
            Expanded(
              child: SingleChildScrollView(
                child: ContentFrame(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUSSAGE ${_index + 1} VON ${_items.length}',
                        style: text.labelSmall,
                      ),
                      const SizedBox(height: 16),
                      Text(_current.text, style: text.headlineSmall),
                      const SizedBox(height: 28),
                      for (int value = bank.scaleMax; value >= 0; value--)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: LikertOption(
                            label: bank.likertLabels[value],
                            selected: selected == value,
                            onTap: () => _answer(value),
                          ),
                        ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _back,
                        child: Text(_index == 0 ? 'Abbrechen' : 'Zurück'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final int current;
  final int total;

  const _Progress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: current / total,
      minHeight: 4,
      backgroundColor: AppColors.ink.withValues(alpha: 0.08),
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
    );
  }
}
