from pathlib import Path

path = Path('lib/dashboard/dashboard_v3_screen.dart')
text = path.read_text()
old = '      height: compact ? 206 : 196,'
new = '      height: compact ? 206 : 198,'
if old not in text:
    raise SystemExit('Expected LOT04D practice-row height not found')
path.write_text(text.replace(old, new, 1))
