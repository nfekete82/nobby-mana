# Klassen, Pfeile, HUD und größere Karte

Referenzen: `shaman` und `hero` aus Nobby Worlds genehmigter Registry,
nativer Monk/Warrior als Actor-/Ausrüstungsmaster, `skeleton` als HUD-Motiv,
Tiny-Swords-Gras/Wege/Bäume für die Karte. Das vom Nutzer angehängte Diablo-Bild
ist ausschließlich die Anordnungsreferenz für die linke HUD-Ecke.

Schamane: unveränderte native 192×192-Zellen, Fuß [96,132], Hitbox 32×24,
je zwei Richtungsreihen. Stand [0,4] aus sechs Posen bei 0,5 FPS, vier echte
Monk-Laufposen bei 12 FPS, Angriff sechs bei 16 FPS, Heilung elf bei 9 FPS,
Treffer zwei bei 10 FPS, Tod vier bei 8 FPS. Keine neue Figur oder Skalierung.
Mana/HUD-Zahlen spiegeln die tatsächliche gewählte Klasse.

Das bestehende Projekt enthält keinen nativen Pfeil-Sprite. Bewusste neue
Ergänzung: ein kleiner handgesetzter 32×11-Pixel-Pfeil, ein Frame, Zentrum
[16,5]. Die Material-/Konturreferenzen sind der vorhandene Schamanenstab samt
Gewand sowie das native Warrior-Schwert; Gameplayvergleich ist Nobby in
Originalgröße. Der Pixelplan steht unter art/generated-source/arrow.json,
mit begrenzter bestehender Palette (Schiefer, Ocker, Creme und Petrol bzw.
Blau für die arkane Variante). tools/setup_assets.py kompiliert beide PNGs
deterministisch nach assets/compiled; keine Canvas-Platzhalter, Glättung,
weichen Verläufe oder neuen externen Packdateien. Diese Ergänzung ist keine
nachträglich behauptete native Pixel-Frog-Grafik und kein neuer Stilmaster.

HUD: zwei native 96px-Füllanzeigen in gestaffelter Anordnung ganz unten links,
432×180px-Gesamtfläche, 12px linker/10px unterer Rand. Rechts daneben zwei
funktionale Slots: R mit einem unveränderten 64×72px-Skelettausschnitt und
Pfeile/J mit der nativen kleinen Pfeilgrafik. Keine Diablo-Bilder übernommen.

Karte: 40×28 native 64px-Kacheln, echte gespeicherte TileMapLayer für Boden,
Wege und separate Kollision. Vorhandene Innen-/Rand-/Eckkacheln weiterverwendet.
Zusätzliche östliche Lichtung, Verbindungspfad und native Baum-/Buschgruppen.
Keine bestehenden TMX-Dateien, Objekt-IDs oder Grafiken des alten Spiels ändern.
