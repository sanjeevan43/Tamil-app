import re

file_path = r'c:\HS\tamil_app\lib\services\tamil_word_filter_service.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

def dedup_set(match):
    prefix = match.group(1)
    words_str = match.group(2)
    
    words = re.findall(r"'(.*?)'", words_str)
    seen = set()
    unique_words = []
    for w in words:
        if w not in seen:
            unique_words.append(w)
            seen.add(w)
    
    new_words_str = ""
    for i in range(0, len(unique_words), 6):
        chunk = unique_words[i:i+6]
        new_words_str += "    " + ", ".join(f"'{w}'" for w in chunk) + ",\n"
    
    return f"{prefix}{{\n{new_words_str}  }};"

pattern = re.compile(r'(static const Set<String> \w+ = )\{(.*?)\};', re.DOTALL)
new_content = pattern.sub(dedup_set, content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)
