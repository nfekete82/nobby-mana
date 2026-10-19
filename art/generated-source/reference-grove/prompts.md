# Referenz-Wald – vollständiger Imagegen-Promptsatz

Werkzeug: eingebautes `image_gen.imagegen`. Eigene generierte Bitmapquellen, keine ausgeschnittenen Bildteile aus der Nutzerreferenz. `environment.png` enthält Landschaftsmodule, `terrain.png` den ersten Versuch, `terrain-v2.png` den ruhigeren produktiven Boden, `hud-icons.png` die vier Aktionssymbole. Alle Originalausgaben erhalten. Layout/Palette/Anker und Produktionsgrößen stehen in layout.json und art/registry.json. Die neue Nutzer-Bildreferenz ersetzt ausdrücklich die vorherige Tiny-Swords-Prototyplandschaft als aktive Stilrichtung.

## Landschaft

Create a coherent PRODUCTION PIXEL-ART GAME ENVIRONMENT ASSET SHEET based on the USER'S MOST RECENT REFERENCE GAME SCREENSHOT. This is for an actual topdown action RPG, NOT a concept painting. Match its lush emerald forest, chunky crisp detailed pixel clusters, dark bluegreen shadows, warm gold thatch/wood, flower-rich grass, grey rock cliff banks, visible top surfaces and front faces, upperleft sunlight. Style transition approved from earlier Tiny Swords; same-category historic references native Tree1/House1/Warrior, comparable gameplay assets personal monkey/panda chibi characters. Aim for the screenshot's inviting classic 16bit HD pixel finish with limited tonal steps/material, clearly placed square pixels, no smooth gradients/blur/antialias or realistic painterly texture.
STRICT atlas: square1536x1536, exactly3equal columns x3equal rows;9 COMPLETE SEPARATE isolated assets, each within its own512x512cell with abundant actual transparent gutter. No text, ground backdrop, checkerboard, gridlines, labels, extra objects spilling between cells. Every asset complete with fixed feet, no clipping. Assets seen in same 3/4 topdown perspective:
Row1 col1 LARGE LUSH BROADLEAF OAK, round layered dense emerald canopy, dark teal shadow gaps, thick curved brown trunk with roots; entire tree incl trunk visible, approximate native192x256.
Row1 col2 COZY TIMBER COTTAGE, honey GOLD THATCH ROOF, dark timber/plaster walls, front arched door, small window, lantern, a little redflowerbox; full standalone building native256x320, NO large ground/base rectangle, NO plants obscuring door. NOT blue roof, not castle.
Row1 col3 ROCK RIVER CLIFF SEGMENT, grassy top rim, tall irregular grey stone front with2-3 column faces and moss, native128x192, isolated column usable repeatedly along a riverbank, NO water or backdrop.
Row2 col1 FULL HORIZONTAL WOODEN FOOTBRIDGE, traversable left-to-right (west/east) across a vertical river, topdown planks with slight visible front edge, four corner rope posts, thin rope rails only along TOP and BOTTOM sides, open entrances LEFT and RIGHT; native448x192, full entire bridge in cell without clipping; do NOT make diagonal bridge or block its entrances.
Row2 col2 WATERFALL vertical cascade of deep cyan water and pixel white foam, tall transparent isolated stream native128x320; open top cut flat for connecting to water channel, foam pool at bottom, no rock frame/background.
Row2 col3 FLOWER CLUSTER small irregular meadow tuft with white daisies, a few pink and yellow blooms, native64x64, no rectangle of grass, just small foliage and flowers.
Row3 col1 WOODEN FENCE SEGMENT west-east, two upright timber posts linked by two horizontal rails, modest moss, native128x96, no dirt backdrop.
Row3 col2 SMALL CLOSED TREASURE CHEST with brown wood, gold metal bands, simple latch, native64x64, same perspective, no glow or platform.
Row3 col3 LUSH LOW SHRUB emerald green rounded leaves and a few light lime tips, native128x128, complete silhouette.
Match density, palette, light and scale between all9 modules. Separate silhouettes and transparency vital. Ready to extract as reusable game sprites, NOT a pasted screenshot.

