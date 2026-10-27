import urllib.request
import urllib.parse
import http.cookiejar
import json

cookie_jar = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookie_jar))

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
    'X-Requested-With': 'XMLHttpRequest',
}

# GET melle_index
print("=== GET https://colorsforever.com/api/melle_index ===")
req = urllib.request.Request('https://colorsforever.com/api/melle_index', headers=headers)
try:
    with opener.open(req) as res:
        print("Status:", res.status)
        print("Body:", res.read().decode('utf-8')[:600])
except Exception as e:
    print("Error:", e)

# POST melle_get_attribute with attrType='cart' to add item
print("\n=== POST melle_get_attribute attrType=cart ===")
data = urllib.parse.urlencode({
    'attrType': 'cart',
    'color': 'Blue',
    'color_ch': 'Aqua Blue I',
    'size': '0.9 MM',
    'grade': 'VVS1-VS2',
    'quantity': '5',
    'stone_type': 'mellee',
    'spl_req': ''
}).encode('utf-8')
req = urllib.request.Request('https://colorsforever.com/api/melle_get_attribute', data=data, headers=headers)
try:
    with opener.open(req) as res:
        print("Status:", res.status)
        print("Body:", res.read().decode('utf-8'))
except Exception as e:
    print("Error:", e)

# GET melle_index again to see if cart_list now contains the item in session!
print("\n=== GET https://colorsforever.com/api/melle_index (After adding) ===")
req = urllib.request.Request('https://colorsforever.com/api/melle_index', headers=headers)
try:
    with opener.open(req) as res:
        print("Status:", res.status)
        print("Body:", res.read().decode('utf-8')[:600])
except Exception as e:
    print("Error:", e)
