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
        path = ROOT / ('assets/compiled' if animation.get('compiled') else 'assets/licensed') / animation['file']
        if path.exists():
            data = path.read_bytes()
            assert data[:8] == b'\x89PNG\r\n\x1a\n'
            assert struct.unpack('>II',data[16:24]) == (asset['frame'][0]*animation['frames'],asset['frame'][1]*animation.get('rows',1)), key
            if not animation.get('compiled'):
                assert hashlib.sha256(data).hexdigest() == animation['sha256'], key
            checked += 1
for entry in registry['terrain'].values():
    path = ROOT / 'assets/licensed' / entry['file']
    if path.exists():
        assert hashlib.sha256(path.read_bytes()).hexdigest() == entry['sha256']
        checked += 1
# Own full-body inputs are committed, so validate the rebuild chain in CI too.
source_root = ROOT/'art/generated-source/creatures/fullbody-v2'
layout = json.loads((source_root/'layout.json').read_text())
provenance = json.loads((source_root/'provenance.json').read_text())
for ident, spec in layout['characters'].items():
    source = source_root/f'{ident}.png'
    data = source.read_bytes()
    recorded = provenance['files'][source.name]
    assert hashlib.sha256(data).hexdigest() == recorded['sha256'], source
    width,height = struct.unpack('>II',data[16:24])
    assert [width,height] == recorded['size'] and width % 6 == 0
    assert len(spec['bands']) == 8 and 0 < spec['scale'] <= 1
    previous_end = 0
    for start,end in spec['bands']:
        assert previous_end <= start < end <= height
        previous_end = end
    for state, poses in spec['states'].items():
        assert len(poses) == registry['assets'][ident]['animations'][state]['frames']
        assert all(0 <= row < 4 and 0 <= col < 6 for row,col in poses)
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
