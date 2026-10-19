# Nobby Mana

Ein neues 2D-Action-Rollenspiel mit Godot und GDScript. Vorbild für freie
Bewegung, Echtzeitkampf und Erkundung ist Secret of Mana; Welt, Figuren und
Geschichte werden eigenständig entwickelt. Keine Verbindung zu Square Enix.

## Erster spielbarer Stand

Eine neue Waldlichtung mit Nobby, zwei Nahkampfgegnern, Kamera, festen
Fußkollisionen, Trefferverzögerung, Rückstoß, Lebensanzeige und einem kleinen
Kampfziel. Kleine Lebensbalken stehen über den Gegnern; besiegte Gegner
verschwinden nach 0,3 Sekunden. Unten mittig zeigt ein kompaktes HUD Leben
als rote und Mana als blaue Kugel, mit Beschwörung und Begleiterzahl dazwischen.
WASD/Pfeile bewegen, Leertaste/J greift in Bewegungsrichtung an,
R beschwört ein Skelett, F5 startet die Szene neu. Angriffe treffen erst nach ihrer Ausholphase,
pro Schwung einmal und nicht durch Bäume oder andere Weltkollisionen.

Die aktuellen Nobby-/Tiny-Swords-Grafiken sind wiederverwendete Prototypgrafiken.
Sie stellen noch keine neue SNES-Art-Direction dar. Die vorhandenen Sheets
haben keine vollständigen vier Blickrichtungen; die Darstellung verwendet
vorerst die vorhandenen Posen und horizontale Spiegelung. Kampfprüfungen
arbeiten bereits mit der tatsächlichen Blickrichtung.

## Skelette als Mitkämpfer

**R** oder der HUD-Button erweckt ein Skelett für **10 Mana**, ohne Cooldown.
Bis zu drei Skelette kämpfen gleichzeitig; sie haben jeweils 85 Leben,
verursachen 10 Schaden und bleiben bis zu zwei Minuten. Ohne Gegner folgen
sie Nobby in Formation. Gegner werden innerhalb von 300 Pixeln gesucht;
ein lebendes Kampfziel bleibt bis 480 Pixel Entfernung gebunden, auch wenn
Nobby wegläuft. Wege um Stämme/Wände verwenden ein kollisionsgeprüftes A*-Raster.
Gegner wählen den nächsten erreichbaren Verbündeten und können Skelette töten.
Keine freundlichen Treffer. Tod/Timeout gibt den Platz sofort wieder frei;
Nobbys Tod oder F5 entfernt seine Begleiter. F5 setzt auch Mana und Gegner zurück.
Mana erholt sich im Stehen nach 0,25 Sekunden Ruhe um 5 Punkte pro Sekunde.
Das benötigt im Prototyp keine Charakterklassenwahl und keine Gegnerleichen.

Stand/Lauf/Angriff/Beschwörung/Tod verwenden unveränderte vorhandene Skelett-
Sheets einschließlich Rückenansichten, nativer 192px-Zellen und fester Füße.
Nach einem Pull einmal `python3 tools/setup_assets.py` ausführen (oder die
aktualisierte Startdatei verwenden), damit die neuen lokalen PNGs vorhanden sind.

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
godot --headless --path . --script tests/companions_smoke.gd
godot --headless --path . --script tests/hud_enemy_smoke.gd
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
5. Begleiter im nächsten Spielabschnitt weiter abstimmen.

Das alte RPG-JS-Spiel bleibt ein separates Projekt. Karten, Objekt-IDs und
Spielstände daraus werden hier nicht automatisch importiert.
