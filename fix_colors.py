import os
import re

directory = "templates"

replacements = {
    r"text-green-\d00": "text-[#C5A55A]",
    r"bg-green-\d00": "bg-[#C5A55A]",
    r"bg-green-50": "bg-white",
    r"border-green-\d00": "border-[#C5A55A]",
    r"text-red-\d00": "text-[#B8B8B8]",
    r"bg-red-\d00": "bg-[#B8B8B8]",
    r"bg-red-50": "bg-[#F8F9FA]",
    r"border-red-\d00": "border-[#B8B8B8]",
    r"text-blue-\d00": "text-[#C5A55A]",
    r"bg-blue-\d00": "bg-[#C5A55A]",
    r"bg-blue-50": "bg-[#F8F9FA]",
    r"border-blue-\d00": "border-[#C5A55A]",
    r"text-yellow-\d00": "text-[#C5A55A]",
    r"bg-yellow-\d00": "bg-[#C5A55A]",
    r"bg-yellow-50": "bg-[#F8F9FA]",
    r"border-yellow-\d00": "border-[#C5A55A]",
    r"bg-indigo-50": "bg-[#F8F9FA]",
    r"border-indigo-100": "border-[#B8B8B8]",
    r"text-indigo-800": "text-[#2D2D2D]",
    r"🖥️ ": "",
    r"🎮 ": "",
    r"💻 ": "",
    r"💾 ": "",
    r"🛡️ ": "",
}

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith(".html"):
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
