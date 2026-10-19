# Neue Art Direction nach Bildreferenz – vor Produktion

Der Nutzer wünscht ausdrücklich komplette Grafik, Kartenaufbau und HUD nach dem
angehängten Referenzbild. Dies ersetzt für die aktive Godot-Welt den bisherigen
Tiny-Swords-Prototypstil. Historische native Stilvorgaben bleiben für archivierte
Assets gültig; die Umstellung erfolgt als zusammengehörige neue Landschaft und
HUD, nicht als einzelne eingeklebte Illustrationen. Kein Anspruch auf exakte
Reproduktion der Bildvorlage. Affe/Panda behalten persönliche Identität, ganze
Animationen und Fähigkeiten. Spielkarte vollständig56×40,64px-Zellen. Bestehende
handbearbeitete forest.tscn und woodland_village.tscn bleiben archiviert/editierbar.
Die aktive neue Karte ist eine eigene gespeicherte Godot-Szene.

Ziel: sattgrüner dichter Wald, verzweigte schmale Erdwege, gelb gedecktes Holzhaus,
Felsufer, Fluss mit Wasserfall und tatsächlich begehbarer Brücke, kleine Blumen,
Kisten und Zäune. Mehr Tiefenstaffelung durch echte Vordergrund-Überdeckung.
Große klare Pixelgruppen, dunkle blaugrüne Schatten, goldene warme Akzente,
Licht oben links, pixelharte Konturen und Nearest. Keine weich skalierte Collage.
Referenz ist das Nutzerbild; vergleichbare native Actor-/Gebäudereferenzen bleiben
Red Warrior, House1/2 und Tree1. Bestehende Duo-Sprites als Gameplayvergleich.

Neue Quelle: neun freigestellte Landschaftsmodule auf3×3Raster: Eiche192×256,
Haus256×320, Felsufer128×192, Brücke448×192, Wasserfall128×320, Blumen64×64,
Zaun128×96, Truhe64×64, Busch128×128. Füße/Hitboxen in Registry; vollständige
Silhouetten, keine per-Pose-Skalierung. Originale Bitmapquellen getrennt von
kompilierten Produktions-PNGs; passende IDs können neue eigene Grafik verwenden,
Originaldateien bleiben unverändert. Zusätzlich eigene64×64-Gras/Erde/Wasser-
Texturen, deterministische Pixel-Übergänge und animierte Wasser-UVs.

HUD unten links ca.460×166: echtes Heldenporträt, rote LP-/blaue MP-Balken mit
aktuellen Zahlen, vier Aktionsplätze Angriff/Heilen/Skelett/Item mit Tasten.
Neue Pixel-Symbolquelle: Schwert, grünes Heilkreuz, Schädel, Beutel. Native
Godot-Controls für lesbaren Text und Rahmen, Bitmapillustrationen für Symbole.
Heilen H:20Mana für35LP, nur wenn verletzt/lebendig/genugMana, niemals Überheilung;
Panda besitzt dafür Mana, sonst reiner Schwertkämpfer. Skelette nur Affe;
Item sichtbar deaktiviert bis es ein Inventar gibt. Keine implizite Inventar-
Vollimplementierung. Keine Schaden-/Navigationslogik durch Dekoration ersetzen.

Nachher: gesamte aktive Karte, Wasser-/Brückenblockaden, Schwert-/Pfeil-/Heil-
/Skelett-/HUD-/Editorfunktionen testen, tatsächliche Screenshots bei1:1Pixelzoom
neben neuer und historischen Referenzen ansehen. Npm-Stil-/Test-/Build-/Referenz-
Checks zusätzlich; neue Stilabweichung transparent berichten.
