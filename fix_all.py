import os
import re

html_dir = "templates"
css_file = "static/css/theme.css"

# 1. Fix theme.css
with open(css_file, "r") as f:
    css = f.read()

css = re.sub(r"@import url\('https://fonts\.googleapis\.com/css2\?family=Noto\+Serif[^']+'\);", 
             "@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap');", css)
css = re.sub(r"--gold: #C5A55A;", "--gold: #D4AF37;", css)
css = re.sub(r"--charcoal: #2D2D2D;", "--charcoal: #0F172A;", css)
css = re.sub(r"--silver: #B8B8B8;", "--silver: #94A3B8;", css)
css = re.sub(r"font-family: 'Noto Serif', 'Noto Serif TC', serif;", "font-family: 'Inter', sans-serif;", css)
css = re.sub(r"font-family:\s*'Noto Serif',[^;]+;", "font-family: 'Inter', sans-serif;", css)

with open(css_file, "w") as f:
    f.write(css)

# 2. Fix HTML files
replacements = [
    (r"(from|to|via)-(violet|indigo|purple|blue|emerald|teal)-[1-9]00(?:/[0-9]+)?", r"\1-slate-100"),
    (r"border-t-(violet|emerald|blue|indigo)-[456]00", r"border-t-gold-400"),
    (r"border-l-(violet|emerald|blue|indigo)-[456]00", r"border-l-gold-400"),
    (r"border-(violet|emerald|blue|indigo)-[456]00", r"border-gold-400"),
    (r"bg-gradient-to-[a-z] from-slate-100 to-slate-100", r"bg-slate-50"),
    
    # Chart colors
    (r"#a855f7", r"#0F172A"), # Purple to Slate 900
    (r"#9ca3af", r"#94A3B8"), # Gray to Silver
    (r"#3b82f6", r"#D4AF37"), # Blue to Gold
    (r"#7c3aed", r"#0F172A"), # Purple to Slate
    (r"#16a34a", r"#D4AF37"), # Green to Gold
    (r"#dc2626", r"#94A3B8"), # Red to Silver
    (r"#2563eb", r"#0F172A"),
    (r"#d97706", r"#D4AF37"),
    
    # Text colors that might be leftover
    (r"text-(violet|emerald|blue|indigo)-[456]00", r"text-gold-400"),
    (r"text-(violet|emerald|blue|indigo)-[789]00", r"text-slate-900"),
    (r"bg-(violet|emerald|blue|indigo)-[456]00", r"bg-gold-400"),
    (r"bg-(violet|emerald|blue|indigo)-[789]00", r"bg-slate-900"),
    (r"bg-(violet|emerald|blue|indigo)-50", r"bg-slate-50"),
    
    # Replace Noto Serif with sans in tailwind config inside base.html
    (r"serif: \['Noto Serif', 'Noto Serif TC', 'Georgia', 'serif'\],", r"sans: ['Inter', 'sans-serif'],\n                        serif: ['Inter', 'sans-serif'],"),
]

for root, _, files in os.walk(html_dir):
    for file in files:
        if file.endswith(".html"):
            path = os.path.join(root, file)
            with open(path, "r") as f:
                content = f.read()
            
            # ensure body uses sans
            if "body class=" in content:
                content = re.sub(r"body class=\"([^\"]+)\"", r'body class="\1 font-sans"', content)
                # clean up duplicate font-sans
                content = content.replace("font-sans font-sans", "font-sans")
                
            for pattern, repl in replacements:
                content = re.sub(pattern, repl, content)
                
            with open(path, "w") as f:
                f.write(content)
                
