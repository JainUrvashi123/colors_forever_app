import urllib.request
import json

url = 'https://colorsforever.com/api/solitaire_load_more_data'
headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'User-Agent': 'Mozilla/5.0 (Mobile; ColorsForeverApp)'
}

payloads = [
    {'name': 'carat 1;50', 'data': {
        "stock": "", "report": "", "checkbox": [], "color": [], "color_ch": [], "clarity": [],
        "cert": ["GIA", "IGI"], "carat": "1;50", "price": "1;500000", "search": "",
        "location": "", "sort_by": "price_l", "per_page": 16, "page": 0
    }},
    {'name': 'carat 0;100', 'data': {
        "stock": "", "report": "", "checkbox": [], "color": [], "color_ch": [], "clarity": [],
        "cert": ["GIA", "IGI"], "carat": "0;100", "price": "1;500000", "search": "",
        "location": "", "sort_by": "price_l", "per_page": 16, "page": 0
    }},
    {'name': 'carat 0.1;50', 'data': {
        "stock": "", "report": "", "checkbox": [], "color": [], "color_ch": [], "clarity": [],
        "cert": ["GIA", "IGI"], "carat": "0.1;50", "price": "1;500000", "search": "",
        "location": "", "sort_by": "price_l", "per_page": 16, "page": 0
    }},
    {'name': 'price 1;500000', 'data': {
        "stock": "", "report": "", "checkbox": [], "color": [], "color_ch": [], "clarity": [],
        "cert": ["GIA", "IGI"], "carat": "0.1;50", "price": "1;500000", "search": "",
        "location": "", "sort_by": "price_l", "per_page": 16, "page": 0
    }},
]

for p in payloads:
    req = urllib.request.Request(url, data=json.dumps(p['data']).encode('utf-8'), headers=headers)
    try:
        res = urllib.request.urlopen(req)
        body = json.loads(res.read().decode('utf-8'))
        records = body.get('records', [])
        tot = body.get('total_records')
        print(f"{p['name']}: total_records={tot}, recs_len={len(records)}")
    except Exception as e:
        print(f"{p['name']}: Error={e}")
