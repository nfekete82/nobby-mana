# Erster Prototyp · 19. Oktober 2026

- Godot 4.7.2 Standard: vollständiger Headless-Import ohne Scriptfehler.
- `python3 tools/check_project.py`: Struktur und alle 14 lokalen PNGs geprüft;
  Framegrößen, unveränderte SHA-256-Werte und Ausschluss aus Git bestätigt.
- `tests/combat_smoke.gd`: echte Physikframes für normale/diagonale Bewegung,
  Weltkollision, Angriffswindup, genau einen Treffer, Immunitätsfenster,
  Reichweite/Blickrichtung, Tod, einmaligen Zielfortschritt und Wandblockierung.
- `tests/capture.gd`: echter nativer Godot-/OpenGL-Screenshot aufgenommen und
  nach einer Korrektur der HUD-Abstände und Balkenfarbe erneut angesehen.
- Screenshot mit Nobby Worlds generierter Referenzgalerie im Browser verglichen:
  enemy-warrior, hero, tree-oak, tree-small und bush. Sprites behalten ihre
  Originalpixel und Fußpunkte; der Prototyp beansprucht keine fertige SNES-Optik.
- Die laufende neue Szene wurde nativ in Godot geprüft. Ein Browser-Spieltest
  des neuen Projekts ist noch nicht vorhanden, da kein Web-Export eingerichtet
  ist. Der native Screenshot liegt lokal in `artifacts/clearing.png`.
- Die im bestehenden Projekt vorgeschriebenen Checks wurden ebenfalls ausgeführt:
  `npm run art:style:check`, `npm test` (134/134), `npm run build` und
  `npm run art:references` bestanden. Build meldet nur die bestehende Chunkgröße.

Offen: manuelle Bewertung des Kampfgefühls durch den Spieler, vollständige
vier Blickrichtungen, Dorf, Dialoge, Dungeon/Boss und neue Spielstände.
Das öffentliche Repo enthält keine PNGs und keine Godot-Engine. Ein öffentlicher
Clone ist erst nach Einrichtung der rechtmäßig bezogenen Grafiken spielbar.

## Erweiterung: beschworene Skelettbegleiter

Regeln aus Nobby World: R bzw. HUD-Button, 10 Mana, drei Begleiter, keine
Beschwörungswartezeit, 120 Sekunden, 85 HP und 10 Schaden. Mana regeneriert
nach 0,25 Sekunden Ruhe mit 5 Punkten pro Sekunde. F5 ersetzt R als Neustart.
Der Prototyp besitzt keine Klassenwahl; Nobby kann die Fähigkeit direkt nutzen.

Neue Dateien: `scripts/companion.gd`, `scripts/navigation.gd`,
`tests/companions_smoke.gd` und zugehörige Godot-UIDs.
Angepasst: Player/Fighter/Enemy/Clearing, Art-Loader und Registry, PNG-Prüfung,
Screenshot-Skript, Start-/Editor-Dateien, README, Art-Direction und Credits.
Keine PNG-Pixel verändert. Die sechs vorhandenen Skelett-Sheets werden nur lokal
kopiert. Alle 20 lokalen PNGs bestehen Hash-/Framegrößenprüfung inklusive
beider 192px-Richtungsreihen. Lizenzierte Dateien bleiben aus Git ausgeschlossen.

Godot-Import ohne Scriptfehler; ursprünglicher Combat-Smoke und neuer
Companion-Smoke bestanden. Neue Tests umfassen tatsächlichen R-Input,
Manakosten/Limit/Fehlschläge, Regeneration, kollisionsfreie getrennte Spawns,
Zielbindung trotz entfernten Besitzers, tatsächliche KI-Schadensabwicklung auf
beiden Seiten, keine freundlichen Treffer, nähestes erreichbares Gegnerziel,
A*-Umweg samt tatsächlichem Treffer nach einer Wandumrundung, Ablehnung eines
eingeschlossenen Ziels, echtes Folgen, Rückenanimation, Ablauf/Tod/Ersatz,
Besitzertod sowie F5-Neustart mit zurückgesetztem Mana und Begleiterstand.

