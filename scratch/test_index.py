import urllib.request
import json

url = 'https://colorsforever.com/api/jewelry_index'
headers = {
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'User-Agent': 'Mozilla/5.0 (Mobile; ColorsForeverApp)'
}

req = urllib.request.Request(url, headers=headers)
try:
    res = urllib.request.urlopen(req)
    body = json.loads(res.read().decode('utf-8'))
    data = body.get('data', {})
    for key in data:
        if isinstance(data[key], list):
            print(f"{key}: {data[key]}")
        elif isinstance(data[key], dict):
            print(f"{key}: {list(data[key].keys())}")
        else:
            print(f"{key}: {data[key]}")
except Exception as e:
    print(f"Error: {e}")
