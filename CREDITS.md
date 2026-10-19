# Quellen und Rechte

- Engine: [Godot Engine](https://godotengine.org), MIT; separat installiert.
- Prototypgrafiken: **Tiny Swords (Free Pack), Pixel Frog**,
  [offizielle Quelle und Lizenz](https://pixelfrog-assets.itch.io/tiny-swords).
  Eingebunden werden ausschließlich bereits im lokalen Nobby-World-Projekt
  enthaltene Dateien. Die dortige Herkunft steht in `CREDITS.md` und
  `art/pack-manifest.json`. Der Pack ist nicht CC0 und wird in diesem
  öffentlichen Repository nicht als Asset-Sammlung veröffentlicht.
- Nobby-PNGs und die kompilierten Terrainvarianten stammen aus Nobby World.
  Nobby wurde dort mit OpenAI ImageGen anhand der bereitgestellten Referenzen
  gestaltet und deterministisch kompiliert. Native Framegrößen bleiben erhalten.
- Secret of Mana dient nur als Spielgefühl-Referenz. Keine Grafiken, Musik,
  Namen, Karten oder Geschichte daraus werden verwendet.

Für den neuen Spielcode wurde noch keine Open-Source-Lizenz festgelegt.
Die öffentliche Sichtbarkeit erteilt keine weitergehenden Nutzungsrechte.

Die Skelettbegleiter verwenden ebenfalls unveränderte Nobby-World-Expansion-PNGs.
Diese wurden dort mit OpenAI ImageGen anhand der Tiny-Swords-/Gameplayreferenzen
entworfen und deterministisch kompiliert; Quellen/Provenienz verbleiben im alten
Projekt. Auch diese Dateien bleiben lokal und werden nicht mit Git veröffentlicht.

Der spielbare Schamane übernimmt die vorhandenen nativen Monk-Edits aus
Nobby World (brauner Dutt/Bart, petrolfarbenes Gewand, Stab), einschließlich
der vier ursprünglichen Monk-Laufposen. Die Bilddateien bleiben lokal.
Die kleinen Pfeile sind eigene handgesetzte Pixelpläne in der bestehenden
Materialpalette, deterministisch kompiliert aus art/generated-source/arrow.json.
Das angehängte Diablo-Bild dient nur als Layoutreferenz; keine Bildteile
daraus werden im Spiel oder Repository verwendet.

Affen-Schamane und beide Waldkobolde wurden im zweiten Durchgang als vollständige
Figuren neu mit dem eingebauten OpenAI-Imagegen-Werkzeug gezeichnet. Native
Monk-/Warrior-PNGs und der vorhandene Gameplay-Schamane dienten nur als
Stil-/Größenreferenzen. Die neuen Produktionsfiguren enthalten keine montierten
nativen Körper. Originale vollständige Bögen, Prompts, SHA256 und Layout unter
art/generated-source/creatures/fullbody-v2. Ein deterministischer Compiler trennt
die vollständigen Posen, wendet eine gemeinsame Figurenskalierung per Nearest
und eine begrenzte Materialpalette an und packt sie in feste 192px-Zellen.
Produktionsatlanten bleiben lokal in assets/compiled. Neue Figuren sind eigene
Erweiterungen, keine originalen Pixel-Frog-Packdateien. Die früheren Kopf-/
Schweifquellen bleiben ausschließlich als verworfene Produktionshistorie erhalten.

Aktuelles persönliches Heldenduo: vollständig gezeichnete Affe-/Panda-Quellen in
art/generated-source/creatures/duo-v3, erzeugt mit dem eingebauten Imagegen.
Vom Nutzer bereitgestellte Fotos dienten nur der stilisierten Ähnlichkeit;
diese privaten Referenzen werden nicht im Repository gespeichert. Neue eigene
Grafikquellen und vollständige Prompts werden veröffentlicht, keine Fotodateien.

Dorfgebäude (House1, House2, Monastery), zusätzliche Birke(Tree2) und Felsen(Rock1)
sind unveränderte bereits im lokalen Tiny-Swords-Pack enthaltene Dateien. Herkunft
und SHA256 stehen in art/registry.json; PNGs bleiben ausschließlich unter dem
ignorierten assets/licensed. Keine neuen externen Packdateien werden verteilt.
