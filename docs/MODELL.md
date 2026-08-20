# Das Modell hinter dem Check

## Warum fünf Skalen und nicht sechs Typen

Die Vorlage beschreibt sechs Leitertypen und jeweils die Art von Mitarbeitern,
die sie hervorbringen. Diese sechs sind aber nicht sechs gleichrangige
Kategorien, aus denen man eine Prozent-Torte bilden könnte:

- **Typ 1–4** (unberechenbar, dominierend, verschlossen, passiv) sind vier
  voneinander unabhängige Verhaltensrisiken.
- **Typ 5 „gesund"** ist in der Vorlage ausdrücklich definiert als die
  *Abwesenheit* von 1–4, plus tägliche Präsenz. Also kein eigener Typ, sondern
  ein erreichtes Niveau.
- **Typ 6 „ermächtigend"** ist „gesund und darüber hinaus": Menschen tief in
  der Organisation dürfen Ja sagen.

Der Check misst deshalb **vier Risikoskalen und eine Stärkeskala**:

| Skalen-ID | Skala | gesunder Pol | Risiko-Pol | Typ |
|---|---|---|---|---|
| `consistency` | Berechenbarkeit | berechenbar | unberechenbar | 1 |
| `power` | Umgang mit Macht | beteiligend | dominierend | 2 |
| `openness` | Offenheit | transparent | verschlossen | 3 |
| `action` | Handlungsbereitschaft | aktiv | passiv | 4 |
| `empowerment` | Bevollmächtigung | andere dürfen Ja sagen | alles läuft über dich | 6 |

„Gesund" wird nicht gemessen, sondern abgeleitet: alle vier Risikoskalen unter
30 %. „Ermächtigend" wird erst geprüft, wenn „gesund" erreicht ist — sonst
bescheinigt sich jemand Ermächtigung, während er dominiert.

## Auswertung

Jedes Item wird auf einer fünfstufigen Skala beantwortet (Rohwert 0–4). Items
mit `"reverse": true` sind entgegen der Messrichtung der Skala formuliert und
zählen gespiegelt (`4 − Rohwert`). Das ist kein Selbstzweck: Ohne Gegenpol-Items
kreuzt man nach drei Fragen mechanisch immer dieselbe Spalte an.

Skalenwert = Summe der (ggf. gespiegelten) Werte ÷ (Anzahl beantworteter Items
× 4) × 100.

Schwellen: unter 30 % niedrig, 30–55 % mittel, ab 55 % hoch. Bewusst grob —
vier Items pro Skala tragen keine feinere Unterscheidung, und eine Anzeige auf
die Nachkommastelle würde eine Genauigkeit vortäuschen, die nicht da ist.

## Grenzen, die man kennen sollte

- **Kein geprüftes Testverfahren.** Es gibt keine Normstichprobe, keine
  Reliabilitätsprüfung, keine Validierung. Das Ding ist ein
  Gesprächsanstoß für einen Kurs, nicht mehr — und die App sagt das auch.
- **Selbstauskunft hat eine bekannte Schwäche.** Gerade bei „dominierend" und
  „verschlossen" antwortet man tendenziell so, wie man gern wäre. Deshalb
  endet die Ergebnisseite mit dem Hinweis, dieselben Fragen drei Leuten aus
  dem eigenen Team zu stellen. Die Differenz ist aussagekräftiger als der
  Selbsttest allein.
- **Die relative Risikoverteilung** (`TestResult.riskDistribution`) summiert
  sich immer auf 100 %, auch wenn alle Werte niedrig sind. Sie zeigt
  Schwerpunkte, keine Ausprägung. Die absoluten Skalenwerte sind die
  wichtigere Zahl; die Verteilung wird in der Oberfläche derzeit bewusst
  nicht angezeigt.

## Itembank ändern

Die Fragen liegen in `assets/items/leader_items_de.json`, nicht im Code.

Zwei Regeln beim Bearbeiten:

1. **Item-IDs sind stabil.** Text ändern ist in Ordnung, ID ändern nicht —
   sonst passen exportierte oder gespeicherte Ergebnisse nicht mehr dazu.
2. **`itembankVersion` hochzählen**, wenn sich Items inhaltlich ändern oder
   welche dazukommen bzw. wegfallen.

`flutter test` prüft die Datei mit: eindeutige IDs, vier Risikoskalen plus eine
Stärkeskala, und mindestens ein Gegenpol-Item pro Skala.

## Quelle

Die Typologie ist angelehnt an den *Craig Groeschel Leadership Podcast*,
Folgen 1 und 2 („Six Types of Leaders"). Die Einteilung selbst ist die Idee
aus dem Podcast; sämtliche Fragen, Ergebnistexte und Handlungsschritte in
diesem Repo sind eigenständig formuliert.
