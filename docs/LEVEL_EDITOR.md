# Karte in Godot bearbeiten

`Editor.command` doppelklicken. Die Datei öffnet direkt
`scenes/levels/forest.tscn` im Godot-Editor. Oben **2D** auswählen.
Mit F5 startet das ganze Spiel mit Klassenwahl; F6 zeigt nur die aktuelle
Kartenszene. Änderungen vor dem Spielen mit Cmd+S speichern.

## Gelände und Wege

Im Szenenbaum **Ground** auswählen, unten **TileMap** öffnen und eine Kachel
in der Atlaspalette auswählen. Im 2D-Fenster malen; mit dem Radierer entfernen.
**Paths** enthält eine getrennte, transparente Wegeebene mit 64px-Kanten/Ecken.
Vorhandene Kanten und Ecken passend setzen; es gibt noch kein Terrain-Autotiling.
Alle Positionen bleiben auf dem 64×64-Raster. Keine Texturen weich skalieren.

## Kollisionen

**Barriers** auswählen und dort Sperrkacheln malen. Die roten Markierungen
sind ausschließlich im Editor sichtbar und blockieren im Spiel tatsächlich
Bewegung, Pfeile und Navigation. Mit dem Radierer wird eine Fläche wieder frei.
Optische Boden-/Klippenkacheln sperren den Weg nicht automatisch; dafür bewusst
die Barriers-Ebene verwenden. Bäume haben automatisch eine Stammkollision,
Büsche sind durchquerbar.

## Bäume, Büsche, Gegner und Startpunkt

- Unter **Scenery** einen Baum auswählen, mit Cmd+D duplizieren und verschieben.
  Im Inspector bestimmt **Asset Id** Baum groß, Baum klein oder Busch. Füße und
  Kollisionen folgen dem Asset; die Scale bleibt bei (1,1).
- Unter **Encounters** einen Warrior-Marker verschieben oder duplizieren.
  Seine Sprite-Vorschau kennzeichnet die Position des tatsächlichen Gegners.
  Anzahl, Kampfziel und Spawnpositionen werden daraus beim Start gelesen.
- **PlayerSpawn** verschieben, um den Heldenstart zu verändern.
- Den Root **Forest** auswählen: **Map Tiles** bestimmt die Grenzen. Aktuell
  40×28 bzw. 2560×1792 Pixel. Bei Erweiterung die neuen Flächen selbst malen;
  Kamera, Weltgrenzen und Navigationsraster übernehmen die Maße beim Neustart.

Die Karte ist eine reguläre gespeicherte Godot-Szene und wird beim Spielen oder
Einrichten nicht neu generiert. `tools/create_level.gd` war nur die einmalige
Erstellung und verweigert jedes Überschreiben. Das alte RPG-JS-/Tiled-Projekt
bleibt getrennt. Der Speichern/Laden-Test arbeitet ausschließlich in einer
vorübergehenden Testdatei, nicht an deiner Projektkarte.

## Waldkobolde

Die Szenen scenes/encounters/goblin_scout.tscn und goblin_brute.tscn lassen
sich als Gegner in die Encounters-Gruppe ziehen. Die separate Standardgruppe
liegt in forest_goblins.tscn und kann dort bearbeitet werden; deine bestehende
Waldkarte wird dafür nicht überschrieben. Beim Root schaltet Include Goblin Camp
diese Zusatzgruppe ein/aus. Details: [CREATURES.md](CREATURES.md).
