import urllib.request
import json

url = 'https://colorsforever.com/api/solitaire_load_more_data'
headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'User-Agent': 'Mozilla/5.0 (Mobile; ColorsForeverApp)'
}

payloads = [
    {'name': 'Default All Certs GIA+IGI', 'data': {
        "stock": "", "report": "", "checkbox": [], "color": [], "color_ch": [], "clarity": [],
        "cert": ["GIA", "IGI"], "carat": "1;50", "price": "1;500000", "search": "",
        "location": "", "sort_by": "price_l", "per_page": 16, "page": 0
    }},
    {'name': 'Shape ROUND', 'data': {
        "stock": "", "report": "", "checkbox": ["ROUND"], "color": [], "color_ch": [], "clarity": [],
        "cert": [], "carat": "0.5;50", "price": "1;500000", "search": "",
        "location": "", "sort_by": "price_l", "per_page": 16, "page": 0
    }},
    {'name': 'Color Blue', 'data': {
        "stock": "", "report": "", "checkbox": [], "color": ["Blue"], "color_ch": [], "clarity": [],
        "cert": [], "carat": "0.1;50", "price": "1;500000", "search": "",
        "location": "", "sort_by": "price_l", "per_page": 16, "page": 0
    }},
    {'name': 'Clarity VS1 + VS2', 'data': {
        "stock": "", "report": "", "checkbox": [], "color": [], "color_ch": [], "clarity": ["VS1", "VS2"],
        "cert": [], "carat": "0.1;50", "price": "1;500000", "search": "",
        "location": "", "sort_by": "price_l", "per_page": 16, "page": 0
    }},
    {'name': 'Page 2 (offset 16)', 'data': {
        "stock": "", "report": "", "checkbox": [], "color": [], "color_ch": [], "clarity": [],
        "cert": ["GIA", "IGI"], "carat": "1;50", "price": "1;500000", "search": "",
        "location": "", "sort_by": "price_l", "per_page": 16, "page": 16
    }},
]

print("=== EXECUTING SOLITAIRE API TESTS ===")
for p in payloads:
    req = urllib.request.Request(url, data=json.dumps(p['data']).encode('utf-8'), headers=headers)
    try:
        res = urllib.request.urlopen(req)
        body = json.loads(res.read().decode('utf-8'))
        records = body.get('records', [])
        tot = body.get('total_records')
        status = body.get('status')
        print(f"{p['name']}: status={status} | recs={len(records)} | total_records={tot}")
        if records:
            print(f"   First rec serial: {records[0].get('SN_SERIALNO')}, shape: {records[0].get('shape_full')}, wt: {records[0].get('QT_WEIGHT')}")
    except Exception as e:
        print(f"{p['name']}: Error={e}")
