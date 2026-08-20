import '../models/leader_scale.dart';

/// Ergebnis einer einzelnen Skala.
class ScaleResult {
  final LeaderScale scale;

  /// 0–100. Bei Risikoskalen: wie stark das Risiko ausgeprägt ist.
  /// Bei Stärkeskalen: wie stark die Stärke ausgeprägt ist.
  final double percent;

  const ScaleResult({required this.scale, required this.percent});

  /// Grobe Einordnung. Die Schwellen sind bewusst weit gesetzt: vier Items
  /// pro Skala tragen keine feinere Unterscheidung.
  ScaleLevel get level {
    if (percent < 30) return ScaleLevel.low;
    if (percent < 55) return ScaleLevel.mid;
    return ScaleLevel.high;
  }

  String get text {
    switch (level) {
      case ScaleLevel.low:
        return scale.lowText;
      case ScaleLevel.mid:
        return scale.midText;
      case ScaleLevel.high:
        return scale.highText;
    }
  }
}

enum ScaleLevel { low, mid, high }

/// Gesamteinordnung nach dem Modell: „gesund" ist kein eigener Typ, sondern
/// das Ergebnis niedriger Werte auf allen vier Risikoskalen. „Ermächtigend"
/// ist die Stufe darüber und wird erst geprüft, wenn „gesund" erreicht ist.
enum LeaderLevel { development, healthy, empowering }

/// Vollständiges Testergebnis.
class TestResult {
  final int itembankVersion;
  final List<ScaleResult> riskResults;
  final ScaleResult empowermentResult;

  const TestResult({
    required this.itembankVersion,
    required this.riskResults,
    required this.empowermentResult,
  });

  /// Risikoskalen, absteigend nach Ausprägung.
  List<ScaleResult> get ranked {
    final sorted = List<ScaleResult>.from(riskResults);
    sorted.sort((a, b) {
      final byPercent = b.percent.compareTo(a.percent);
      return byPercent != 0 ? byPercent : a.scale.name.compareTo(b.scale.name);
    });
    return sorted;
  }

  /// Die deutlichste Baustelle — oder null, wenn alles im grünen Bereich ist.
  ScaleResult? get primaryRisk {
    final top = ranked.first;
    return top.level == ScaleLevel.low ? null : top;
  }

  bool get isHealthy =>
      riskResults.every((r) => r.level == ScaleLevel.low);

  LeaderLevel get level {
    if (!isHealthy) return LeaderLevel.development;
    return empowermentResult.percent >= 60
        ? LeaderLevel.empowering
        : LeaderLevel.healthy;
  }

  /// Relative Verteilung der vier Risiken, summiert auf 100 %.
  ///
  /// Das beantwortet die Frage „wie viel Prozent von welchem Typ steckt in
  /// mir" — allerdings *relativ*: Wer überall niedrig liegt, bekommt hier
  /// trotzdem eine Verteilung. Die absoluten Werte in [riskResults] sind die
  /// wichtigere Zahl; diese Verteilung zeigt nur die Schwerpunkte.
  Map<String, double> get riskDistribution {
    final total = riskResults.fold<double>(0, (sum, r) => sum + r.percent);
    if (total <= 0) {
      return {for (final r in riskResults) r.scale.id: 0};
    }
    return {
      for (final r in riskResults) r.scale.id: r.percent / total * 100,
    };
  }
}

/// Rechnet Antworten in ein Ergebnis um. Reine Funktion ohne Seiteneffekte —
/// dadurch in `test/scoring_test.dart` direkt prüfbar.
///
/// [answers] bildet Item-ID auf den Rohwert 0..scaleMax ab. Fehlende Items
/// werden als „nicht beantwortet" behandelt und aus der Berechnung der
/// jeweiligen Skala herausgenommen.
TestResult calculateResult(ItemBank bank, Map<String, int> answers) {
  final results = <String, ScaleResult>{};

  for (final scale in bank.scales) {
    double sum = 0;
    int answered = 0;

    for (final item in scale.items) {
      final raw = answers[item.id];
      if (raw == null) continue;
      // Umgedrehte Items sind in Richtung des gesunden Pols formuliert und
      // zählen daher gespiegelt.
      sum += item.reverse ? (bank.scaleMax - raw) : raw;
      answered++;
    }

    final percent =
        answered == 0 ? 0.0 : sum / (answered * bank.scaleMax) * 100;
    results[scale.id] = ScaleResult(scale: scale, percent: percent);
  }

  final risks = bank.scales
      .where((s) => s.polarity == ScalePolarity.risk)
      .map((s) => results[s.id]!)
      .toList();

  final strength = bank.scales
      .firstWhere((s) => s.polarity == ScalePolarity.strength);

  return TestResult(
    itembankVersion: bank.version,
    riskResults: risks,
    empowermentResult: results[strength.id]!,
  );
}
