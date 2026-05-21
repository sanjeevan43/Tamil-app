import re

file_path = r'c:\HS\tamil_app\lib\services\tamil_word_filter_service.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

sets = []
current_set = None
for i, line in enumerate(lines):
    if 'static const Set<String>' in line:
        current_set = {'name': line.strip(), 'start': i, 'words': []}
        sets.append(current_set)
    if current_set:
        matches = re.findall(r"'(.*?)'", line)
        for m in matches:
            current_set['words'].append((m, i + 1))
        if '};' in line:
            current_set = None

for s in sets:
    seen = {}
    for word, line_num in s['words']:
        if word in seen:
            print(f"Duplicate in {s['name']}: '{word}' at lines {seen[word]} and {line_num}")
        seen[word] = line_num
