# Nobby Mana

Ein neues 2D-Action-Rollenspiel mit Godot und GDScript. Vorbild für freie
Bewegung, Echtzeitkampf und Erkundung ist Secret of Mana; Welt, Figuren und
Geschichte werden eigenständig entwickelt. Keine Verbindung zu Square Enix.

## Spielen

Beim Start **Magier**, **Schamane** oder **Affen-Schamane** wählen. Esc öffnet die Klassenwahl
wieder; F5 startet die aktuelle Klasse neu. WASD/Pfeile bewegen, Leertaste
ist Nahkampf. **Linksklick** wirft in Richtung der Maus, **J** visiert den
nächsten Gegner an. Pfeile fliegen sichtbar, treffen einmal und werden von
Wänden/Bäumen gestoppt. Schamane: 18 Schaden ohne Manakosten. Magier: arkane
Pfeile, 25 Schaden für 6 Mana. Keine Munitionsverwaltung.

Menschlicher Schamane und Affen-Schamane erwecken mit **R** oder dem Skelettsymbol bis zu drei Mitkämpfer
für je 10 Mana und zwei Minuten. Sie folgen ihm und kämpfen selbstständig.
Gegner können sie besiegen. Mana erholt sich im Stehen nach 0,25 Sekunden
Ruhe mit 5 Punkten pro Sekunde. Der Magier hat keine Skelettbeschwörung.

Unten links: rote Lebens- und blaue Manakugel, gestaffelt wie in der
HUD-Referenz, rechts daneben das Skelettsymbol mit „R · Erwecken“ und der
Pfeilslot. Gegner haben schmale Lebensbalken und verschwinden nach dem Tod.

Die Waldkarte ist **40×28 Kacheln (2560×1792 Pixel)** groß, mit zusätzlicher
Lichtung, Verbindungspfad und Baumgruppen. Die vorhandenen Tiny-Swords-/Nobby-
Grafiken bleiben Prototypgrafiken; keine übernommenen Secret-of-Mana- oder
Diablo-Assets. Der Schamane besitzt Vorder-/Rückenreihen, der Magier behält
vorerst die bisherigen seitlich/frontalen Posen.

## Neue Figuren

Der **Affen-Schamane** ist ein spielbarer Charakter mit neuen Kopf-/Schweifteilen
auf authentischen nativen Monk-Bewegungen: vier echte Laufphasen, getrennte
Vorder-/Rückenreihen, Wurf, Beschwörung, Treffer und Tod. Füße und Hitbox bleiben
fest. Zwei **Waldkoboldtypen** bewachen die östliche Lichtung: schnelle Späher
und kräftigere Raufbolde, mit eigenen Werten und platzierbaren Editorvorlagen.
[Figuren, Grafikquellen und Editor-Anleitung](docs/CREATURES.md).

## Leveleditor

**Editor.command** öffnet direkt die bearbeitbare Waldkarte in Godot.
Ground/Paths: Kacheln malen. Barriers: Sperrflächen malen. Scenery: Bäume
und Büsche kopieren/verschieben. Encounters: Gegner platzieren. PlayerSpawn:
Startpunkt verschieben. **Cmd+S speichern, F5 spielen.**

[Schrittweise Editor-Anleitung](docs/LEVEL_EDITOR.md). Die Karte wird zur
Laufzeit aus der gespeicherten Szene geladen und beim Einrichten nicht
überschrieben. Kein Browsereditor und kein Tiled-Import nötig.

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
```

Der letzte Befehl braucht eine grafische Sitzung und schreibt einen echten
Godot-Screenshot nach `artifacts/clearing.png`. Strukturprüfungen ersetzen
keine Sichtprüfung oder Spieltests. CI prüft die öffentlich verfügbaren
Projektdateien; vollständige Laufzeittests benötigen die lokalen Grafiken.

## Weiterentwicklung

1. Bewegung und Nahkampf spielerisch abstimmen; vier Blickrichtungen gestalten.
2. Kleines Dorf, NPC-Dialog und eine eigenständige Aufgabe ergänzen.
3. Wald-Dungeon und ersten Boss bauen.
4. Inventar, Ausrüstung, weitere Magie und neue Spielstände ergänzen.
5. Begleiter im nächsten Spielabschnitt weiter abstimmen.

Das alte RPG-JS-Spiel bleibt ein separates Projekt. Karten, Objekt-IDs und
Spielstände daraus werden hier nicht automatisch importiert.

Die aktuellen Affen-/Koboldsprites sind vollständige Neuzeichnungen mit eigenen
Körpern und Vorder-/Rückenanimationen. Die frühere Kopf-/Körpermontage ist ersetzt.
Quellen und Animationen: [Kreaturen](docs/CREATURES.md).
