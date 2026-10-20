# Doppelte Waldfläche und Heldenlevel

Vor Umsetzung: bestehende aktive reference_grove.tscn bleibt vollständig erhalten.
Eine eigene expanded_grove.tscn kopiert den Norden und ergänzt ausschließlich
südliche64px-Zellen:56×80 statt56×40,3584×5120Weltpixel. Keine alten Handkarten
überschreiben. Vorhandene IDs, Fußpunkte, Kollisionen und Module übernehmen.

Referenzen: art/registry.json, REFERENCE_GROVE_BRIEF.md und die tatsächlichen
bestehenden grove-tree/house/bridge/path-Assets. Native Tiny-Swords-Baum/Haus/
Warrior bleiben historische Technikreferenzen gemäß ART_DIRECTION.md; keine
neuen Bildpixel, Paletten oder Animationen. Terrain64px, Baum192×256/Fuß96,234,
Haus256×320/Fuß128,300, Brücke512×256/Fuß256,234; jeweils ein Standframe.
Materialien bleiben Waldgrün, ockerfarbene Wege/Dächer, blaues Wasser, Schiefer.
Figuren192×192/Fuß96,132 bleiben unverändert, Nearest bleibt aktiv.

Viewport1152×800 statt960×640:20%mehr Breite,25%mehr Höhe bei Kamera1:1.
Kein fractional Sprite-Zoom. Kleine Minimap behält180×146Panel; die ganze Karte
wird mit korrektem Seitenverhältnis eingepasst. Bekannte alte Zellen migrieren,
der neue Süden bleibt schwarz. Bestehendes312×126HUD bekommt eine dünne EP-
Leiste und Levelanzeige ohne größere Aktionsfelder.

28statt6Gegner, sichere Startposition, südliche Begegnungen Level2–3.
EP genau einmal je Tod, auch bei Skelettkills. Separate permanente EP für Affe
und Panda; Levelkosten100,+50je nächster Stufe, Grenze50. Levelaufstieg füllt
LP/MP, erhöht klassenabhängig Leben, Mana und Schaden. F5/Tod behalten EP,
Gegner werden wie bisher neu geladen. Kein Inventar-/Skillbaumauftrag.

Prüfung: tatsächlicher Weg in den Süden und über beide Brücken, alle Spawnpunkte
frei/erreichbar, XP-/Speicher-/Mehrfachkill-/Klassenwechseltests, bestehende
Kampf-/HUD-/Minimaptests und echte Spielscreenshots neben Quellreferenzen.
