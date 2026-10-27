import urllib.request
import urllib.parse
import json

url = 'https://colorsforever.com/api/melle_get_attribute'
headers = {
    'User-Agent': 'Mozilla/5.0 (Mobile; ColorsForeverApp)',
    'X-Requested-With': 'XMLHttpRequest',
}

def test_payload(name, payload):
    print(f"=== {name} ===")
    data = urllib.parse.urlencode(payload).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers=headers)
    try:
        with urllib.request.urlopen(req) as res:
            body = res.read().decode('utf-8')
            print("Status:", res.status)
            print("Body:", json.dumps(json.loads(body), indent=2))
            print("\n")
    except Exception as e:
        print("Error:", e, "\n")

test_payload("attrType=cart with item params", {
    'attrType': 'cart',
    'color': 'Blue',
    'color_ch': 'Aqua Blue I',
    'size': '0.9 MM',
    'grade': 'VVS1-VS2',
    'quantity': '5',
    'stone_type': 'mellee',
    'spl_req': ''
})

test_payload("attrType=cart without item params", {
    'attrType': 'cart'
})

test_payload("attrType=get_cart with user_id", {
    'attrType': 'get_cart',
    'user_id': '25'
})

test_payload("attrType=cart with check_id=1", {
    'attrType': 'cart',
    'color': 'Blue',
    'color_ch': 'Aqua Blue I',
    'size': '0.9 MM',
    'grade': 'VVS1-VS2',
    'quantity': '5',
    'check_id': '1',
    'stone_type': 'mellee'
})
