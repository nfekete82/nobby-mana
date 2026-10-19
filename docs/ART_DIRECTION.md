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
