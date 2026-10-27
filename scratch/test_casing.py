import urllib.request
import json

url = 'https://colorsforever.com/api/jewelry_load_more_data'
headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'User-Agent': 'Mozilla/5.0 (Mobile; ColorsForeverApp)'
}

payloads = [
    {'name': 'metal_color Multi-Color', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'metal_color': ['Multi-Color']}},
    {'name': 'metal_color Multi Color', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'metal_color': ['Multi Color']}},
    {'name': 'metal_color ["Multi-Color", "Multi Color"]', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'metal_color': ['Multi-Color', 'Multi Color']}},
    {'name': 'diamond_color ["Blue"]', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'diamond_color': ['Blue']}},
    {'name': 'diamond_color ["BLUE"]', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'diamond_color': ['BLUE']}},
    {'name': 'diamond_color ["BLUE", "YELLOW"]', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'diamond_color': ['BLUE', 'YELLOW']}},
    {'name': 'diamond_color ["Blue", "Yellow"]', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'diamond_color': ['Blue', 'Yellow']}},
]

for p in payloads:
    req = urllib.request.Request(url, data=json.dumps(p['data']).encode('utf-8'), headers=headers)
    try:
        res = urllib.request.urlopen(req)
        body = json.loads(res.read().decode('utf-8'))
        d = body.get('data', {})
        recs = d.get('records', []) if isinstance(d, dict) else []
        tot = d.get('total_records') if isinstance(d, dict) else body.get('total_records')
        print(f"{p['name']}: total_records={tot}, recs={len(recs)}")
    except Exception as e:
        print(f"{p['name']}: Error={e}")
