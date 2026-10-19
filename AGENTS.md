# Nobby Mana

Eigenständiger Godot-/GDScript-Neustart. Das benachbarte nobby_world niemals
zurücksetzen, umschreiben oder dessen manuell bearbeitete TMX-Karten generieren.

- Vor Grafikarbeit docs/ART_DIRECTION.md und art/registry.json lesen.
- Aktuell Tiny Swords als durchgängige Prototypgrafik verwenden; vorhandene
  geprüfte Sprites wiederverwenden. Keine Secret-of-Mana-Assets kopieren.
- Native 64px-Terrainzellen, native Spritegrößen, feste Füße/Hitboxen,
  Nearest-Filter, ganzzahlige Skalierung und keine Glättung.
- Lizenzierte PNGs ausschließlich unter assets/licensed, niemals mit Git
  veröffentlichen. Herkunft und Prüfsummen bleiben im Manifest.
- Keine Canvas-/Vektor-Platzhalter als endgültige Spielgrafiken.
- Nach Codeänderungen python3 tools/check_project.py und Godot-Import ausführen.
  Bei Gameplayänderungen tests/combat_smoke.gd ausführen. Bei visuellen Änderungen
  tatsächlichen Godot-Screenshot aufnehmen und neben den Quellreferenzen ansehen.
- Spielcode verständlich und klein halten. Physik in _physics_process,
  Kampfwerte zentral in scripts/fighter.gd. Keine pro-Frame-Dateizugriffe.
- Keine Multiplayer-, Inventar- oder Editor-Vollimplementierung ohne Auftrag.
