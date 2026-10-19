# Vollständige Figuren – Neubau v2

Der Nutzer hat die Kopf-/Körpermontage abgelehnt. Dieser Brief ersetzt die
bisherige Produktion: Affe, Späher und Raufbold werden als ganze Figuren neu
gezeichnet. Kein Übernehmen von Monk-Beinen, Warrior-Rüstung, ausgeschnittenen
Köpfen oder gedrehten Standbildern als Tod. Bestehende Figuren bleiben unverändert.

Vor der Produktion: Native Same-Category-Master sind Blue Monk Run/Idle und
Red Warrior Idle/Run aus dem lokal lizenzierten Tiny-Swords-Pack. Vergleich im
Gameplay: vorhandener menschlicher Schamane und enemy-warrior. Stilregeln aus
nobby_world/docs/ART_STYLE.md, art/style-references.json und
TINY_SWORDS_ART_DIRECTION.md gelten weiterhin: große flache Pixelcluster,
schieferblaue Kontur, 3–4 Farbstufen je Material, Licht oben links, 3/4-Aufsicht.

Runtime-Zellen 192×192, fester Fuß [96,132], Hitbox 32×24. Affe ca. 70px hoch,
Kobolde ca. 60–64px. Quellen enthalten vollständige Figuren auf regelmäßigem
Raster; eine feste gemeinsame Nearest-Skalierung pro Figur, keine einzelnen
Körperteile und kein Strecken pro Pose. Richtungen separat gezeichnet.

Affenquelle: 6 Spalten × 8 Reihen. Je Richtung vier Reihen: zwei Stand-, zwei
Treffer-, zwei Todesposen in Reihe 0; sechs Laufposen in Reihe 1; sechs Wurfposen
in Reihe 2; sechs Beschwörungsposen in Reihe 3. Danach dieselben Aktionen von
hinten. Stand 2/2 FPS, Lauf 6/12, Wurf 6/15, Beschwörung 6/5, Treffer 2/10,
Tod 2/4. Braunes Fell, cremefarbene Schnauze/Pfoten, kurze petrolfarbene
Waldkleidung, Holzstab, kleiner Schweif; eigener nichtmenschlicher Körper.

Koboldquellen: je 6 Spalten × 8 Reihen. Pro Richtung: Stand vier und Treffer
zwei; Lauf sechs; Angriff sechs; Tod sechs. Stand 4/3 FPS, Lauf 6/12, Angriff
6/15, Treffer 2/10, Tod 6/12. Geduckter Körper, sichtbare kurze Beine, große
spitze Ohren, moosgrüne Haut und dunkles Leder. Späher: leichter Blattumhang,
kleiner Dolch. Raufbold: breitere Silhouette, ockerfarbene Weste, Holzkeule.

Neue vollständige Bitmapbögen mit eingebautem Imagegen, danach deterministische
Rasteraufteilung und harte Alpha-/Materialpalette. Quellen, Prompts und SHA256
getrennt von kompilierten Laufzeit-PNGs. Strukturtests sind kein Stilnachweis:
Galerie neben tatsächlichen Godot-Aufnahmen bei nativer Pixelgröße prüfen.
