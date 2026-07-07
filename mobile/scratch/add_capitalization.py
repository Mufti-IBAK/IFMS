import os
import re

directory = r'c:\Users\USER\Desktop\farm_works\mobile\lib\features'

modified_count = 0

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # skip if already modified manually
            # we will just add textCapitalization if not present
            def replacer(match):
                prefix = match.group(0) # e.g. "TextField("
                return prefix + "textCapitalization: TextCapitalization.sentences, "

            # We need to make sure we don't add it twice.
            # We'll split the content by TextField( and TextFormField(
            # and check if the next words are textCapitalization.
            # Simpler: just do the dumb replace, then fix double injections.
            
            new_content = re.sub(r'TextField\(\s*(?!textCapitalization:)', 'TextField(textCapitalization: TextCapitalization.sentences, ', content)
            new_content = re.sub(r'TextFormField\(\s*(?!textCapitalization:)', 'TextFormField(textCapitalization: TextCapitalization.sentences, ', new_content)
            
            if content != new_content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                modified_count += 1
                print(f"Modified {file}")

print(f"Total files modified: {modified_count}")
