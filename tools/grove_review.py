#!/usr/bin/env python3
"""Native-size gallery for the new reference art plus real Godot captures."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
registry=json.loads((ROOT/'art/registry.json').read_text())
out=ROOT/'artifacts/grove';out.mkdir(parents=True,exist_ok=True)
cards=[]
for ident in ['grove-tree','grove-house','grove-cliff','grove-bridge','grove-waterfall','grove-flowers','grove-fence','grove-chest','grove-bush','grove-foam','tree-oak','house','enemy-warrior','monkey-shaman','panda']:
    asset=registry['assets'][ident];anim=asset['animations']['stand'];w,h=asset['frame']
    folder='compiled' if anim.get('compiled') else 'licensed'
    cards.append(f'<article><strong>{ident}</strong><div style="width:{w}px;height:{h}px;background-image:url(../../assets/{folder}/{anim["file"]})"></div><small>{w}×{h} · Fuß {asset["foot"]}</small></article>')
html='''<!doctype html><meta charset="utf-8"><title>Referenz-Wald · native Grafikprüfung</title><style>body{background:#18352d;color:#f2ead1;font:14px system-ui;margin:24px}main{display:flex;gap:20px;flex-wrap:wrap}article{padding:12px;border:1px solid #a7915c;background:#325a40}article div{image-rendering:pixelated;background-repeat:no-repeat}img{image-rendering:pixelated;max-width:none}small{display:block}a{color:#b7dbb3}</style><h1>Neue aktive Art Direction und historische Größenreferenzen</h1><p>100% Pixelzoom; echte Spielaufnahmen darunter. Keine Gleichsetzung automatischer Checks mit Stilqualität.</p><main>'''+''.join(cards)+'</main><h2>Tatsächliche Godot-Aufnahmen</h2>'
for name in ['reference-world-hud','bridge','waterfall']:
    html+=f'<p>{name}</p><img src="{name}.png" alt="Echte Spielscreenshot {name}">'
(out/'review.html').write_text(html)
print(out/'review.html')
