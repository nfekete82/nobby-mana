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
