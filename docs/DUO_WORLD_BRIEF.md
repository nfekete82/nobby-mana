# Persönliches Heldenduo und Waldorf – vorab festgelegt

Nur zwei spielbare Klassen: monkey und panda. Magier/menschlicher Schamane aus
Auswahl und Spielsteuerung entfernen; alte lizenzierte Eingaben bleiben historische
lokale Referenzen. Affe behält Pfeile/Skelette, bekommt vollen dunklen Bart mit
wenigen grauen Akzenten und braunen hohen Dutt nach dem Nutzerfoto. Panda ist
Nahkämpfer mit Start-Holzschwert, schwarzer rechteckiger Brille, seitlich fallendem
blondem Haar und korallfarbener Tunika nach dem zweiten Nutzerfoto. Tieranatomie
und einheitliche Ganzkörpergestaltung beibehalten, keine Kopfmontage. Die privaten
Fotos werden nicht im öffentlichen Repository abgelegt.

Stilmaster: native Tiny Swords Red Warrior Idle/Run (Actor), Blue Monk Run;
Gameplayvergleich: aktuelle vollständige monkey-shaman/Goblin-Figuren. Bestehende
ART_STYLE.md, style-references.json, TINY_SWORDS_ART_DIRECTION.md sowie Biome-
und Aggro-Dokumente gelesen. Klare große Cluster, Schieferkontur, Licht oben links,
3–4 Farbstufen je Material, feste Füße und Nearest. Panda warmes Creme/Schiefer,
blondes Ocker/Creme, Coral/Rost, Holzbraun. Affe Fellbraun/Creme, Bart dunkelbraun/
Schiefer, Petrol/Blattgrün. Ganze Bögen neu bzw. im vorhandenen Stil überarbeiten.

Beide192×192-Zellen, Fuß96,132, Hitbox32×24, sichtbare Ruhehöhe etwa70px. Atlas6×8:
Affe pro Richtung Stand2+Treffer2+Tod2, Lauf6, Wurf6, Beschwörung6; FPS2/10/4,
12/15/5. Panda pro Richtung Stand4+Treffer2, Lauf6, Schwertschlag6, Tod6;
FPS3/10/12/15/12. Zwei echte Richtungsreihen, seitliche Spiegelung.

Welt: von40×28 auf56×40 native64px-Tiles (3584×2560) erweitern, ca.doppelte Fläche.
Bestehende handbearbeitete forest.tscn bytegleich erhalten. Separat gespeicherte
Godot-Erweiterung mit editierbaren TileMapLayers und Props. Ein nativer Wanderweg
verbindet bestehende östliche Lichtung mit einem kleinen Dorf; ein zweiter Weg
führt um das südliche Waldstück. Bestehende Grenzen nicht durch eine unpassierbare
Baumwand abschließen; offene Durchgänge zwischen den bisherigen Bäumen nutzen.
Neue native Häuser1/2, Monastery als Dorfhalle, Felsen und Baum2 aus bereits
lizenzierten lokalen Packdateien. Keine externen Packdownloads oder Raster-
Illustrationen. Registry übernimmt native Abmessungen/Fußpunkte und konservative
Grundflächen. Keine begehbaren Innenräume versprechen. Bewusste abwechslungsreiche
Baumgruppen, Felsgruppen, Buschbeete, große freie Dorfplätze statt Zufallsstreuung.

Nachher tatsächliche Menü-/Dorf-/Kampfaufnahmen neben nativen Referenzen prüfen,
Python-Struktur/Quellhashes, Godot-Import, Kampf/Begleiter/HUD/Duo/Editor/Navigation
und vorgeschriebene npm-Checks ausführen. Keine Stilparität allein aus Tests ableiten.
