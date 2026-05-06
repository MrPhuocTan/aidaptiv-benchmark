import os
import re

directories = ["templates"]

replacements = [
    # Replace blue/indigo/violet/purple/sky with gold
    (r"(bg|text|border|ring|hover:bg|hover:text)-(blue|indigo|violet|purple|sky)-[4567]00", r"\1-gold-400"),
    (r"(bg|text|border|ring)-(blue|indigo|violet|purple|sky)-[89]00", r"\1-slate-900"),
    (r"(bg|text|border|ring)-(blue|indigo|violet|purple|sky)-[123]00", r"\1-gold-200"),
    (r"(bg|text|border|ring)-(blue|indigo|violet|purple|sky)-50", r"\1-gold-50"),
    
    # Replace gray with slate
    (r"(bg|text|border|ring|hover:bg|hover:text)-gray-([1-9]00|50)", r"\1-slate-\2"),
    
    # Replace amber/yellow with gold
    (r"(bg|text|border|ring)-amber-[456]00", r"\1-gold-400"),
    (r"(bg|text|border|ring)-yellow-[456]00", r"\1-gold-400"),
    (r"(bg|text|border|ring)-amber-50", r"\1-gold-50"),
    (r"(bg|text|border|ring)-yellow-50", r"\1-gold-50"),

    # Direct hex replacements from custom CSS in templates
    (r"#4f46e5", r"#D4AF37"), # indigo-600 to Gold
    (r"#4338ca", r"#A68B3C"), # indigo-700 to Gold-500
    (r"#67cdef", r"#D4AF37"), # cyan-like to Gold
    
    # Specific fix for chart palettes in python
]

for root, _, files in os.walk("templates"):
    for file in files:
        if file.endswith(".html"):
            path = os.path.join(root, file)
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            
            original = content
            for pattern, repl in replacements:
                content = re.sub(pattern, repl, content)
            
            if original != content:
                with open(path, "w", encoding="utf-8") as f:
                    f.write(content)
                print(f"Updated HTML: {path}")

# Fix Python charts
py_dir = "src/reports"
for root, _, files in os.walk(py_dir):
    for file in files:
        if file.endswith(".py"):
            path = os.path.join(root, file)
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            original = content
            
            # python replaces
            content = re.sub(r"'#3b82f6'", r"'#D4AF37'", content) # blue-500 to gold
            content = re.sub(r"'#8b5cf6'", r"'#94A3B8'", content) # violet-500 to slate-400 (silver)
            content = re.sub(r"'#ec4899'", r"'#0F172A'", content) # pink-500 to slate-900 (charcoal)
            
            if original != content:
                with open(path, "w", encoding="utf-8") as f:
                    f.write(content)
                print(f"Updated PY: {path}")

print("Done template replacements.")
