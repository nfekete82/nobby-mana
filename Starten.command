#!/bin/zsh
set -eu
cd -- "$(dirname -- "$0")"
if [[ ! -f assets/licensed/hero-stand.png || ! -f assets/licensed/skeleton-death.png || ! -f assets/licensed/shaman-walk.png || ! -f assets/compiled/arrow.png || ! -f assets/compiled/monkey-shaman-walk.png || ! -f assets/compiled/goblin-scout-walk.png ]]; then
  python3 tools/setup_assets.py
fi
if [[ -x .tools/Godot.app/Contents/MacOS/Godot ]]; then
  nobby_engine="$PWD/.tools/Godot.app/Contents/MacOS/Godot"
elif command -v godot >/dev/null 2>&1; then
  nobby_engine="$(command -v godot)"
elif [[ -x /Applications/Godot.app/Contents/MacOS/Godot ]]; then
  nobby_engine=/Applications/Godot.app/Contents/MacOS/Godot
else
  print 'Bitte Godot 4.7.2 installieren oder unter .tools/Godot.app ablegen.'
  read '?Enter zum Schließen'
  exit 1
fi
"$nobby_engine" --headless --editor --path . --import
exec "$nobby_engine"  --path .