Native Screenshots `artifacts/summon-party.png` und `artifacts/summon-combat.png`
aufgenommen und bei 1:1-Pixelzoom neben den aktuellen Browser-Referenzkarten
`skeleton` und `enemy-warrior` angesehen. HUD nach dem ersten Screenshot
verschmälert, damit es Nobby am Start freilässt. Beide Richtungsreihen werden
unverändert dargestellt. Keine Behauptung einer neuen/fertigen SNES-Art-Direction.
Ein Web-Spieltest des Godot-Projekts bleibt mangels Web-Export noch ausstehend;
die Sichtprüfung erfolgt mit echten nativen Godot-Screenshots.

Auch die vorgeschriebenen Prüfungen im alten Referenzprojekt bestanden:
`npm run art:style:check`, `npm test` (134/134), `npm run build`,
`npm run art:references`. Bestehende Buildwarnung zur Chunkgröße bleibt bestehen.

## Kompaktes HUD und Gegneranzeigen

Geändert: `scripts/clearing.gd` (320×84px-Dock unten mittig),
`scripts/enemy.gd` (Lebensbalken, Entfernung nach Tod),
`tests/combat_smoke.gd` (lebenden zweiten Gegner vor Tod des ersten referenzieren),
README und Art-Direction. Neu: `scripts/resource_orb.gd`,
`shaders/resource_orb.gdshader`, `tests/hud_enemy_smoke.gd` und HUD-Brief.

Referenzen: bisherige HUD-Palette, native Tiny-Swords-WoodTable-UI und
vorhandene Gameplay-Sprites. Keine neuen Bitmapassets oder Änderungen an
Sprites/Frames/Füßen. Shader ist eine funktionale native Ressourcenanzeige
mit harten 64px-Kanten, flachen Farbflächen und vertikalem Füllstand.

Godot-Import, Combat-Smoke, Companion-Smoke und HUD/Enemy-Smoke bestanden.
Letzterer prüft echte Health-/Mana-Signale samt Füllwerten, mitwandernde
Gegnerbalken und deren tatsächliche 48×6px-Größe trotz Theme-Mindestgrößen,
zentrierten unteren Anker bei 960×640, 1280×720 und 640×480, sofortige
Entfernung aus der Zielgruppe, einmaligen Zielfortschritt sowie tatsächliche
Freigabe des besiegten Gegners nach 0,3 Sekunden Fade.

Echter nativer Kampfscreenshot `artifacts/summon-combat.png` visuell geprüft.
Im ersten Bild waren die Theme-Mindesthöhen der Balken zu groß; korrigiert
und erneut aufgenommen. Das große linke Panel ist entfernt, der Spielbereich
bleibt frei. Die WoodTable-Quellreferenz wurde daneben angesehen. Die native
Godot-Sichtprüfung ersetzt weiterhin den noch nicht eingerichteten Web-Export.

Vorgeschriebene Referenzprojekt-Checks bestanden ebenfalls: art:style:check,
134/134 npm-Tests, Build und art:references. Bestehende Buildwarnung zur
Chunkgröße bleibt unverändert.

## Klassen, Pfeile, linkes HUD und editorfähige größere Karte

Neue Funktionen: Startauswahl Magier/Schamane, Esc zurück zur Auswahl,
Pfeilwurf per Linksklick/J, klassenspezifischer Schaden/Mana, Skelette nur
für den Schamanen. F5 behält die ausgewählte Klasse. Der Schamane nutzt
die bestehenden vier nativen Monk-Laufposen samt Rückenreihe unverändert.
HUD unten links mit zwei gestaffelten 96px-Kugeln, R-Skelettsymbol und
Pfeilslot; nur das Layout des Nutzerbilds übernommen, keine Diablo-Bilder.

Die neue 40×28-Karte liegt in scenes/levels/forest.tscn mit echten
Ground-/Paths-/Barriers-TileMapLayern, Scenery-Props, Gegner-Markern und
PlayerSpawn. Kamera und Navigation lesen die Mapgröße; der einmalige
Bootstrap überschreibt niemals vorhandene Szenen. Das alte Tiled-Projekt
ist unverändert. Editor.command öffnet direkt die neue Kartenszene.

