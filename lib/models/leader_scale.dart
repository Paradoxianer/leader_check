/// Ob eine Skala ein Risiko misst (hoher Wert = schlecht) oder eine Stärke
/// (hoher Wert = gut). Die vier Risikoskalen entsprechen den negativen
/// Leitertypen, die Stärkeskala der Bevollmächtigung.
enum ScalePolarity { risk, strength }

/// Eine einzelne Aussage, die angekreuzt wird.
class LeaderItem {
  /// Stabile ID (z.B. 'con_1'). Wird nie aus dem Text abgeleitet, damit
  /// Textänderungen gespeicherte Antworten nicht ungültig machen.
  final String id;

  final String text;

  /// True, wenn die Aussage *entgegen* der Richtung formuliert ist, die die
  /// Skala misst: bei Risikoskalen also in Richtung des gesunden Pols, bei
  /// der Stärkeskala in Richtung des ungesunden. Beim Auswerten wird der Wert
  /// dann gespiegelt. Das bricht die Tendenz, gedankenlos immer dieselbe
  /// Spalte anzukreuzen.
  final bool reverse;

  const LeaderItem({
    required this.id,
    required this.text,
    required this.reverse,
  });

  factory LeaderItem.fromJson(Map<String, dynamic> json) {
    return LeaderItem(
      id: json['id'] as String,
      text: json['text'] as String,
      reverse: json['reverse'] as bool? ?? false,
    );
  }
}

/// Eine Dimension des Modells mit ihren Items und allen Ergebnistexten.
class LeaderScale {
  final String id;
  final String name;
  final ScalePolarity polarity;

  /// Bezeichnung des ungesunden bzw. des gesunden Pols, für die Skalenachse
  /// in der Ergebnisansicht.
  final String riskLabel;
  final String healthyLabel;

  /// Welche Art von Mitarbeitern dieser Leitungsstil hervorbringt.
  final String followerEffect;
  final String shortDescription;

  /// Ergebnistexte je nach Ausprägung.
  final String lowText;
  final String midText;
  final String highText;

  /// Ein konkreter nächster Schritt — bewusst nur einer.
  final String nextStep;

  final List<LeaderItem> items;

  const LeaderScale({
    required this.id,
    required this.name,
    required this.polarity,
    required this.riskLabel,
    required this.healthyLabel,
    required this.followerEffect,
    required this.shortDescription,
    required this.lowText,
    required this.midText,
    required this.highText,
    required this.nextStep,
    required this.items,
  });

  factory LeaderScale.fromJson(Map<String, dynamic> json) {
    return LeaderScale(
      id: json['id'] as String,
      name: json['name'] as String,
      polarity: json['polarity'] == 'strength'
          ? ScalePolarity.strength
          : ScalePolarity.risk,
      riskLabel: json['riskLabel'] as String,
      healthyLabel: json['healthyLabel'] as String,
      followerEffect: json['followerEffect'] as String,
      shortDescription: json['shortDescription'] as String,
      lowText: json['lowText'] as String,
      midText: json['midText'] as String,
      highText: json['highText'] as String,
      nextStep: json['nextStep'] as String,
      items: (json['items'] as List)
          .map((i) => LeaderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Die komplette Itembank aus einer JSON-Datei.
class ItemBank {
  /// Version der Itembank. Ergebnisse, die exportiert werden, tragen diese
  /// Nummer mit — so bleibt nachvollziehbar, gegen welche Fragen sie
  /// entstanden sind.
  final int version;

  /// Höchster Antwortwert (0..scaleMax), also scaleMax + 1 Stufen. Bewusst
  /// eine gerade Anzahl (Stufen 0..5), damit keine goldene Mitte wählbar ist.
  final int scaleMax;

  final List<String> likertLabels;
  final List<LeaderScale> scales;

  const ItemBank({
    required this.version,
    required this.scaleMax,
    required this.likertLabels,
    required this.scales,
  });

  factory ItemBank.fromJson(Map<String, dynamic> json) {
    return ItemBank(
      version: json['itembankVersion'] as int,
      scaleMax: json['scaleMax'] as int,
      likertLabels: List<String>.from(json['likertLabels'] as List),
      scales: (json['scales'] as List)
          .map((s) => LeaderScale.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Alle Items in Reihenfolge der Skalen — die Reihenfolge, in der der Test
  /// durchlaufen wird.
  List<LeaderItem> get allItems =>
      scales.expand((scale) => scale.items).toList();

  int get itemCount => allItems.length;
}
