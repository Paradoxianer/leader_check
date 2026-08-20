# Arbeitsanweisungen für Claude Code — leader_check

Kurz-Selbsttest für Leiterschaftskurse. Flutter-Web-App, bewusst klein.

## Arbeitsprinzipien

1. **Minimale, gezielte Änderungen.** Keine ungefragten Refactorings, keine
   Umbenennungen „bei der Gelegenheit", keine wholesale Rewrites. Wenn ein
   größerer Umbau nötig scheint: erst vorschlagen und begründen.
2. **Kein Overengineering.** Keine State-Management-Pakete, keine
   Abstraktionsschichten auf Vorrat, keine Fremdpakete ohne konkreten Grund.
   YAGNI. Wenn eine Abhängigkeit nötig scheint: erst fragen.
3. **`logic/scoring.dart` bleibt rein** — kein Flutter-, kein IO-Import. Jede
   Änderung an der Auswertung braucht einen Test in `test/scoring_test.dart`.
4. **Fragen sind Daten.** Items und Ergebnistexte leben in
   `assets/items/leader_items_de.json`, nie im Dart-Code. Item-IDs sind
   stabil; bei inhaltlichen Änderungen `itembankVersion` hochzählen.
5. **UI und Logik getrennt.** `build`-Methoden bleiben deklarativ,
   wiederkehrende Elemente wandern nach `lib/widgets/`.
6. Doku und Oberflächentexte auf Deutsch, Code-Bezeichner auf Englisch.
7. Vor Commits: `flutter analyze` und `flutter test`.
8. Commit-Nachrichten im Conventional-Commits-Format, kurz, ohne KI-Signatur.

## Struktur

```
lib/models/     Datenmodell (LeaderScale, LeaderItem, ItemBank)
lib/data/       Laden der Itembank aus dem Asset
lib/logic/      Auswertung (rein, testbar)
lib/screens/    Start → Test → Ergebnis
lib/widgets/    LikertOption, ScaleAxis, ContentFrame
assets/items/   die Fragen
docs/MODELL.md  warum fünf Skalen und nicht sechs Typen
```

## Fachliche Schnellreferenz

- Vier Risikoskalen (`consistency`, `power`, `openness`, `action`) plus eine
  Stärkeskala (`empowerment`).
- „Gesund" wird nicht gemessen, sondern abgeleitet: alle vier Risikoskalen
  unter 30 %. „Ermächtigend" nur, wenn zusätzlich `empowerment` ≥ 60 %.
- Antwortwerte 0–4. `reverse: true` heißt: entgegen der Messrichtung
  formuliert, zählt gespiegelt.

## Was hier bewusst *nicht* drin ist

Kein Fremdbild-Modul, keine Speicherung, kein Verlauf, kein Backend, keine
Lokalisierung. Das ist Absicht, nicht vergessen worden. Wenn eines davon
gewünscht wird, kommt es als eigene Aufgabe — nicht nebenbei.
