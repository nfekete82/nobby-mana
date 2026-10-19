# Nobby Mana

Ein neues 2D-Action-Rollenspiel mit Godot und GDScript. Vorbild für freie
Bewegung, Echtzeitkampf und Erkundung ist Secret of Mana; Welt, Figuren und
Geschichte werden eigenständig entwickelt. Keine Verbindung zu Square Enix.

## Erster spielbarer Stand

Eine neue Waldlichtung mit Nobby, zwei Nahkampfgegnern, Kamera, festen
Fußkollisionen, Trefferverzögerung, Rückstoß, Lebensanzeige und einem kleinen
Kampfziel. WASD/Pfeile bewegen, Leertaste/J greift in Bewegungsrichtung an,
R startet die Szene neu. Angriffe treffen erst nach ihrer Ausholphase,
pro Schwung einmal und nicht durch Bäume oder andere Weltkollisionen.

Die aktuellen Nobby-/Tiny-Swords-Grafiken sind wiederverwendete Prototypgrafiken.
Sie stellen noch keine neue SNES-Art-Direction dar. Die vorhandenen Sheets
haben keine vollständigen vier Blickrichtungen; die Darstellung verwendet
vorerst die vorhandenen Posen und horizontale Spiegelung. Kampfprüfungen
arbeiten bereits mit der tatsächlichen Blickrichtung.

## Lokal starten

Voraussetzung: **Godot 4.7.2 Standard**, Python 3, und eine rechtmäßig bezogene
Kopie der verwendeten Nobby-World-Grafiken. Keine Node-, Docker- oder
Cloud-Abhängigkeit für das Spiel.

```sh
python3 tools/setup_assets.py --source ../nobby_world
godot --headless --editor --path . --import
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
GitHub liefert den Pixel-Frog-Pack nicht mit. Details in [CREDITS.md](CREDITS.md).

## Prüfen

```sh
python3 tools/check_project.py
godot --headless --editor --path . --import
godot --headless --path . --script tests/combat_smoke.gd
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
4. Inventar, Ausrüstung, Magie und neue Spielstände ergänzen.
5. Begleiter erst nach einem überzeugenden Einzelspielerabschnitt entwickeln.

Das alte RPG-JS-Spiel bleibt ein separates Projekt. Karten, Objekt-IDs und
Spielstände daraus werden hier nicht automatisch importiert.
