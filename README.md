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
besitzt keine Pfeile oder Skelettbeschwörung. Beide Figuren können mit H bzw.
dem Heilkreuz für20Mana bis zu35LP heilen; volle LP oder zu wenig Mana blockieren
die Aktion ohne Kosten.

Ein Skelett kostet den Affen10Mana und kämpft zwei Minuten mit. Mana erholt sich
im Stehen nach0,25Sekunden Ruhe mit5Punkten pro Sekunde. Gegner haben
Lebensbalken und verschwinden nach ihrer Todesfolge.

Der Affe trägt Dutt und Bart, der Panda blonde Seitenfrisur, schwarze Brille und
korallfarbene Kleidung nach den persönlichen Bildreferenzen. Ganze Körper und
Vorder-/Rückenanimationen, keine Kopfmontagen. Private Fotos liegen nicht im Repo.
[Figuren, Quellen und Grenzen](docs/CREATURES.md).

Die aktive Welt ist **56×40 Kacheln (3584×2560 Pixel)** groß und wurde nach der
neuen Bildreferenz als dichter Wald gestaltet: warme Holz-/Strohhäuser, Gras und
Blumen, Felsufer, animierter Fluss, Wasserfallstufe und begehbare Holzbrücke.
Die neue Karte liegt in scenes/levels/reference_grove.tscn. Eure älteren Szenen
forest.tscn und woodland_village.tscn bleiben erhalten, sind aber nicht aktiv.
Die Grafik ist eine eigene Umsetzung der neuen Richtung, keine exakte Bildkopie.

Unten links sitzt das verkleinerte HUD mit Heldenporträt, LP/MP-Zahlen und
Angriff(J), Heilen(H), Skelett(R), Item. Oben rechts zeigt eine kleine Karte
die tatsächliche Landschaft und einen hellen Punkt für die eigene Position.
Unerforschte Gebiete bleiben vollständig schwarz. Beim Laufen wird die Umgebung
aufgedeckt; die Erkundung bleibt für beide Helden sowie nach F5 und späteren
Spielstarts erhalten. Sie wird lokal als user://map-exploration-v1.json
periodisch und beim Verlassen der Szene gespeichert. Keine Cloud-Abhängigkeit.

Beim Panda ist Skelett deaktiviert; Item ist erkennbar noch nicht verfügbar.
Kein Inventar oder begehbares Hausinnere implementiert. Eure persönlichen Figuren
bleiben erhalten. [HUD-/Minimap-Details](docs/MINIMAP_BRIEF.md).

## Leveleditor

**Editor.command** öffnet die aktive Referenzkarte. Ground, Paths, River,
CliffFaces, Barriers, Scenery, Encounters und PlayerSpawn sind normale
Godot-Nodes. Häuser/Bäume/Blumen/Felsen verschieben, auf Scale(1,1) belassen,
Cmd+S speichern und F5 spielen. Die Welt wird beim Start nicht neu generiert.

[Editor-Anleitung](docs/LEVEL_EDITOR.md) ·
[Neue Grafikquellen und Art Direction](docs/REFERENCE_GROVE_BRIEF.md).

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
godot --headless --path . --script tests/minimap_smoke.gd
godot --path . --script tests/capture.gd
godot --path . --script tests/grove_smoke.gd
godot --path . --script tests/capture_grove.gd
```

Die Aufnahmebefehle brauchen eine grafische Sitzung und schreiben echte
Godot-Screenshots nach `artifacts/clearing.png` bzw. `artifacts/grove/`. Strukturprüfungen ersetzen
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
