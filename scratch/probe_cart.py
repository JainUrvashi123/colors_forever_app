import urllib.request
import urllib.parse
import http.cookiejar
import json

cookie_jar = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookie_jar))

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'X-Requested-With': 'XMLHttpRequest',
}

def post(endpoint, data):
    print(f"=== POST {endpoint} ===")
    print("Data:", data)
    encoded_data = urllib.parse.urlencode(data).encode('utf-8')
    req = urllib.request.Request(endpoint, data=encoded_data, headers=headers)
    try:
        with opener.open(req) as response:
            body = response.read().decode('utf-8')
            print(f"Status: {response.status}")
            print(f"Cookies: {[c.name + '=' + c.value for c in cookie_jar]}")
            print(f"Body: {body}\n")
            return body
    except urllib.error.HTTPError as e:
        print(f"HTTP Error {e.code}: {e.read().decode('utf-8')}\n")
    except Exception as e:
        print(f"Error: {e}\n")

# First, let's login to get a session cookie
print("--- LOGGING IN ---")
login_res = post('https://colorsforever.com/api/login', {
    'username': 'praveen@braintreeproducts.com',
    'password': '123' # test credentials or common test login
})

# Probe melle_get_attribute for various attrTypes
attr_types = [
    'add_cart', 'addcart', 'add_to_cart', 'add', 'save_cart',
    'cart', 'get_cart', 'cart_list', 'view_cart',
    'delete_cart', 'remove_cart', 'item'
]

for at in attr_types:
    post('https://colorsforever.com/api/melle_get_attribute', {
        'attrType': at,
        'color': 'Blue',
        'color_ch': 'Aqua Blue I',
        'size': '0.9 MM',
        'grade': 'VVS1-VS2',
        'quantity': '5',
        'stone_type': 'mellee',
        'user_id': '25'
    })

# Also probe endpoints: melle_add_cart, add_cart, get_cart, melle_index with session
post('https://colorsforever.com/api/melle_add_cart', {
    'color': 'Blue',
    'color_ch': 'Aqua Blue I',
    'size': '0.9 MM',
    'grade': 'VVS1-VS2',
    'quantity': '5',
    'stone_type': 'mellee',
    'user_id': '25'
})

post('https://colorsforever.com/api/melle_index', {'user_id': '25'})
