import 'package:flutter/material.dart';

import '../logic/scoring.dart';
import '../models/leader_scale.dart';
import '../theme.dart';
import '../widgets/question_card.dart';
import 'result_screen.dart';

/// Der Test selbst: eine scrollbare Kartenliste, eine Aussage pro Karte, mit
/// sechs Antwortstufen ohne exakte Mitte.
///
/// Bewusst ohne State-Management-Paket — der gesamte Zustand sind zwanzig
/// Zahlen, die nur in diesem Screen leben. Die Auswertung liegt getrennt
/// davon in `logic/scoring.dart`. `CarouselView` kommt direkt aus dem
/// Flutter-SDK, keine zusätzliche Abhängigkeit.
class TestScreen extends StatefulWidget {
  final ItemBank bank;

  const TestScreen({super.key, required this.bank});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  static const double _itemExtent = 300;

  final Map<String, int> _answers = {};
  final CarouselController _controller = CarouselController();

  List<LeaderItem> get _items => widget.bank.allItems;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _answer(LeaderItem item, int value) {
    setState(() => _answers[item.id] = value);

    // Kurze Pause, damit die Auswahl sichtbar wird, bevor es weitergeht.
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      final nextIndex = _items.indexWhere((i) => !_answers.containsKey(i.id));
      if (nextIndex == -1) {
        _showResult();
        return;
      }
      _controller.animateTo(
        nextIndex * _itemExtent,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
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

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final answered = _answers.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('$answered von ${items.length} beantwortet'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: LinearProgressIndicator(
                value: answered / items.length,
                minHeight: 4,
                backgroundColor: AppColors.ink.withValues(alpha: 0.08),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: kContentMaxWidth),
                  child: CarouselView(
                    controller: _controller,
                    scrollDirection: Axis.vertical,
                    itemExtent: _itemExtent,
                    shrinkExtent: 230,
                    itemSnapping: true,
                    enableSplash: false,
                    backgroundColor: Colors.transparent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    children: [
                      for (final item in items)
                        QuestionCard(
                          item: item,
                          likertLabels: widget.bank.likertLabels,
                          selected: _answers[item.id],
                          onAnswer: (value) => _answer(item, value),
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
