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
