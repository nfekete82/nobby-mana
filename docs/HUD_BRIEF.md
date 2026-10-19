# Kompaktes Ressourcen-HUD und Gegnerleben

Vor Umsetzung festgelegt: funktionale native Godot-UI, 320×84px-Dock,
10px Abstand zum unteren Bildschirmrand, horizontal zentriert; zwei 64×64px-
Ressourcenanzeigen, je ein Zustand mit kontinuierlichem Füllwert, keine
Spriteframes oder veränderten Actor-Füße. Leben rot links, Mana blau rechts,
Beschwörung und Begleiterstand dazwischen. Diablo dient nur als Anordnungs-
und Bedienreferenz; keine Diablo-Bilder, Ornamente oder Schriften kopiert.

Stilreferenzen: das bestehende Nobby-Mana-HUD (Schiefer #293544, Ocker #d2ad65,
Creme #eee2c3) und Pixel Frogs bereits vorhandene WoodTable-/RegularPaper-UI
als Materialreferenz. Gameplayvergleich: Nobby und native enemy-warrior-Sprites.
Die UI bleibt code-nativ und benötigt keine neuen Bitmapgrafiken. Ein 64px-
Shader erzeugt die funktionale vertikale Füllanzeige mit harten Pixelkanten,
wenigen flachen Farbstufen und Licht oben links; keine Glättung oder Verläufe.

Gegner erhalten 48×6px-Lebensbalken bei [-24,-101] relativ zum festen Fußpunkt.
Nach Tod verschwindet der Balken sofort, der Gegner verlässt die Zielgruppe
und wird nach 0,3 Sekunden Ausblenden aus der Szene entfernt. Der vorhandene
Krieger besitzt keine Todesanimation; es wird kein fremdes Sheet ergänzt.
