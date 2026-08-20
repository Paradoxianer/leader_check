import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:leader_check/logic/scoring.dart';
import 'package:leader_check/models/leader_scale.dart';

/// Lädt die echte Itembank direkt von der Platte — die Auswertung soll gegen
/// die Daten getestet werden, die auch ausgeliefert werden, nicht gegen ein
/// hübsch zurechtgelegtes Fixture.
ItemBank loadBank() {
  final raw = File('assets/items/leader_items_de.json').readAsStringSync();
  return ItemBank.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

/// Beantwortet jedes Item so, dass die Skala maximal in Richtung ihres
/// Messziels ausschlägt (also: maximales Risiko bzw. maximale Stärke).
Map<String, int> answerAllTowardsScale(ItemBank bank) {
  final answers = <String, int>{};
  for (final item in bank.allItems) {
    answers[item.id] = item.reverse ? 0 : bank.scaleMax;
  }
  return answers;
}

void main() {
  late ItemBank bank;

  setUp(() => bank = loadBank());

  group('Itembank', () {
    test('enthält vier Risikoskalen und genau eine Stärkeskala', () {
      final risks =
          bank.scales.where((s) => s.polarity == ScalePolarity.risk).length;
      final strengths =
          bank.scales.where((s) => s.polarity == ScalePolarity.strength).length;
      expect(risks, 4);
      expect(strengths, 1);
    });

    test('Item-IDs sind eindeutig', () {
      final ids = bank.allItems.map((i) => i.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('jede Skala hat mindestens ein umgedrehtes Item', () {
      for (final scale in bank.scales) {
        expect(
          scale.items.any((i) => i.reverse),
          isTrue,
          reason: 'Skala ${scale.id} ohne Gegenpol-Item',
        );
      }
    });
  });

  group('Auswertung', () {
    test('maximale Ausprägung ergibt 100 % auf allen Skalen', () {
      final result = calculateResult(bank, answerAllTowardsScale(bank));
      for (final scaleResult in result.riskResults) {
        expect(scaleResult.percent, 100);
      }
      expect(result.empowermentResult.percent, 100);
    });

    test('minimale Ausprägung ergibt 0 % und gilt als gesund', () {
      final answers = <String, int>{
        for (final item in bank.allItems)
          item.id: item.reverse ? bank.scaleMax : 0,
      };
      final result = calculateResult(bank, answers);

      for (final scaleResult in result.riskResults) {
        expect(scaleResult.percent, 0);
      }
      expect(result.isHealthy, isTrue);
      expect(result.primaryRisk, isNull);
    });

    test('gesund plus hohe Bevollmächtigung ergibt „ermächtigend"', () {
      final answers = <String, int>{};
      for (final scale in bank.scales) {
        for (final item in scale.items) {
          final towardsScale = scale.polarity == ScalePolarity.strength;
          answers[item.id] = towardsScale
              ? (item.reverse ? 0 : bank.scaleMax)
              : (item.reverse ? bank.scaleMax : 0);
        }
      }

      final result = calculateResult(bank, answers);
      expect(result.level, LeaderLevel.empowering);
    });

    test('ein hoher Risikowert verhindert die Einstufung als gesund', () {
      final answers = <String, int>{
        for (final item in bank.allItems)
          item.id: item.reverse ? bank.scaleMax : 0,
      };
      // Die Passivitäts-Items maximal in Richtung Risiko drehen.
      final action = bank.scales.firstWhere((s) => s.id == 'action');
      for (final item in action.items) {
        answers[item.id] = item.reverse ? 0 : bank.scaleMax;
      }

      final result = calculateResult(bank, answers);
      expect(result.isHealthy, isFalse);
      expect(result.level, LeaderLevel.development);
      expect(result.primaryRisk?.scale.id, 'action');
    });

    test('unbeantwortete Items verzerren den Skalenwert nicht', () {
      final scale = bank.scales.first;
      // Nur ein einziges Item beantworten, maximal in Risikorichtung.
      final item = scale.items.first;
      final answers = {item.id: item.reverse ? 0 : bank.scaleMax};

      final result = calculateResult(bank, answers);
      final scaleResult =
          result.riskResults.firstWhere((r) => r.scale.id == scale.id);
      expect(scaleResult.percent, 100);
    });

    test('Risikoverteilung summiert sich auf 100 %', () {
      final result = calculateResult(bank, answerAllTowardsScale(bank));
      final sum = result.riskDistribution.values
          .fold<double>(0, (total, value) => total + value);
      expect(sum, closeTo(100, 0.001));
    });
  });
}
