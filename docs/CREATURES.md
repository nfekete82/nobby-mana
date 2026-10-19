# Affen-Schamane und Waldkobolde

Im Startmenü **Affen-Schamane** wählen. Menschlicher Magier und Schamane bleiben
verfügbar. Linksklick/J wirft Pfeile; R erweckt Skelette. Der Affe hat einen vollständig neu gezeichneten Körper mit Pfoten,
Blätterkleidung und Schweif. Sechs eigene Lauf-, Wurf- und Beschwörungsposen
pro Richtung ersetzen die früheren zusammengesetzten Figuren. Treffer
unterbrechen die Zauberpose; danach funktionieren Laufen und Angreifen weiter.
Die Beschwörung dauert 1,2 Sekunden, aus der tatsächlich verwendeten Animation
berechnet. Der menschliche Schamane behält seine bisherige native Sequenz.

Neue Gegner in der östlichen Lichtung:

| Gegner | Leben | Treffer | Bewegung |
|---|---:|---:|---|
| Waldkobold-Späher | 45 | 10 | schnell (135 px/s) |
| Waldkobold-Raufbold | 75 | 18 | langsamer (95 px/s) |

Beide kämpfen gegen Helden und Skelette, besitzen Vorder-/Rückenansicht,
Lauf-, Angriffs-, Treffer- und Todeszustände. Ihre Körpersilhouetten sind
kleiner als die ursprünglichen Krieger; Kleidung und Waffen unterscheiden sich (Dolch bzw. Holzkeule).
Nach der Todessequenz werden sie aus der Szene entfernt.

## Im Editor platzieren

`scenes/encounters/goblin_scout.tscn` oder `goblin_brute.tscn` aus dem
Dateisystembereich in **Encounters** deiner Waldszene ziehen und verschieben.
Der Inspector bietet **Enemy Kind**, die Vorschau zeigt die passende Figur.
Scale bei (1,1) lassen. Cmd+S speichern, F5 spielen.

Die neue Standardgruppe liegt separat in
`scenes/encounters/forest_goblins.tscn` und kann dort verschoben werden.
Deine bereits bearbeitete forest.tscn wurde dafür nicht umgeschrieben.
Beim Forest-Root schaltet **Include Goblin Camp** die Standardgruppe ein/aus.
Im Editor zeigt eine temporäre Vorschau diese Gruppe; gespeicherte Gegner
in deiner eigenen Encounters-Gruppe bleiben unabhängig davon bestehen.

## Grafik und Grenzen

Quelle: [Produktionsbrief](CREATURE_ART_BRIEF.md) und
[Imagegen-Prompts v2](../art/generated-source/creatures/fullbody-v2/prompts.md).
Der Nutzer lehnte die erste Montage aus neuen Köpfen und nativen Körpern ab.
Diese wurde komplett ersetzt: ganze Körper, Kleidung, Ausrüstung, Vorder- und
Rückenposen sind jetzt zusammen gezeichnet. Zwei Richtungsreihen plus seitliche
Spiegelung; eigenständige Ost-/West-Bögen sind weiterhin nicht vorhanden.

Native Referenzen: Pixel Frog Blue Monk Run und Red Warrior Idle; Gameplay-
Vergleich mit dem vorhandenen menschlichen Schamanen. Feste 192px-Zellen,
Fuß [96,132], Hitbox 32×24 und Nearest bleiben erhalten. Affe ca.70px hoch,
Kobolde ca.60–64px. Keine Übernahme von Monk-Beinen, Ritterkörpern oder
Rotation stehender Figuren als Tod.

`python3 tools/setup_assets.py` installiert lokale Lizenzgrafiken und kompiliert
die eigenen vollständigen Quellen. `fullbody-v2/layout.json` dokumentiert die
gemessenen transparenten Zeilenabstände, gemeinsame Skalierung pro Figur,
Palettenfarben und ausgewählten Posen. Ein versehentlich liegend gezeichneter
Späher-Rückenangriffsframe wird ausgelassen; der Ablauf nutzt die übrigen
vollständigen Posen. Historische Teilequellen werden nicht mehr eingelesen.
Produktionsatlanten liegen unter dem ignorierten assets/compiled. Neue Quellen
werden nicht automatisch zu nativen Stilmastern hochgestuft.

```sh
python3 tools/creature_review.py
godot --headless --path . --script tests/creatures_smoke.gd
godot --path . --script tests/capture_creatures.gd
```

Die animierte Galerie liegt in artifacts/creatures/review.html. Tatsächliche
Spielaufnahmen: party.png und walk-gameplay.png im selben Ordner. Tests können
Framegeometrie, gemeinsame Fußpunkte und Verhalten prüfen; sie beweisen keine perfekte
Animation oder vollständige visuelle Stilgleichheit.
