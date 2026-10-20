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
Die erste Kopf-/Körpermontage wurde vom Nutzer abgelehnt und vollständig ersetzt.
Affen-Schamane, Späher und Raufbold verwenden jetzt separat neu gezeichnete
Ganzkörperposen, einschließlich eigener Rückenansichten. Native Monk-/Warrior-
Bilder dienen als Stilreferenzen, nicht als Körperlieferanten. Originalbögen,
Prompts und Provenienz stehen in art/generated-source/creatures/fullbody-v2.
Tatsächliche Spiel- und Laufsichtprüfung sowie Vergleichsgalerie siehe
[CREATURES.md](CREATURES.md). Native Master werden dadurch nicht ersetzt.

## Persönliches Duo und größeres Waldorf

[DUO_WORLD_BRIEF.md](DUO_WORLD_BRIEF.md) legt vor der Produktion Namen, Dimensionen,
Paletten, Referenzen, Animationszahlen und Erhalt der alten Karte fest. Magier
und menschlicher Schamane sind aus der Heldenauswahl entfernt. Vollständige
Affe-/Panda-Bitmapquellen unter duo-v3, keine Fotomontagen oder privaten
Fotodateien im öffentlichen Repository. Native Red Warrior/Blue Monk als
Actor-Stilmaster, aktuelle Ganzkörper-Kreaturen als Gameplayvergleich.

Gebäude und neue Landschaftsteile verwenden unveränderte bereits lokal
lizenzierte Tiny-Swords-Dateien: House1, House2, Monastery, Tree2 und Rock1.
Die Registry übernimmt ursprüngliche Zellen, Füße und konservative Grundflächen.
Kein neuer Asset-Pack-Download, keine abweichenden Illustrationen. Welt56×40,
Terrain64px, alle Instanzen Scale1 und Nearest. Alte forest.tscn bleibt unverändert;
Dorf/Wege/Grasinsel sind als separate Szene editierbar.

## Aktive Richtung: Referenz-Wald statt Tiny-Swords-Prototyplandschaft

Der neue ausdrückliche Nutzerwunsch nach dem angehängten dichten Wald-/Flussbild
ersetzt die frühere Tiny-Swords-Mastervorgabe für die aktive Landschaft und das
HUD. [REFERENCE_GROVE_BRIEF.md](REFERENCE_GROVE_BRIEF.md) wurde vor Produktion
festgehalten. Keine stille Mischung einzelner Illustrationen: ganze neue Karte
mit zusammengehörigem eigenem Modulset und neuem Boden/HUD. Native Originale
bleiben unveränderte historische Größen-/Technikreferenzen. Affe und Panda
behalten bereits akzeptierte Identitäten und ganze Animationen.

Eigene Quellen: art/generated-source/reference-grove mit vollständigen Prompts,
Originalausgaben, SHA256, gemessenen Schnittrechtecken, Füßen und Produktions-
abmessungen. compile_grove.gd trennt ganze Module, skaliert per Nearest, setzt
binäres Alpha und komponiert pixelharte authored Terrainkanten. Terrain64px,
Wasser128px als2×2Atlas. Keine Quellbilder im Runtime-Editor strecken.
Aktive Szene reference_grove.tscn, alte Handkarten bleiben unverändert.

## Kompaktes HUD und echte Gebiets-Minimap

Der aktuelle Nutzerwunsch verkleinert das HUD auf312×126 statt446×170. Bestehende
Porträt-/Symbol-Bitmaps bleiben unverändert; native Controls/Textgrößen und
Nearest-Sampling werden angepasst, keine unscharfe Skalierung des ganzen HUDs.
Die180×146Minimap oben rechts enthält168×120Pixel reale Weltgrafik, gebacken aus
Ground/River/Paths/CliffFaces und geordneten Scenery-Sprites mit ihren tatsächlichen
Fußpunkten. Vor der Anzeige werden alle unbekannten Zellen vollständig schwarz
maskiert. Spielerpunkt/Rahmen sind funktionale native Controls. Brief und
Abmessungen siehe MINIMAP_BRIEF.md. Keine Terrain-, Figuren- oder Kartenquelle
für diese UI-Änderung neu gezeichnet oder überschrieben.

## Doppelte Waldhöhe, größere Sicht und EP-HUD

EXPANSION_LEVELS_BRIEF.md wurde vor Implementierung festgelegt. Die neue
expanded_grove.tscn übernimmt die komplette Referenzkarte und ergänzt den Süden
auf56×80; bestehende Quelldateien bleiben unverändert. Verwendet werden dieselben
grove-Module mit identischen Frames/Füßen, Licht, Paletten, native64px-Zellen.
1152×800Viewport und Kamera1:1 zeigen mehr Umgebung ohne Sprite-Skalierung.
Goldene3px-EP-Leiste und Lv.-Text sind funktionale Controls im312×126HUD,
keine neue Illustration. Minimap wird mit Nearest und korrektem Seitenverhältnis
in dasselbe kleine Panel eingepasst. Gegnerstufen sind lesbare native Labels.
Die bereits dokumentierte Stilabweichung der Referenzlandschaft gegenüber den
historischen Tiny-Swords-Mastern bleibt bestehen; kein neues Stilmaterial.