Neu: Session, Startmenü/-szene, Projectile, LevelData/LevelProp, forest.tscn,
create_level.gd, eigener Pfeil-Pixelplan, Classes/Editor-Smoke und Anleitungen.
Geändert: Player, Clearing, Navigation, Art-Loader/Registry, Orbs/Shader,
Startdateien, Projektkonfiguration, Asset-Setup/-Checks, Capture und HUD-Test.
Alle Details und Grenzen: CLASSES_ART_BRIEF.md und LEVEL_EDITOR.md.

Prüfungen bestanden:
- Vollständiger Godot-Import und regulärer Start mit Autoload/Startmenü.
- Combat-, Companion- und angepasstes HUD/Enemy-Smoke.
- Classes/Projectile/Editor-Smoke mit echten Klassenbuttons und J-Eingabe,
  Flugzeit/Schaden/Manakosten/Cooldown, Wandblockierung, fehlendem Mana,
  maximaler Pfeilreichweite und Freigabe fliegender Pfeile bei Klassenwechsel.
- Erweiterte Navigation bis zur östlichen Lichtung und passende Kameragrenzen.
- Tatsächliche Kollision einer gemalten Barriers-Kachel im unsichtbaren
  Runtime-Layer. Speichern/Laden von Boden, Sperrflächen und verschobenem
  Gegner in einer temporären Testdatei; Projektkarte dabei nicht gespeichert.
- Die tatsächliche forest.tscn im Godot-Editor geladen, keine Tool-Scriptfehler.
- 26 lokale Lizenz-PNGs mit Hash-/Framegrößen-/Richtungsreihenprüfung; eigene
  Pfeilquellen/kompilierte Maße geprüft; Binärgrafiken weiterhin aus Git ausgeschlossen.
- Referenzprojekt art:style:check, 134/134 npm-Tests, Build, art:references.

Native Screenshots class-selection.png, summon-combat.png, shaman-shot.png,
mage-shot.png und eastern-glade.png bei nativem Pixelzoom angesehen;
Schamanen-/Warrior-/Skelettreferenzen und Browsergalerie verglichen. Keine
neue SNES-Art-Direction behauptet. Eigene Pfeile sind eine dokumentierte
Ergänzung, da der vorhandene Packbestand keinen nativen Pfeil enthält.
Godot-Web-Export bleibt noch nicht eingerichtet; Spiel-Sichtprüfung nativ.

## Affen-Schamane, Waldkobolde und native Animationen

Neue Bildquellen mit eingebautem Imagegen: monkey-parts.png/goblin-parts.png,
je 1280×1280 mit Alpha; Prompts und SHA-256-Provenienz unter
art/generated-source/creatures. Keine CLI/API-Fallbacks. Der neue deterministische
Godot-Compiler normalisiert einmalig Kopf/Schweifteile per Nearest, quantisiert
Paletten, setzt binäres Alpha und komponiert feste 192px-Zellen mit [96,132]-Fuß.
Die Produktionsbilder enthalten bestehende lizenzierte Körperposen und bleiben
unter dem ignorierten assets/compiled. Native Packbilder wurden nicht verändert.

Neu: drei Registry-Einträge (Affen-Schamane, Kobold-Späher/Raufbold), Compiler,
Bildteile/Prompts/Provenienz, Encounter-Marker und drei platzierbare Szenen,
animierte Galerie, Kreaturentest und Spiel-Capture. Angepasst: Klassenmenü/Session,
Player/Fighter/Enemy, Clearing, LevelData, Art-Loader, Setup/Checks, Launcher und
Regressionstests für dynamische Gegnerzahlen. README/Editor-/Art-Dokumentation
und Credits ergänzen Quellen, Bedienung und Grenzen.

Die bereits manuell bearbeitete scenes/levels/forest.tscn wurde nicht angefasst
oder mit eingecheckt. Vier neue Gegner stehen in einer separaten Zusatzszene;
die vorhandenen beiden Encounters und deine Karteneinstellungen bleiben erhalten.

