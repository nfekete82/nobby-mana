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
