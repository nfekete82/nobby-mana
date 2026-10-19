# Affen-Schamane und Waldkobolde

Im Startmenü **Affen-Schamane** wählen. Menschlicher Magier und Schamane bleiben
verfügbar. Linksklick/J wirft Pfeile; R erweckt Skelette. Der Affe verwendet
native Schamanenbewegungen mit neuem Kopf, geschlossenen Zauberaugen und
animiertem Schweif. Treffer unterbrechen die Zauberpose; danach funktionieren
Laufen und Angreifen weiter. Beim Beschwören wird die komplette elfteilige
Stab-/Armsequenz abgespielt, statt die Laufpose als Platzhalter zu verwenden.

Neue Gegner in der östlichen Lichtung:

| Gegner | Leben | Treffer | Bewegung |
|---|---:|---:|---|
| Waldkobold-Späher | 45 | 10 | schnell (135 px/s) |
| Waldkobold-Raufbold | 75 | 18 | langsamer (95 px/s) |

Beide kämpfen gegen Helden und Skelette, besitzen Vorder-/Rückenansicht,
Lauf-, Angriffs-, Treffer- und Todeszustände. Ihre Körpersilhouetten sind
kleiner als die ursprünglichen Krieger; Kleidung/Schilde unterscheiden sich.
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
[Imagegen-Prompts](../art/generated-source/creatures/prompts.md).
Imagegen erzeugte neue Identitätsteile, keine vollständigen zufälligen
Animationskörper. Roben-/Bein-/Waffenposen bleiben die authentischen nativen
Monk-/Warrior-Phasen. Der Affenlauf besitzt die vier echten abwechselnden
Fußkontakte/Durchschwünge, keine duplizierten oder neu erfundenen Ersatzbeine.
Die Rückenkörper werden aus den vorhandenen nativen Posen abgeleitet;
es gibt weiterhin keine komplett separat gezeichneten vier Blickrichtungen.

`python3 tools/setup_assets.py` installiert die vorhandenen lokalen Bilder
und führt den deterministischen Godot-Compiler aus. Eigene Bildquellen und
Prompts liegen unter art/generated-source/creatures; Produktionsatlanten
unter dem ignorierten assets/compiled. Neue Quelldateien sind keine originalen
Pixel-Frog-Master; sie werden nicht automatisch zu Stilreferenzen hochgestuft.

```sh
python3 tools/creature_review.py
godot --headless --path . --script tests/creatures_smoke.gd
godot --path . --script tests/capture_creatures.gd
```

Die animierte Galerie liegt in artifacts/creatures/review.html. Tatsächliche
Spielaufnahmen: party.png und walk-gameplay.png im selben Ordner. Tests können
Framegeometrie, native Füße und Verhalten prüfen; sie beweisen keine perfekte
Animation oder vollständige visuelle Stilgleichheit.
