#!/usr/bin/env python3
"""Copy only the existing game's used, licensed PNGs without modifying pixels."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=ROOT.parent / 'nobby_world')
    args = parser.parse_args()
    registry = json.loads((ROOT / 'art/registry.json').read_text())
    entries = list(registry['terrain'].values())
    for asset in registry['assets'].values():
        for animation in asset['animations'].values():
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
    print(f'{len(entries)} licensed PNGs installed locally; none are tracked by Git.')

if __name__ == '__main__':
    main()