Bestanden: Godot-Import, Combat-Smoke, Companion-Smoke, HUD/Enemy-Smoke,
Classes/Projectile/Editor-Smoke und Creature-Smoke. Neue Tests prüfen sämtliche
16 neuen Produktionsatlanten mit nativen Einzelzellen, zwei getrennten Reihen,
binärem Alpha und nichtleeren Posen. Alle vier nativen unteren Roben-/Beinphasen
bleiben in beiden Richtungen pixelgenau erhalten; entgegengesetzte Kontakte
und Durchschwünge bleiben verschieden. Affen-Klassenbutton, elfteilige
Beschwörung, Übergang zu Rückenlauf, echter Pfeiltreffer, tatsächliche Kobold-KI-
Treffer, unterschiedliche Werte und Todesanimation/Entfernung wurden geprüft.
Koboldgruppe wurde ohne Tool-Scriptfehler im nativen Godot-Editor geladen.

Echte Gameplaybilder: artifacts/creatures/party.png und walk-gameplay.png
(vier tatsächliche Front-/Rücklaufzustände). Nach der ersten Aufnahme wurden
ausschließlich Testreste aus dem Capture entfernt. Beide Bilder anschließend
bei nativer Pixelgröße angesehen. Browsergalerie review.html und einzelne
192px-Karten von originalem Schamanen, Affe und Kobold daneben verglichen.
Erweiterte Klassenwahl ebenfalls aufgenommen und geprüft.

42 lokale Runtime-PNGs strukturell geprüft (26 bestehende Lizenzdateien und
16 neue Kompilate). Referenzprojekt ebenfalls grün: art:style:check, 134/134
npm-Tests, Build, art:references. Bestehende Chunkgrößenwarnung bleibt bestehen.

Grenzen: bestehende native Körperbewegungen werden wiederverwendet und für
Rückansichten abgeleitet; keine vollständig separat gezeichneten vier
Blickrichtungen. Die Galerie ist eine Sichtprüfung, kein Beweis für perfekte
Animation oder vollständige Stilparität. Kein neuer Godot-Web-Export eingerichtet.

## Vollständige Figuren v2 (ersetzt die abgelehnte Montage)

Die frühere Sichtprüfung der montierten Kopf-/Körperfiguren ist durch die
Ablehnung des Nutzers überholt. Affe, Späher und Raufbold wurden nun als
vollständige Figuren neu erstellt; Produktionsbrief vorab aktualisiert.
Imagegen eingebaut, drei unveränderte Quellen (je1086×1448), vollständige
Prompts/SHA256/Layout unter art/generated-source/creatures/fullbody-v2.
Referenzen: native Blue Monk Run, Red Warrior Idle und Gameplay shaman-stand.
Native Masterdateien bleiben unverändert, keine Körper aus ihnen montiert.

Geändert: Quellen, Registry, Compiler, Creature-Dokumentation/Galerie,
Frame-/Gameplaytest und tatsächliche Laufaufnahme. Beschwörungsdauer liest
nun die verwendete Animation (Affe6/5=1,2s, Mensch weiterhin11/9s).

Geprüft: python3 tools/check_project.py (42 lokale Runtime-PNGs plus eigene
Quellhashes/-abmessungen); Godot headless editor import --quit; combat_smoke,
companions_smoke, hud_enemy_smoke, classes_editor_smoke, creatures_smoke alle
PASS mit0Fehlern. Echte Editor-Vorschau forest_goblins ohne Scriptfehler.
Zusätzliche vorgeschriebene Checks im benachbarten nobby_world:
art:style:check PASS; npm test134/134PASS; npm run build PASS (bekannte
Chunkgrößenwarnung); art:references PASS. Der erste npm-Testversuch scheiterte
am Sandbox-gesperrten lokalen Listen-Port; Wiederholung mit lokalem Portzugriff
bestand vollständig. Alte handbearbeitete TMX-Karten nicht überschrieben.

Visuell: tatsächliche Godot-Aufnahme artifacts/creatures/party.png und sechs
Vorder-/Rücken-Laufphasen in walk-gameplay.png bei nativem Pixelzoom angesehen;
animierte Chrome-Galerie review.html und native style-reference.html ebenfalls
geprüft. Eigene Körper lesen sich zusammenhängend, Größen passend, feste Füße,
harte Pixel, kein Kopf-/Ritterkörper-Mix. Kein Versprechen perfekter Animation
oder identischer Handschrift zum Originalpack: selbstständige generierte
Figuren bleiben etwas kleinteiliger schattiert. Zwei echte Ansichten plus
seitliche Spiegelung, keine vier vollständig getrennten Richtungsbögen.
Ein falscher liegender Scout-Angriffsframe wird bewusst nicht verwendet;
Layout dokumentiert die Auswahl vollständiger Ersatzposen aus derselben Folge.

