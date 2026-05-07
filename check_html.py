import os
import re
from html.parser import HTMLParser

class MyHTMLParser(HTMLParser):
    def __init__(self, filename):
        super().__init__()
        self.filename = filename
        self.stack = []
        self.errors = []
        # self.void_elements based on HTML5 spec
        self.void_elements = {"area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "source", "track", "wbr"}

    def handle_starttag(self, tag, attrs):
        if tag not in self.void_elements:
            self.stack.append((tag, self.getpos()))

    def handle_endtag(self, tag):
        if tag in self.void_elements:
            return
            
        if not self.stack:
            self.errors.append(f"Line {self.getpos()[0]}: Unexpected end tag </{tag}> without any open tags.")
            return

        last_tag, pos = self.stack.pop()
        if last_tag != tag:
            self.errors.append(f"Line {self.getpos()[0]}: Mismatched end tag </{tag}>. Expected </{last_tag}> (opened at line {pos[0]}).")
            # Recover
            found = False
            for i in range(len(self.stack)-1, -1, -1):
                if self.stack[i][0] == tag:
                    found = True
                    self.stack = self.stack[:i]
                    break
            if not found:
                self.stack.append((last_tag, pos))

for root, dirs, files in os.walk('templates'):
    for f in files:
        if f.endswith('.html'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                content = file.read()
                
                # Replace jinja tags with spaces to preserve line numbers
                def replacer(match):
                    return ' ' * len(match.group(0))
                    
                # We should replace multiline jinja tags preserving newlines
                def newline_replacer(match):
                    text = match.group(0)
                    return '\n' * text.count('\n') + ' ' * (len(text) - text.count('\n'))
                    
                content = re.sub(r'\{%.*?%\}', newline_replacer, content, flags=re.DOTALL)
                content = re.sub(r'\{\{.*?\}\}', newline_replacer, content, flags=re.DOTALL)
                content = re.sub(r'\{#.*?#\}', newline_replacer, content, flags=re.DOTALL)
                
                parser = MyHTMLParser(filepath)
                try:
                    parser.feed(content)
                    if parser.stack:
                        # Ignore "block" or "extends" pseudo tags if any sneaked in
                        for tag, pos in parser.stack:
                            parser.errors.append(f"Unclosed tag <{tag}> opened at line {pos[0]}.")
                    
                    if parser.errors:
                        print(f"Errors in {filepath}:")
                        for err in parser.errors:
                            print(f"  {err}")
                except Exception as e:
                    print(f"Failed to parse {filepath}: {e}")
print("Check complete.")
