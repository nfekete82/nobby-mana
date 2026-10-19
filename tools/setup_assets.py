#!/usr/bin/env python3
"""Copy only the existing game's used, licensed PNGs without modifying pixels."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import zlib
import struct
import subprocess

ROOT = Path(__file__).resolve().parents[1]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=ROOT.parent / 'nobby_world')
    parser.add_argument('--godot', type=Path, help='Optional path to Godot executable')
    args = parser.parse_args()
    registry = json.loads((ROOT / 'art/registry.json').read_text())
    entries = [entry for entry in registry['terrain'].values() if not entry.get('compiled')]
    for asset in registry['assets'].values():
        for animation in asset['animations'].values():
            if not animation.get('compiled'):
                entries.append(animation)
    # Validate everything before copying anything.
    for entry in entries:
        source = args.source / entry['source']
        if not source.is_file():
            parser.error(f'Missing licensed input: {source}. See CREDITS.md.')
        data = source.read_bytes()
        if hashlib.sha256(data).hexdigest() != entry['sha256']:
            parser.error(f'Input changed: {source}. Review art before updating the manifest.')
    target = ROOT / 'assets/licensed'
    target.mkdir(parents=True, exist_ok=True)
    for entry in entries:
        shutil.copyfile(args.source / entry['source'], target / entry['file'])
        import_file = target / (entry['file'] + '.import')
        if import_file.exists():
            continue
        import_file.write_text(
            '[remap]\nimporter="texture"\ntype="CompressedTexture2D"\n\n'
            '[params]\ncompress/mode=0\nmipmaps/generate=false\n'
            'process/fix_alpha_border=false\n')
    compile_projectiles()
    engine = args.godot or (ROOT/'.tools/Godot.app/Contents/MacOS/Godot')
    if not engine.is_file():
        found = shutil.which('godot')
        if not found:
            parser.error('Godot is needed to compile creature art; use --godot /path/to/godot')
        engine = Path(found)
    subprocess.run([str(engine),'--headless','--path',str(ROOT),'--script','tools/compile_creatures.gd'],check=True)
    subprocess.run([str(engine),'--headless','--path',str(ROOT),'--script','tools/compile_grove.gd'],check=True)
    print(f'{len(entries)} licensed PNGs installed locally; none are tracked by Git.')

def compile_projectiles():
    recipe = json.loads((ROOT/'art/generated-source/arrow.json').read_text())
    width,height = recipe['frame']
    def chunk(kind,data):
        return struct.pack('>I',len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data)&0xffffffff)
    target = ROOT/'assets/compiled'
    target.mkdir(parents=True,exist_ok=True)
    for name,palette in [('arrow',recipe['palette']),('arcane-arrow',recipe['arcane_palette'])]:
        assert len(recipe['rows']) == height and all(len(row)==width for row in recipe['rows'])
        raw = b''.join(b'\x00'+b''.join(bytes.fromhex(palette[pixel]) for pixel in row) for row in recipe['rows'])
        data = b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',width,height,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(raw))+chunk(b'IEND',b'')
        (target/(name+'.png')).write_bytes(data)

if __name__ == '__main__':
    main()