Die zuvor manuell bearbeitete scenes/levels/forest.tscn bleibt unverändert
außerhalb dieses Grafikcommits. Keine Szenen-IDs, Platzierungen, Kollisions-
oder Kampfwerte durch diese Änderung ersetzt.

## Persönliches Heldenduo und Dorf (aktueller Stand)

Vorabbrief: DUO_WORLD_BRIEF.md. Magier und menschlicher Schamane aus Auswahl,
Session und Spielerlogik entfernt. Nur Affe und Panda starten reguläres Gameplay.
Affe: Dutt/Bart nach Nutzerfoto, Pfeile und Skelette erhalten. Panda: stilisierte
schwarze Brille, blonde Seitenfrisur, Koralltunika nach zweiter Fotoreferenz;
125Leben, Start-Holzschwert28Schaden. Linksklick/J lösen klassenspezifisch Schwert
oder Pfeil aus, Leertaste schlägt im Nahkampf. Panda-HUD zeigt Schwert und Leben,
keine nutzlose Mana-/Beschwörungsanzeige. Alte menschliche PNG-Metadaten verbleiben
nur als historische lokale Grafikreferenzen, nicht als spielbare Klassen.

Vollständige neue Heldenbögen mit eingebautem image_gen.imagegen, keine
Fotomontagen oder privaten Fotodateien im Repo. Originale Quellen/Prompts/SHA256
unter art/generated-source/creatures/duo-v3. Native Referenzen: Red Warrior/Blue
Monk; Gameplay-Vergleich mit aktuellen ganzen Kreaturen. Häuser1/2, Monastery,
BirkeTree2 und Rock1 stammen unverändert aus dem bereits lizenzierten lokalen
Pack. Insgesamt52Runtime-PNGs im Manifest, Quellenhashes geprüft.

Neue separat gespeicherte woodland_village.tscn: sechs Dorfgebäude plus
Start-Hütte und südliche Holzfällerhütte; verbundene64px-Wege, Grasinsel,
Birken/Nadelbäume/Büsche/Felsen. Welt von40×28 auf56×40Tiles (3584×2560)
verdoppelt. Grundflächen blockieren Bewegung/Schläge/Pfeile/Navigation, Dächer
nicht. Base-forest.tscn bytegleich zu Beginn: SHA256
5c02086d483bc7cb8a757187b6e6a0866a3e1350e09b06a55798a9765e09baa5.
Nicht im Grafikcommit enthalten. Temporäre Dorf-/Koboldinstanzen bleiben beim
Packen aus der ursprünglichen Editor-Szene heraus; eigene Dorfdatei editierbar.

Checks: check_project.py PASS (52PNGs plus Quellhashes), Python py_compile PASS,
Godot headless import PASS. Combat, Companions, HUD/enemy, Creatures und
Duo/projectile/village/editor: alle PASS mit0Fehlern. Nach letzter Grafik-/HUD-
Bereinigung Duo/HUD/Creatures gezielt wiederholt, ebenfalls PASS. Reale Schwert-
Ausholzeit,28Schaden genau einmal, Nahkampfreichweite, Wandblockade, keine Panda-
Pfeile/Beschwörung, Klassenwechsel-Cleanup, Dorf-/Südpfade, Hausgrundfläche und
Speichern/Laden manueller Editoränderungen im echten Godot geprüft. Dorfszene
mit headless editor geöffnet, keine Scriptfehler. Git diff --check PASS.

Vorgeschriebene Checks im Nachbarprojekt: art:style:check PASS; npm test134/134
PASS; build PASS (bekannte Chunkgrößenwarnung); art:references PASS.
Kein design-worlds --force und keine manuell bearbeiteten TMX-Dateien ersetzt.

