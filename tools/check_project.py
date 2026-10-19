#!/usr/bin/env python3
"""Check tracked resources and optional local art with Python's standard library."""
import hashlib
import json
from pathlib import Path
import struct
import subprocess

ROOT = Path(__file__).resolve().parents[1]
registry = json.loads((ROOT / 'art/registry.json').read_text())
assert registry['tile_size'] == 64
checked = 0
for key, asset in registry['assets'].items():
    assert len(asset['foot']) == 2 and all(n > 0 for n in asset['frame'])
    for state, animation in asset['animations'].items():
        assert animation['frames'] > 0 and animation['fps'] > 0
        assert all(0 <= n < animation['frames'] for n in animation.get('indices', []))
        path = ROOT / 'assets/licensed' / animation['file']
        if path.exists():
            data = path.read_bytes()
            assert data[:8] == b'\x89PNG\r\n\x1a\n'
            assert struct.unpack('>II',data[16:24]) == (asset['frame'][0]*animation['frames'],asset['frame'][1]), key
            assert hashlib.sha256(data).hexdigest() == animation['sha256'], key
            checked += 1
for entry in registry['terrain'].values():
    path = ROOT / 'assets/licensed' / entry['file']
    if path.exists():
        assert hashlib.sha256(path.read_bytes()).hexdigest() == entry['sha256']
        checked += 1
assert (ROOT/'scenes/clearing.tscn').exists()
assert 'TEXTURE_FILTER_NEAREST' in (ROOT/'scripts/art_library.gd').read_text()
assert 'scale_mode="integer"' in (ROOT/'project.godot').read_text()
if (ROOT/'.git').exists():
    tracked = subprocess.check_output(['git','ls-files','assets/licensed'],cwd=ROOT,text=True).splitlines()
    assert tracked in ([], ['assets/licensed/.gitkeep']), 'Licensed PNGs must stay local'
print(f'Project structure PASS; {checked} local PNGs verified (runtime requires 14).')
