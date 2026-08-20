# Leitertyp-Check

Ein Kurz-Selbsttest für Leiterschaftskurse: 20 Aussagen ankreuzen, Ergebnis
ansehen, einen konkreten nächsten Schritt mitnehmen. Läuft als Web-App, ohne
Konto, ohne Server, ohne Speicherung.

Die Typologie ist angelehnt an den *Craig Groeschel Leadership Podcast*,
Folgen 1 und 2 („Six Types of Leaders").

## Was gemessen wird

Vier Verhaltensrisiken und eine Stärke — warum nicht sechs Typen, steht in
[`docs/MODELL.md`](docs/MODELL.md).

| Skala | gesunder Pol | Risiko-Pol |
|---|---|---|
| Berechenbarkeit | berechenbar | unberechenbar |
| Umgang mit Macht | beteiligend | dominierend |
| Offenheit | transparent | verschlossen |
| Handlungsbereitschaft | aktiv | passiv |
| Bevollmächtigung | andere dürfen Ja sagen | alles läuft über dich |

## Loslegen

```bash
flutter pub get
flutter run -d chrome      # lokal
flutter test               # Auswertung + Itembank prüfen
```

## Fragen ändern

Alle Aussagen und Ergebnistexte liegen in
`assets/items/leader_items_de.json` — kein Dart nötig. Die Regeln dazu stehen
in `docs/MODELL.md`, Abschnitt „Itembank ändern".

## Aufbau

```
lib/
├── models/leader_scale.dart   Datenmodell (Skala, Item, Itembank)
├── data/item_bank_loader.dart lädt die JSON-Itembank
├── logic/scoring.dart         Auswertung — reines Dart, ohne Flutter
├── screens/                   Start, Test, Ergebnis
├── widgets/                   Antwortoption, Skalenachse, Rahmen
└── theme.dart                 Farben und Textstile
assets/items/                  die Fragen
test/scoring_test.dart         Tests gegen die echte Itembank
```

Bewusst ohne Fremdpakete und ohne State-Management-Framework: Der gesamte
Zustand sind zwanzig Zahlen, die nur während des Tests existieren. Die
Auswertung liegt trotzdem getrennt von der Oberfläche, damit sie testbar
bleibt.

## Deployment

Push auf `main` baut und veröffentlicht automatisch auf GitHub Pages
(`.github/workflows/deploy.yml`). Der `--base-href` im Workflow muss zum
Repo-Namen passen.

## Grenzen

Ein Selbstreflexions-Werkzeug für den Kursgebrauch, kein geprüftes
psychologisches Testverfahren. Keine Normstichprobe, keine Validierung.
Details in `docs/MODELL.md`.
