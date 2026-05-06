import os
import re

directories = ["templates", "design"]

replacements = {
    r"#C5A55A": "#D4AF37",
    r"\[#C5A55A\]": "[#D4AF37]",
    r"#B8B8B8": "#94A3B8",
    r"\[#B8B8B8\]": "[#94A3B8]",
    r"#2D2D2D": "#0F172A",
    r"\[#2D2D2D\]": "[#0F172A]",
    # Change 'slate-800' to 'slate-900' for charcoal
    r"slate-800": "slate-900",
}

for d in directories:
    for root, _, files in os.walk(d):
        for file in files:
            if file.endswith(".html") or file.endswith(".md"):
                path = os.path.join(root, file)
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()
                
                original = content
                for pattern, repl in replacements.items():
                    content = re.sub(pattern, repl, content)
                
                if original != content:
                    with open(path, "w", encoding="utf-8") as f:
                        f.write(content)
                    print(f"Updated {path}")

# Also check python files for charts
py_dir = "src/reports"
for root, _, files in os.walk(py_dir):
    for file in files:
        if file.endswith(".py"):
            path = os.path.join(root, file)
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            
            original = content
            for pattern, repl in replacements.items():
                content = re.sub(pattern, repl, content)
            
            if original != content:
                with open(path, "w", encoding="utf-8") as f:
                    f.write(content)
                print(f"Updated {path}")
print("Done")