## Erste Terrainquelle

Generate a production-ready TOPDOWN PIXEL ART TERRAIN TEXTURE ATLAS for the lush classic action RPG in the user's reference screenshot. Four square texture swatches in a strict2x2 layout on a1024x1024canvas, each512x512 quadrant ENTIRELY filled by its seamless tile texture, no gutters/borders/labels/shadows. Top-left: lush bright emerald/lime meadow grass, small deliberate square pixel tufts and a few darker green clusters, NO flowers or trees or objects. Top-right: warm ochre light brown packed earth walking path, subtle irregular small pebbles and compact soil clusters, no big rocks, no grass edges, entirely dirt texture. Bottom-left: vibrant clear cobalt/cyan flowing river water with angular ripples, darker irregular blue cells and brightcyan short pixel highlights, no foam borders, no land, no reflections of objects. Bottom-right: warm moss-grey rock wall/stony surface with chunky flat facets and discreet dark cracks, no plants, no objects.
EACH QUADRANT must be seamlessly repeatable on its own with matching left/right and top/bottom edges, no gradients or lighting vignettes across a quadrant. Match the rich but crisp detailed pixel clusters of reference image and new tree/house modules, NO blurry handpainted texture or smooth gradients, no photographs, no anti-aliasing. Native intended terrain64x64, represent every native pixel as8x8 solid blocks in its512swatch.4materials only, simple clean repeating playable terrain. Opaque textures.

## Überarbeitete Terrainquelle

Edit the supplied terrain texture atlas, preserving exact2x2 layout and materials but RADICALLY REDUCE MICRODETAIL AND CONTRAST. The last game screenshot showed noisy grass/dirt. This must read as quiet ground under detailed trees and characters, not busy confetti.
TOPLEFT grass: 80% gently varied broad mid green #55933b / #639e40, only a few small darkleaf or lime grass clusters, NO yellow speckle, NO white flecks, NO tiny1pixelnoise. Large flat4-8nativepixel clusters. This is smooth in detail density but STILL CRISP PIXELART, NOT blurry.
TOPRIGHT earth: warm light brown/tan #c7a16c / #d4b17c, broadly flat with a handful of small pebbles, NOT hundreds of black cracks or random pixels.
BOTTOMLEFT water: retain clear blue/cyan ripples, larger simple ripple shapes and lower density, clean and readable.
BOTTOMRIGHT moss grey stones: keep simple flat rockfacets.
Every quadrant is exactlyhalf of a squarecanvas, fills it entirely, independently seamless left/right/top/bottom, no gutter/text/objects or border. Native intended64x64 per texture with deliberate square pixelclusters. No antialias, no texture noise, no smooth illustration.

## HUD-Symbole

Create FOUR polished classic fantasy PIXEL ART HUD ICONS matching the user's reference HUD screenshot: square dark slots with crisp ivory/gold-rimmed illustrated symbols, readable at native48x48. Exactly2columns by2rows on square1024x1024 atlas with actual transparent background and generous transparent gutters. Each icon complete centered in its quadrant, same artstyle/size. No slot backgrounds, no frame, no letters, no text, no labels, no glow spilling into gutters.
TOPLEFT: diagonal steel SWORD with pale silver blade, gold simple crossguard, brown leather grip, pointed upperright; matches reference attack icon.
TOPRIGHT: bright green HEALING PLUS cross, thick solid chunky cross shape, cream small highlights and darker green bottom/right shadows, crisp pixel contours.
BOTTOMLEFT: ivory SKELETON SKULL with black eye sockets, small crossed bones below, warm cream highlights, dark brownslate outline.
BOTTOMRIGHT: tan/brown LEATHER ITEM POUCH with drawstring, rounded bag and short tied neck, goldcord, simple shaded material.
Rich clean square pixel clusters, firm dark navy contours, flat3-4 shades/material, upperleft lighting. Not emoji, not vector, not smooth clipart, no photorealistic material. Designed as one coherent production HUD icon set. Native icon48x48 pixels with nearest pixel blocks magnified in source. Source targetreference screenshot and latest lush tree/cottage modules in conversation.
