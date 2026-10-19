#!/usr/bin/env python3
"""Native-size, animated reference gallery; uses existing local PNGs only."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
registry=json.loads((ROOT/'art/registry.json').read_text())
out=ROOT/'artifacts/creatures';out.mkdir(parents=True,exist_ok=True)
cards=[]
styles=[]
for ident in ['monkey-shaman','panda','enemy-warrior','goblin-scout','goblin-brute']:
    asset=registry['assets'][ident]
    for state in ['stand','walk','attack','heal','hit','death']:
        if state not in asset['animations']:continue
        anim=asset['animations'][state]
        folder='compiled' if anim.get('compiled') else 'licensed'
        total=anim['frames'];duration=total/anim['fps']
        for row in range(anim.get('rows',1)):
            key=f'{ident}-{state}-{row}'
            styles.append(f'@keyframes {key}'+'{from{background-position:0px '+str(-row*192)+'px}to{background-position:'+str(-total*192)+'px '+str(-row*192)+'px}}')
            cards.append(f'<article><strong>{ident} · {state} · {"Rücken" if row else "Vorne"}</strong><div class="sprite" style="background-image:url(../../assets/{folder}/{anim["file"]});animation:{key} {duration}s steps({total}) infinite"></div><small>{total} Frames · {anim["fps"]} FPS · Fuß 96,132</small></article>')
html='''<!doctype html><html lang="de"><meta charset="utf-8"><title>Kreaturen – native Animationen</title><style>body{margin:24px;background:#16242d;color:#eee2c3;font:14px system-ui}main{display:flex;flex-wrap:wrap;gap:16px}article{padding:14px;background:#243541;width:240px}strong{font-size:12px}.sprite{width:192px;height:192px;background-repeat:no-repeat;background-color:#8ba86e;image-rendering:pixelated;margin:10px 0;outline:1px solid #d2ad65}small{color:#b8c5c9}'''+''.join(styles)+'''</style><h1>Native Figuren und neue Kreaturen</h1><p>100% Pixelzoom: native Vorlage und vollständig neu gezeichnete Figuren. Hier lassen sich Reihen und Zustandswechsel einzeln vergleichen.</p><main>'''+''.join(cards)+'</main></html>'
(out/'review.html').write_text(html)
print(out/'review.html')