Visuell geprüft: actual artifacts/class-selection.png zeigt genau zwei Figuren;
artifacts/duo/panda-village.png, panda-sword-gameplay.png, panda-walk-gameplay.png,
monkey-cottage.png, monkey-walk-gameplay.png, southern-woodland.png aus echtem
Godot bei nativem Pixelmaß. Chrome-Animationsgalerie neben nativer
artifacts/art-direction/style-reference.html geprüft. Kleine isolierte
Quellbogenreste an einzelnen Panda-Frames gefunden und vor Abschluss entfernt;
nochmals tatsächliche Spielaufnahmen kontrolliert. Größen, Füße, Umrisse,
Schwert-/Laufbewegungen und Dachüberdeckung passend. Keine behauptete perfekte
Stilparität: eigene generierte Figuren haben mehr kleine Farbgruppen als native
Originalfiguren. Echte Front-/Rückensequenzen, seitliche Spiegelung statt vier
vollständiger Richtungen. Affen-Frontbeschwörung nutzt eine gehaltene Stabpose,
um ungewollte Rückenwechsel der Quelle auszuschließen. Ähnlichkeit zu den Fotos
bleibt stilisiert; keine Porträtgenauigkeit bei70px Figurenhöhe. Gebäude noch
ohne Innenräume, Inventar-/Waffenwechsel oder NPC-Dialoge.

## Referenz-Wald und Bild-HUD (aktiver Stand)

Vorabbrief REFERENCE_GROVE_BRIEF.md: ausdrücklicher neuer Nutzerbildwunsch ersetzt
Tiny-Swords-Prototyplandschaft/HUD, in AGENTS und ART_DIRECTION dokumentiert.
Komplette aktive56×40-Szene reference_grove.tscn; alte manuelle forest.tscn und
vorherige woodland_village.tscn nicht überschrieben. Ganze neue eigene Landschaft:
Laubwald, fünf Holz-/Strohhäuser, verzweigte Erdwege, Blumen/Büsche/Zäune/Truhen,
Fluss mit kontinuierlichen Felsufern, Schaumkante, Wasserfallstufe und echter
begehbarer Brücke. Eigene Originalquellen und vollständige Prompts in
art/generated-source/reference-grove; Generator built-in image_gen.imagegen.
Terrain-v1 war visuell zu unruhig, v2 ersetzt den produktiven Boden.

Änderungen: neue Grafikquellen/Registry/Compiler, neues Karten-Erstellungswerkzeug
(niemals automatisch aufgerufen), gespeicherte aktive Karte, Wasser-Shader,
HUD-Baustein, Heilaktion, Setup/Quellchecks, Start-/Editor-Launcher und angepasste
Szenen-/HUD-Tests. HUD: echtes Affe-/Pandaporträt, LP/MP-Werte, Angriff/Heilen/
Skelett/Item. H heilt bis35LP für20MP, keine Überheilung oder Wiederbelebung,
keine Kosten bei voller Gesundheit/zu wenig Mana. Skelett beim Panda und Item
bewusst deaktiviert. Keine vorgetäuschte Inventarimplementierung.

Checks: check_project.py und py_compile PASS, Quellen-SHA256/Abmessungen,
66Registry-PNGs und4HUD-Icons geprüft. Godot-Import und echte Editoröffnung
reference_grove ohne Scriptfehler. Combat, Companions, HUD/enemy,
Duo/projectile/village/editor, Creatures und Reference grove/bridge/healing:
alle PASS mit0Fehlern. Nach Ufer-/HUD-Nachbesserung Grove/HUD/Duo nochmals PASS.
Tatsächliche Brückenüberquerung, physische Wassersperre, A*-Flussquerung,
H-Eingabe, Mana-/Heilgrenzen, Wandblockaden, Archetypen und Editor-Roundtrip
getestet. Npm style:check,134Tests, build und art:references im Nachbarprojekt
zusätzlich PASS; bekannte reine Build-Chunkgrößenwarnung.

Visuell: artifacts/clearing.png und artifacts/grove/reference-world-hud.png,
bridge.png und waterfall.png aus echtem Godot bei nativem Pixelzoom angesehen.
Galerie grove/review.html neben nativer art-direction/style-reference.html
überprüft. Der erste Boden war zu kleinteilig, Ufer wirkten zunächst freistehend,
Wasserfall schwebend: Boden vereinfacht, Felskante verbunden, Wasserfall an Stufe
angeschlossen und Schaumband verschmälert. LP/MP-Balken und Porträt korrigiert.

