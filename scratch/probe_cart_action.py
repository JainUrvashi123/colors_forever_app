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

def post(endpoint, data):
    print(f"=== POST {endpoint} with data {data} ===")
    encoded_data = urllib.parse.urlencode(data).encode('utf-8')
    req = urllib.request.Request(endpoint, data=encoded_data, headers=headers)
    try:
        with opener.open(req) as response:
            body = response.read().decode('utf-8')
            print(f"Status: {response.status}")
            print(f"Cookies: {[c.name + '=' + c.value for c in cookie_jar]}")
            print(f"Body: {body}\n")
            return body
    except Exception as e:
        print(f"Error: {e}\n")

url = 'https://colorsforever.com/api/melle_get_attribute'

# Test combinations of attrType='cart' with action parameters
post(url, {
    'attrType': 'cart',
    'color': 'Blue',
    'color_ch': 'Aqua Blue I',
    'size': '0.9 MM',
    'grade': 'VVS1-VS2',
    'quantity': '5',
    'stone_type': 'mellee',
    'is_added': '1',
    'spl_req': 'test request'
})

post(url, {
    'attrType': 'cart',
    'color': 'Blue',
    'color_ch': 'Aqua Blue I',
    'size': '0.9 MM',
    'grade': 'VVS1-VS2',
    'quantity': '5',
    'stone_type': 'mellee',
    'check_id': '1',
    'action': 'add'
})

post(url, {
    'attrType': 'cart',
    'color': 'Blue',
    'color_ch': 'Aqua Blue I',
    'size': '0.9 MM',
    'grade': 'VVS1-VS2',
    'quantity': '5',
    'stone_type': 'mellee',
    'item_action': 'add_cart'
})
