import urllib.request
import json

url = 'https://colorsforever.com/api/solitaire_load_more_data'
headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'User-Agent': 'Mozilla/5.0 (Mobile; ColorsForeverApp)'
}

payload = {
    "stock": "",
    "report": "",
    "checkbox": [],
    "color": [],
    "color_ch": [],
    "clarity": [],
    "cert": ["GIA", "IGI"],
    "carat": "1;50",
    "price": "1;500000",
    "search": "",
    "location": "",
    "sort_by": "price_l",
    "per_page": 16,
    "page": 0
}

req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers=headers)
try:
    res = urllib.request.urlopen(req)
    body = json.loads(res.read().decode('utf-8'))
    print("Status:", body.get("status"))
    print("Total records:", body.get("total_records"))
    records = body.get("records", [])
    print("Records length:", len(records))
    if records:
        print("First record keys:", list(records[0].keys()))
        print("First record shape:", records[0].get("shape_full"))
        print("First record serial:", records[0].get("SN_SERIALNO"))
        print("First record weight:", records[0].get("QT_WEIGHT"))
        print("First record price:", records[0].get("TOTAL_RETAIL_PRICE"))
        print("First record image:", records[0].get("image_show"))
except Exception as e:
    print("Error:", e)