Verbleibende Unterschiede zur Bildvorlage: die Karte ist noch deutlicher an einem
64px-Raster orientiert; Bäume und Ufermodule wiederholen sich häufiger, und der
Wasserfall ist eine statische Grafik (Fluss ist animiert). Keine frei begehbaren
vertikalen Höhenebenen. Eigene Affe/Panda-/Goblinanimationen statt Referenzheld/
Slime. Gegenstände/Truhen besitzen noch keine Loot-/Inventarinteraktion, Häuser
keine Innenräume. Keine Behauptung einer pixelidentischen Kopie oder gleicher
handgezeichneter Vielfalt allein aufgrund grüner Tests.

## Kleineres HUD und schwarze Erkundungs-Minimap

Vorabbrief MINIMAP_BRIEF.md, bestehende Portrait-/Symbol-/Weltbitmapreferenzen
unverändert wiederverwendet. HUD312×126 mit44px-Aktionsfeldern statt446×170,
Minimap180×146 rechts oben. Neue Dateien scripts/minimap.gd und exploration.gd;
adventure_hud.gd/clearing.gd/session.gd integrieren Darstellung und gemeinsame
Erkundung. Keine Karte oder Grafikquelle verändert. Alte manuell bearbeitete
forest.tscn bleibt weiterhin außerhalb des Commits; SHA256 unverändert
5c02086d483bc7cb8a757187b6e6a0866a3e1350e09b06a55798a9765e09baa5.

Die Gebietsgrafik stammt aus tatsächlichen TileMapAtlas-Texturen und Scenery-
Frames/Ankern, keine erfundene abstrakte Karte. Unbekannte Zellen einschließlich
Häusern/Brücke schwarz;6Zellen Kreisradius um den Spieler werden beim Gehen
aufgedeckt und bleiben gespeichert. Spielerpunkt folgt der globalen Position.
Erkundung über Session/F5/Heldenwechsel und Disk-Reload erhalten. Typprüfung
numerischer JSON-Dimensionen nach einem vom Test gefundenen Ladefehler korrigiert.
Keine Gegner-/Schatzmarker und keine echte Sichtlinien-Simulation. Map-Snapshot
wird nach Editoränderungen beim nächsten Levelstart neu aus der Szene aufgebaut.

Testisolation in test_support.gd und bestehenden Szenen-/Aufnahmeskripten schützt
den echten lokalen Nutzerstand. Eigenes minimap_smoke.gd prüft reale Bewegung,
schwarze unbekannte Pixel, tatsächlich aufgedeckte Bildpixel, wachsende Erkundung,
Spielerpunkt, frisches Laden von Disk, Heldenwechsel, Randbegrenzung, kaputte
Datei, Auflösung/Anker/Overlay-Abstände und Klickschutz gegen Weltangriffe.
Capture_minimap.gd erzeugt echte Aufnahmen mit isolierten Speicherständen.

PASS: check_project.py(66Registry-PNGs plus4HUD-Icons und Quellhashes), Godot-
Import ohne Scriptfehler; Minimap, HUD/enemy, Duo/projectile/village/editor,
Combat, Companions, Creatures und Grove/bridge/healing: alle7Gruppen0Fehler.
Zusätzlich art:style:check, npm test134/134, build und art:references PASS im
Nachbarprojekt; bekannte nicht blockierende Chunkgrößenwarnung beim Build.

Visuell bei1:1Pixelzoom geprüft: fresh-area.png, explored-route.png und
panda-shared-map.png in artifacts/minimap, neben unveränderten Grafikreferenzen.
Kleine Symbole und LP/MP lesbar, HUD unten links, Karte oben rechts, keine
Überlappung bei960×640/1280×720/640×480. Frische Erkundung schwarz außerhalb des
Startkreises, später zusammenhängend entdeckter Pfad über den Fluss. Grenzen:
kleine Kartendetails sind bewusst stark reduziert; Fog speichert Gebietsbesuch,
keine aktuellen Sichtlinien oder dynamische Gegnerzustände. Regelmäßiges Speichern
alle5Sekunden plus bei normalem Szenenwechsel/Beenden.


