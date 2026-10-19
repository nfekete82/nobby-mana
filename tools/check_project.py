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
            assert struct.unpack('>II',data[16:24]) == (asset['frame'][0]*animation['frames'],asset['frame'][1]*animation.get('rows',1)), key
            assert hashlib.sha256(data).hexdigest() == animation['sha256'], key
            checked += 1
for entry in registry['terrain'].values():
    path = ROOT / 'assets/licensed' / entry['file']
    if path.exists():
        assert hashlib.sha256(path.read_bytes()).hexdigest() == entry['sha256']
        checked += 1
recipe = json.loads((ROOT/'art/generated-source/arrow.json').read_text())
assert len(recipe['rows']) == recipe['frame'][1]
assert all(len(row) == recipe['frame'][0] for row in recipe['rows'])
for palette in [recipe['palette'],recipe['arcane_palette']]:
    assert all(color[-2:] in ('00','ff') for color in palette.values())
    assert all(pixel in palette for row in recipe['rows'] for pixel in row)
for name in ['arrow','arcane-arrow']:
    path = ROOT/'assets/compiled'/f'{name}.png'
    if path.exists():
        assert struct.unpack('>II',path.read_bytes()[16:24]) == tuple(recipe['frame'])
assert (ROOT/'scenes/levels/forest.tscn').exists()
assert (ROOT/'scenes/clearing.tscn').exists()
assert 'TEXTURE_FILTER_NEAREST' in (ROOT/'scripts/art_library.gd').read_text()
assert 'scale_mode="integer"' in (ROOT/'project.godot').read_text()
if (ROOT/'.git').exists():
    tracked = subprocess.check_output(['git','ls-files','assets/licensed'],cwd=ROOT,text=True).splitlines()
    assert tracked in ([], ['assets/licensed/.gitkeep']), 'Licensed PNGs must stay local'
    assert not subprocess.check_output(['git','ls-files','assets/compiled'],cwd=ROOT,text=True).strip()
required = sum(len(asset['animations']) for asset in registry['assets'].values()) + len(registry['terrain'])
print(f'Project structure PASS; {checked} local PNGs verified (runtime requires {required}).')
