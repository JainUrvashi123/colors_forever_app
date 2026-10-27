import urllib.request
import json

url = 'https://colorsforever.com/api/jewelry_load_more_data'
headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'User-Agent': 'Mozilla/5.0 (Mobile; ColorsForeverApp)'
}

payloads = [
    # 1. Departments & Subcategories
    {'name': '1. Ring + secRing[] Bands', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'secRing[]': ['Bands']}},
    {'name': '2. Pendant + secPendant[] Drop', 'data': {'page': 1, 'per_page': 20, 'dep': ['Pendant'], 'secPendant[]': ['Drop']}},
    {'name': '3. Earring + secEarring[] Hoop', 'data': {'page': 1, 'per_page': 20, 'dep': ['Earring'], 'secEarring[]': ['Hoop']}},
    {'name': '4. Bracelet + secBracelet[] Link', 'data': {'page': 1, 'per_page': 20, 'dep': ['Bracelet'], 'secBracelet[]': ['Link']}},

    # 2. Multi Department
    {'name': '5. Ring + Pendant', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring', 'Pendant']}},

    # 3. Diamond Color
    {'name': '6. Diamond Color BLUE', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'diamond_color': ['BLUE']}},
    {'name': '7. Diamond Color BLUE + YELLOW', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'diamond_color': ['BLUE', 'YELLOW']}},
    {'name': '8. Diamond Color G + H', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'diamond_color': ['G', 'H']}},

    # 4. Metal Color
    {'name': '9. Metal Color White', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'metal_color': ['White']}},
    {'name': '10. Metal Color Rose + Yellow', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'metal_color': ['Rose', 'Yellow']}},
    {'name': '11. Metal Color Multi-Color', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'metal_color': ['Multi-Color']}},

    # 5. Metal Grade
    {'name': '12. Metal Grade 14K', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'metal_grade': ['14K']}},
    {'name': '13. Metal Grade 18K', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'metal_grade': ['18K']}},

    # 6. Style Setting
    {'name': '14. Style Setting Prong', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'style_setting': ['Prong']}},

    # 7. Size
    {'name': '15. Size 6.5', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'size': ['6.5']}},

    # 8. Price & Carat
    {'name': '16. Price 500;5000', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'price': '500;5000'}},
    {'name': '17. Carat 0.5;2.0', 'data': {'page': 1, 'per_page': 20, 'dep': ['Ring'], 'carat': '0.5;2.0'}},

    # 9. All Filters Combined
    {'name': '18. Combined Filters', 'data': {
        'page': 1,
        'per_page': 20,
        'dep': ['Ring'],
        'secRing[]': ['Bands'],
        'diamond_color': ['BLUE', 'YELLOW'],
        'metal_color': ['Multi-Color', 'Rose'],
        'metal_grade': ['18K'],
        'style_setting': ['Prong'],
        'size': ['7'],
        'price': '1;100000',
        'carat': '0.1;20'
    }}
]

print("=== EXECUTING API FILTER TESTS ===")
for p in payloads:
    req = urllib.request.Request(url, data=json.dumps(p['data']).encode('utf-8'), headers=headers)
    try:
        res = urllib.request.urlopen(req)
        body = json.loads(res.read().decode('utf-8'))
        d = body.get('data', {})
        recs = d.get('records', []) if isinstance(d, dict) else []
        tot = d.get('total_records') if isinstance(d, dict) else body.get('total_records')
        tot_pages = d.get('total_pages') if isinstance(d, dict) else body.get('total_pages')
        page = d.get('page') if isinstance(d, dict) else body.get('page')
        print(f"{p['name']}: statusCode=200 | recs_count={len(recs)} | total_records={tot} | total_pages={tot_pages} | page={page}")
    except Exception as e:
        print(f"{p['name']}: Error={e}")