## 2026-10-20 · Größere Welt, Sichtweite und permanente Heldenlevel

- Brief vor Umsetzung: EXPANSION_LEVELS_BRIEF.md. Bestehende grove-tree/house/
  bridge/path/river-Module und Duo-/Koboldsprites wiederverwendet. Historische
  native Master in nobby_world/artifacts/art-direction/style-reference.html
  im Browser geöffnet, zusätzlich tatsächliche grove-tree/house-Produktions-PNGs
  neben den folgenden nativen Godot-Screenshots angesehen.
- Neu: scenes/levels/expanded_grove.tscn, tools/extend_grove.gd,
  scripts/progression.gd, tests/levels_expansion_smoke.gd, tests/capture_levels.gd.
  Angepasst: Viewport, Weltloader, Player-/Enemy-/Fighter-Levelwerte, Session,
  Encounter-Marker, HUD, Minimap/Fog-Migration, Tests, Editor.command und Anleitung.
- 56×80Zellen/3584×5120Pixel, doppelte Fläche durch südliche Erweiterung;
  28statt6Gegner, neue Stufen2–3, neun Häuser gesamt und zwei Flussquerungen.
  Viewport1152×800, Kamera1:1, Nearest. Kein neuer Sprite/kein modifiziertes PNG.
- Echte Spielansichten artifacts/levels/larger-view.png,
  south-bridge-level2.png und panda-southern-village.png bei nativen1152×800
  Pixeln visuell geprüft: größeres Sichtfeld, scharfes bestehendes Material,
  kleine Overlays, EP-Füllung und Leveltexte, korrekt schwarze unbekannte Karte.
  whole-map-overview.png ist gesonderte Kameraübersicht zur Geografieprüfung;
  ihr verkleinerter Zoom gilt ausschließlich für das Aufnahme-Skript.
- Acht Godot-Gruppen: combat, companions, hud_enemy, classes_editor, creatures,
  grove, minimap und levels_expansion bestanden mit jeweils0Fehlern.
  Neues Level-/Erweiterungsszenario prüft alle28Gegner auf freie/erreichbare
  Spawnpunkte, sichere Startentfernung, tatsächliches Gehen über die neue Brücke,
  gesperrtes Wasser, alte Fog-Übernahme, Skelettkill-EP, Duplikatschutz,
  Levelgrenzen/mehrere Aufstiege, echte stärkere Pfeiltreffer, angepasste HUD-
  Maxima, getrennte Klassenfortschritte und tatsächlichen Speicherrückimport.
  Tests verwenden eigene temporäre Dateien; reale Spielstände bleiben unberührt.
- python3 tools/check_project.py:66lokale Runtime-PNGs verifiziert. Godot-Import
  ohne Skriptfehler. npm run art:style:check, npm test (134/134), npm run build,
  npm run art:references bestanden im benachbarten Altprojekt. Build zeigt den
  bestehenden Hinweis auf große JS-Chunks. Der erste npm-Testversuch wurde
  durch Sandbox-Loopback-Verbot gestoppt, der genehmigte Wiederholungslauf bestand.
- Unveränderte Originalkarten: forest.tscn SHA256
  5c02086d483bc7cb8a757187b6e6a0866a3e1350e09b06a55798a9765e09baa5;
  reference_grove.tscn 0031038ebf0a26e4099525259ba4944ca6ed354b826f65c3524d53d5e74cc975;
  woodland_village.tscn 09ccb693eb623f4aa6a897e841bf806842dbe66a5d8517376d9f668da847cfb0.
  Die vorbestehende lokale Änderung in forest.tscn wird nicht committed.
- Grenzen: statische Gegnerplatzierung; F5 erneuert Gegner bei erhaltenen EP.
  Permanente Daten sind Klassen-EP und Erkundung, keine Positions-/Inventarsaves.
  Die frühere Referenzwald-Stilabweichung ist unverändert dokumentiert, keine
  behauptete pixelgenaue Parität zur Nutzerillustration oder Tiny-Swords-Mastern.
