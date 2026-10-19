# Nobby Mana

Ein neues 2D-Action-Rollenspiel mit Godot und GDScript. Vorbild für freie
Bewegung, Echtzeitkampf und Erkundung ist Secret of Mana; Welt, Figuren und
Geschichte werden eigenständig entwickelt. Keine Verbindung zu Square Enix.

## Spielen

Beim Start zwischen **Affen-Schamane** und **Panda-Kämpferin** wählen. Die
menschlichen Klassen Magier und Schamane sind entfernt. Esc öffnet die
Heldenwahl; F5 startet dieselbe Figur neu. WASD/Pfeile bewegen.

| Figur | Linksklick / J | Leertaste | Spezialität |
|---|---|---|---|
| Affen-Schamane | Pfeile, 18 Schaden, ohne Mana | Nahkampf | R: bis zu drei Skelettmitkämpfer |
| Panda-Kämpferin | Holzschwert, 28 Schaden | Holzschwert | 125 Leben, reiner Nahkampf |

Mausklick zielt zur Maus; J visiert den nächsten Gegner an. Das Schwert trifft
nur innerhalb seiner Reichweite, nach einer Ausholbewegung und einmal je
Schlag. Bäume und Hausfundamente blockieren Schläge und Pfeile. Der Panda
besitzt keine Pfeile oder Skelettbeschwörung; sein HUD zeigt das Holzschwert.

Ein Skelett kostet den Affen10Mana und kämpft zwei Minuten mit. Mana erholt sich
im Stehen nach0,25Sekunden Ruhe mit5Punkten pro Sekunde. Gegner haben
Lebensbalken und verschwinden nach ihrer Todesfolge.

Der Affe trägt Dutt und Bart, der Panda blonde Seitenfrisur, schwarze Brille und
korallfarbene Kleidung nach den persönlichen Bildreferenzen. Ganze Körper und
Vorder-/Rückenanimationen, keine Kopfmontagen. Private Fotos liegen nicht im Repo.
[Figuren, Quellen und Grenzen](docs/CREATURES.md).

Die Welt ist **56×40 Kacheln (3584×2560 Pixel)** groß, doppelt so viel Fläche
wie zuvor. Östlich der alten Lichtung liegt ein Dorf mit Häusern und Dorfhalle;
eine südliche Waldroute führt an der Holzfällerhütte vorbei zurück nach Osten.
Birken, Nadelbäume, Büsche und Felsen bringen Abwechslung. Eine Hütte ist schon
beim Start sichtbar. Gebäude besitzen Grundkollisionen; begehbare Innenräume
und NPC-Dialoge sind noch nicht implementiert.

## Leveleditor

**Editor.command** öffnet die bisherige Waldkarte. Das neue Dorf liegt separat
in **scenes/levels/woodland_village.tscn**: Ground/Paths malen, Scenery mit
Häusern/Bäumen/Felsen kopieren und verschieben. Scale bleibt(1,1), Cmd+S speichern,
F5 spielen. Die manuell bearbeitete forest.tscn wird nicht neu erzeugt.

[Schrittweise Editor-Anleitung](docs/LEVEL_EDITOR.md).

## Lokal starten

Voraussetzung: **Godot 4.7.2 Standard**, Python 3, und eine rechtmäßig bezogene
Kopie der verwendeten Nobby-World-Grafiken. Keine Node-, Docker- oder
Cloud-Abhängigkeit für das Spiel.

```sh
python3 tools/setup_assets.py --source ../nobby_world
godot --headless --editor --path . --import --quit
godot --path .
```

Am eingerichteten Mac: `Starten.command` doppelklicken.
`Editor.command` öffnet den Godot-Editor. Alternativ `project.godot` importieren.
Die Engine selbst ist lokal unter `.tools/` abgelegt und gehört nicht ins Repo.

## Grafiklizenz und öffentliches Repository

Dieses Repository enthält Spielcode, Szenen und Metadaten. Die lizenzierten
PNGs liegen ausschließlich lokal unter dem ignorierten `assets/licensed/`.
Das Einrichtungsskript kopiert nur referenzierte, vorhandene Dateien und prüft
deren SHA-256-Werte. Ein frischer öffentlicher Clone benötigt diese Dateien;
GitHub liefert den Pixel-Frog-Pack nicht mit. Die eigenen Pfeil-Pixelpläne werden dabei ebenfalls nach dem ignorierten
`assets/compiled/` kompiliert. Details in [CREDITS.md](CREDITS.md).

## Prüfen

```sh
python3 tools/check_project.py
godot --headless --editor --path . --import --quit
godot --headless --path . --script tests/combat_smoke.gd
godot --headless --path . --script tests/companions_smoke.gd
godot --headless --path . --script tests/hud_enemy_smoke.gd
godot --headless --path . --script tests/classes_editor_smoke.gd
godot --headless --path . --script tests/creatures_smoke.gd
godot --path . --script tests/capture.gd
godot --path . --script tests/capture_duo.gd
```

Die Aufnahmebefehle brauchen eine grafische Sitzung und schreiben echte
Godot-Screenshots nach `artifacts/clearing.png` bzw. `artifacts/duo/`. Strukturprüfungen ersetzen
keine Sichtprüfung oder Spieltests. CI prüft die öffentlich verfügbaren
Projektdateien; vollständige Laufzeittests benötigen die lokalen Grafiken.

## Weiterentwicklung

1. Bewegung und Nahkampf spielerisch abstimmen; vier Blickrichtungen gestalten.
2. Dorf um NPC-Dialoge, Innenräume und eine eigenständige Aufgabe ergänzen.
3. Wald-Dungeon und ersten Boss bauen.
4. Inventar, Ausrüstung, weitere Magie und neue Spielstände ergänzen.
5. Begleiter im nächsten Spielabschnitt weiter abstimmen.

Das alte RPG-JS-Spiel bleibt ein separates Projekt. Karten, Objekt-IDs und
Spielstände daraus werden hier nicht automatisch importiert.

Die aktuellen Affen-/Koboldsprites sind vollständige Neuzeichnungen mit eigenen
Körpern und Vorder-/Rückenanimationen. Die frühere Kopf-/Körpermontage ist ersetzt.
Quellen und Animationen: [Kreaturen](docs/CREATURES.md).
