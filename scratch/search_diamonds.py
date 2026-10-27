import os

root_dir = r'c:\Users\Web\.gemini\antigravity\scratch\colors_forever_app\lib'
matches = []

for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                if 'solitaire' in content.lower() or 'diamond' in content.lower():
                    matches.append(filepath)

print("Files referencing Solitaire or Diamond:")
for m in matches:
    print(m)
