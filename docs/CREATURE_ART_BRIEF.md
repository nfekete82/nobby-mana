# Affen-Schamane und Waldkobolde – Produktionsbrief

Vor Produktion festgelegt: bestehende native Tiny-Swords-Actor-Sprache bleibt
Master. Gleiche Perspektive, dunkle Schieferkonturen, Licht oben links, wenige
flache Materialfarben, native Pixelcluster. Terrain bleibt 64px. Alle Runtime-
Actor-Zellen 192×192, Fuß [96,132], Hitbox 32×24; keine Tiled-Skalierung.

Affen-Schamane: neue Affenidentität (braunes Fell, helle Schnauze, runde Ohren,
Schweif), vorhandener petrolfarbener Schamanenumhang und Holzstab. Primäre
Same-Category-Referenz: native Blue Monk Idle/Run/Heal. Gameplayvergleich:
bestehender shaman sowie enemy-warrior. Native Roben-/Fuß-/Armbewegungen
werden bevorzugt übernommen; neue Kopf-/Schweifteile bilden die Identität.
Stand 2 ruhige Posen/0,5 FPS, Lauf 4 native Posen/12 FPS, Angriff 6/16 FPS,
Beschwörung 11/9 FPS, jeweils Vorder-/Rückenreihe. Treffer und Tod behalten
eigene Zustände. Keine künstlichen zusätzlichen Laufbilder oder Beine.

Kleine Waldkobolde: geduckte, grüne Wesen mit großen spitzen Ohren, dunklem
Leder/Blätterkleidung und kleinen Waffen. Master-Ausrüstung, Proportionen und
Animation: native Red/Black Warrior Idle/Run/Attack. Gameplayvergleich: vorhandene
Krieger und Schamane. Zwei Varianten: Waldkobold-Späher und Waldkobold-Raufbold,
mit unterscheidbarer Ausrüstung/Farbakzenten und echtem Gameplayeinsatz.
Stand 4/4 FPS, Lauf 6/12 FPS, Angriff 4/12 FPS, Treffer 2/10 FPS, Tod 4/8 FPS,
Vorder-/Rückenansichten. Sichtbare Körperhöhe ungefähr 55–65px, keine gestreckten
oder weich verkleinerten Figuren. Quellen und Kompilate getrennt halten.

Neue Bitmapquellen entstehen mit dem eingebauten Imagegen-Werkzeug anhand
der tatsächlich beigefügten nativen Referenzen. Danach deterministisches
Trennen, Paletten-/Alpha-Normalisierung und feste Frameanker. Tatsächliche
Bewegungsschleifen und Gameplay bei nativer Pixelgröße ansehen; weder Bilder
noch strukturelle Tests allein beweisen perfekte Animation oder Stilparität.
