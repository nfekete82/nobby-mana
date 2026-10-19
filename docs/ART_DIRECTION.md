# Prototyp: bestehende native Pixelgrafiken

Vor der Implementierung festgelegt: Terrain 64×64, Actor-Zelle 192×192,
Fuß [96,132], Hitbox 32×24. Nobby: Stand zwei stabile Posen [1,3] aus sechs
Quellframes bei 1,5 FPS, Lauf vier Frames bei 10 FPS, Angriff elf bei 28 FPS.
Native rote Krieger: Stand acht Frames bei 4 FPS, Lauf sechs bei 12 FPS,
Angriff vier bei 14 FPS. Baum groß: 192×256, Fuß [96,234], acht bei 2,5 FPS;
kleiner Baum 192×192, Fuß [96,164]; Busch 128×128, Fuß [64,99].

Referenzen sind die tatsächlichen bestehenden Dateien aus Nobby World:
`art/style-references.json`: enemy-warrior als nativer Actor-Master,
hero als Identitätsreferenz, tree-oak/tree-small/bush als native Landschaft.
Die dortigen docs/ART_STYLE.md und docs/TINY_SWORDS_ART_DIRECTION.md sowie
BIOME_ART_DIRECTION.md und STYLE_AND_AGGRO_REVIEW.md wurden vorab gelesen.
Verwendete Quellen und unveränderte Pixeldateien sind in art/registry.json
mit SHA-256 dokumentiert. Keine neuen oder generierten Sprites.

Materialien: dunkle schieferblaue Konturen #293544, Salbei/Olive für die Wiese,
warmes Ocker für den Boden, blaue Robe, rote Gegner, Creme für UI-Text.
Licht und Schatten bleiben wie in den nativen Quellbildern. Terrain verwendet
Original-Innenzellen und neun zusammenhängende Wegkanten einschließlich Ecken.
Keine zufälligen Tile-Grafiken, kein Blur, keine fraktionale Sprite-Skalierung.

Einzige bewusste Darstellungsgrenze: die bisherigen Sheets besitzen keine
vollständigen vier Blickrichtungen. Bis dafür zusammenhängende neue Animationen
vorliegen, werden existierende Posen gespiegelt. Kein Anspruch auf fertige
Secret-of-Mana-Optik oder finale visuelle Parität. UI-Rahmen und Balken sind
native Godot-Controls, keine Illustrationsersatzgrafiken.

## Skelettbegleiter

Vor der Umsetzung festgelegt: dieselben vorhandenen `skeleton`-Assets aus
Nobby Worlds Registry, Identitätsreferenz `skeleton`, nativer Proportionsmaster
`enemy-warrior`, Gameplayvergleich Nobby und die bisherigen Skelettbegleiter.
Alle Zellen 192×192, Fuß [96,132], Hitbox 32×24. Je zwei getrennte Richtungsreihen:
Stand sechs Quellframes (stabile Posen [0,2]) bei 4 FPS, Lauf sechs bei 10 FPS,
Angriff sechs bei 16 FPS, Spawn sechs bei 9 FPS, Treffer zwei bei 10 FPS,
Tod vier bei 8 FPS. Animationen werden ohne Skalierung/Trimming ausgelesen;
Nordbewegung verwendet die Rückenreihe. Keine neuen Bildpixel. Materialpalette
bleibt Knochen/Creme, dunkle Schieferkonturen und blaue Kleidung wie im alten
Spiel. Alle neuen lokalen Eingaben und SHA-256-Werte stehen im Manifest.

## Kompaktes Ressourcen-HUD

Siehe [HUD_BRIEF.md](HUD_BRIEF.md): funktionale rote/blaue Füllanzeigen unten
mittig, native 64px-UI mit pixelharten Kanten und flachen Farbstufen. Keine neuen
Sprites, keine übernommenen Diablo-Grafiken. Gegnerbalken sind native 48×6px-
Controls; Füße, Spritegrößen, Hitboxen und Animationen bleiben unverändert.

## Aktueller Stand: Klassen und linkes HUD

[CLASSES_ART_BRIEF.md](CLASSES_ART_BRIEF.md) ersetzt die frühere mittige
HUD-Anordnung: gestaffelte 96px-Kugeln ganz links, R-Skelettslot daneben.
Schamane, native Animationsmetadaten, eigene kleine Pfeil-Pixelpläne und
die größere editierbare Karte sind dort mit Referenzen/Abmessungen dokumentiert.

## Affen-Schamane und Waldkobolde

[CREATURE_ART_BRIEF.md](CREATURE_ART_BRIEF.md) dokumentiert die vorab festgelegten
nativen Referenzen, 192px-Zellen, Füße/Hitboxen, Paletten und Animationszahlen.
Neue Identitätsteile werden mit echten bestehenden Monk-/Warrior-Bewegungen
komponiert; keine generierten Ersatzbeine. Quellen/Prompts bleiben getrennt
von lokalen Produktionsatlanten. Tatsächliche Spiel- und Laufsichtprüfung
und die animierte Vergleichsgalerie sind in [CREATURES.md](CREATURES.md) beschrieben.
