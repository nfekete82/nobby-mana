# Kleines HUD und entdeckbare Gebietskarte – vor Umsetzung

Nutzerwunsch: HUD kleiner unten links, kleine Karte oben rechts, nicht erkundete
Bereiche schwarz. Bestehende Referenz-Wald-Art Direction bleibt erhalten.
Vorhandene Portrait-/Aktions-Bitmaps wiederverwenden, native Nearest-Filter.
HUD312×126 statt446×170, Portrait64×70, Aktionsfelder44×44, Icons32×32,
weiterhin lesbare LP/MP-Zahlen und unveränderte Angriff-/Heil-/R-/Itemfunktionen.
Anker12px links/10px unten. Keine ganze UI unscharf herunterskalieren.

Minimap180×146 mit168×120Kartenfläche (56×40×3px),12px rechts/oben.
Darstellung aus tatsächlichen Gelände- und Objektbitmaps der aktiven Szene,
keine erfundene Karte und keine nachgebauten Landschafts-Canvas-Primitive.
Nearest, feste Terrain-/Objektanker. Rahmen und Spielerpunkt sind funktionale
native Controls. Unerforschte Kartenpixel sind vollständig schwarz, einschließlich
Häusern, Brücke und Dekoration. Keine Gegner-/Schatzmarker auf unbekannten Flächen.

Beim Gehen wird ein Kreis von6Terrainzellen um die eigene Position aufgedeckt.
Erkundung bleibt gemeinsam für Affe/Panda, F5/Klassenwechsel und spätere Starts
erhalten (lokales user://map-exploration-v1.json, pro Szene/Abmessung). Nur Fog-
Daten, keine Veränderung von Spielerposition/Kampf/Saves. Speicherung gebündelt
und beim Szenenwechsel/Beenden, keine Dateioperationen pro Frame. Tests isolieren
Speicherdateien und ändern niemals die echte Erkundung des Nutzers.

Prüfen: echter Kartenaufbau aus editierter Szene, unbekannt schwarz, Bewegung
und Punktposition, wachsende Entdeckung, Speicherung/Laden, defekte Datei und
Kartengrenzen, UI-Anker bei mehreren Größen, tatsächliche Spielaufnahmen neben
bestehenden Grafikreferenzen. Alte manuell bearbeitete Kartendateien unverändert.

## Fertige Dateien und Verhalten

scripts/minimap.gd rendert eine Momentaufnahme der tatsächlichen editierbaren
Karte beim Laden. Sie zeigt die Landschaft, keine dynamischen Gegner-/Lootmarker.
Aktuell6Zellen Erkundungsradius; das ist eine Gebietserkundung um den Spieler,
keine physikalische Sichtlinien-/Dachsimulation. Bereits entdeckte Gebiete bleiben
hell. Der Spielerpunkt wird10mal pro Sekunde aktualisiert; Kartenpixel nur bei
neuen Zellen. Klicks auf die Minimap schießen nicht in die Welt darunter.

scripts/exploration.gd verwaltet und validiert die lokalen Fog-Daten. Schreiben
alle5Sekunden nur bei Änderungen, atomarer Dateiaustausch über eine .tmp-Datei,
zusätzlich Speichern beim Szenenwechsel/Beenden. Eine fehlerhafte oder anders
bemessene gespeicherte Karte beginnt mit schwarzem Nebel, ohne das Spiel zu
blockieren. Fortschritt ist lokal auf diesem Gerät, nicht im Git-Repository.

Echte Aufnahmen: artifacts/minimap/fresh-area.png, explored-route.png und
panda-shared-map.png. Testläufe verwenden tests/test_support.gd für ausschließlich
separate bzw. reine Speicher-Testdaten; der Persistenztest entfernt nur seine
Datei minimap-smoke-<PID>.json. Keine Tests dürfen den echten Entdeckungsstand
zurücksetzen oder durch automatisch erkundete Testpositionen erweitern.
