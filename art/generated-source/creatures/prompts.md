# Imagegen-Produktionsprompts

Werkzeug: eingebautes `image_gen.imagegen`, keine CLI/API-Fallbacks.
Transparenz für beide Aufrufe aktiviert. Die PNG-Quellen wurden nach der
Erzeugung unverändert ins Projekt kopiert; Produktion erfolgt ausschließlich
über `tools/compile_creatures.gd` (Native-Motion-Komposition, Nearest,
Palettenquantisierung, binäres Alpha und feste Zellen).

## monkey-parts.png

Referenzrollen: native Blue Monk Run als Same-Category-Master,
bestehender shaman-stand als Gameplay-/Materialvergleich, nativer Red Warrior
Idle für Proportionen/Kontur.

Use case: stylized-concept, production pixel-art sprite COMPONENTS for a playable monkey shaman in an existing Tiny Swords game. Input 1 is the approved native Pixel Frog Monk animation style master, input 2 is the existing gameplay shaman identity/material reference, input 3 is the native actor proportion/outline reference. Reuse that exact chunky hand placed pixel technique, not generic detailed pixel illustration. Create a transparent 1024x1024 sheet with FOUR clearly separated quadrants of equal 512x512 cells: top left ONE front three-quarter monkey HEAD only, top right matching rear monkey HEAD only, bottom left the exact same front monkey HEAD with eyes gently closed for casting, bottom right ONE simple curled monkey TAIL only. No bodies or clothes on the heads, no labels or grid. Friendly brown-furred monkey, large round ears, tan muzzle, dark eyes, subtle fur tuft, NO human hair bun, NO human beard. Each head occupies about 384x320 pixels within its cell and is drawn as a nearest-neighbor 8x enlargement of an approximately 48x40 game-pixel head; all edges use clean regular large square pixel steps, very few slate outline pixels in game resolution, broad flat color clusters. Tail is a simple readable brown curl, no hair texture. Color steps ~3 per brown fur/tan material; slate outlines, upper-left lighting, flat matte shading, compact rounded chibi forms. Same identity in front/back/closed-eye heads. Real transparent alpha, no checkerboard painted, no ground shadows, no anti-aliasing, no blur, no gradients, no glow, no jewelry, no extra items. These parts will be reduced only with nearest filtering and attached to the unchanged native Monk robe/arms/feet animation at 52x44 native head size.

## goblin-parts.png

Referenzrollen: nativer Red Warrior Idle und Black Warrior Run als
Same-Category-Master, vorhandener Schamane als Gameplayvergleich.

Use case: stylized-concept. Production sprite COMPONENTS for small forest goblin enemies in the existing Pixel Frog Tiny Swords game. Input 1 and 2 are approved native same-category actor/weapon masters, input 3 is comparable existing gameplay character scale/material reference. New goblin head parts will replace the warrior helmet while keeping all authentic native body/foot/weapon poses. Create a square transparent sheet with FOUR equal quadrants, isolated HEAD only in each quadrant: top left forest goblin front three-quarter neutral, top right same goblin back head, bottom left same front head fierce attacking expression with mouth open, bottom right same front head hurt/eyes squinted. No bodies, weapons, text, tile boundaries or props. Goblin: olive/sage green skin, broad pointed ears, short blunt nose, two tiny ivory lower fangs, dark eyebrows, short dark moss-green hair tuft; mischievous woodland creature, readable friendly-game monster, not gruesome. Match the references EXACT coarse low-resolution chibi pixel clusters, slate outlines, flat ~3 shades per material, upper-left highlight. Not a detailed portrait, no texture noise. Each head should occupy 380x300 pixels inside its quadrant and be a clean nearest-neighbor 8x enlargement of a tiny approximately 46x34 native-pixel game head, deliberately chunky square steps, simple facial features. Keep all 4 heads exactly same width/height, ears/skull silhouette and viewpoint; back head shows no facial features. Real transparent alpha everywhere else, no painted checkerboard, no shadows, no blur, no antialiasing, no glow, no soft gradient, no human ears, no helmet or hat. These become small native gameplay heads, not illustrations.

## Tatsächliche Ausgabe und Produktion

Das Tool erzeugte beide Quellen mit 1280×1280 statt der angefragten
1024×1024 Pixel. Der Compiler liest tatsächliche Halbzellen und Alpha-Grenzen;
keine fest angenommene Quelldateigröße. Kopf-/Schweifteile werden einmalig
unter Beibehaltung des Seitenverhältnisses auf native Zielgrößen gebracht
und gegen die dokumentierte Materialpalette quantisiert. Die Figurenzellen
selbst werden im Spiel niemals gestreckt oder automatisch getrimmt.
