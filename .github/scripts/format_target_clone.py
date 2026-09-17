from pathlib import Path

path = Path('lib/dashboard/dashboard_v3_screen.dart')
text = path.read_text()
replacements = {
    "title: 'Pause the\\nritual',": "title: 'Pause the ritual',",
    "title: 'Practice\\nuncertainty',": "title: 'Practice uncertainty',",
    "title: 'Continue\\nplanned\\npractice',": "title: 'Continue planned practice',",
    "title: 'Need a person, not an\\nanswer?',": "title: 'Need a person, not an answer?',",
}
for old, new in replacements.items():
    if old not in text:
        raise SystemExit(f'missing expected fragment: {old}')
    text = text.replace(old, new, 1)
path.write_text(text)
