from pathlib import Path

path = Path('lib/dashboard/dashboard_v3_screen.dart')
text = path.read_text()

replacements = [
    (
        "color: TrueGroundColors.primary.withValues(alpha: 0.13),\n            blurRadius: 22,\n            offset: const Offset(0, 9),",
        "color: TrueGroundColors.primary.withValues(alpha: 0.15),\n            blurRadius: 24,\n            offset: const Offset(0, 9),",
    ),
    (
        "filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),",
        "filter: ImageFilter.blur(sigmaX: 11, sigmaY: 11),",
    ),
    (
        "Colors.white.withValues(alpha: 0.72),\n                        Colors.white.withValues(alpha: 0.48),",
        "Colors.white.withValues(alpha: 0.56),\n                        Colors.white.withValues(alpha: 0.30),",
    ),
    (
        "color: Colors.white.withValues(alpha: 0.94),\n                      width: 1.2,",
        "color: Colors.white.withValues(alpha: 0.98),\n                      width: 1.35,",
    ),
    (
        "color: Colors.white.withValues(alpha: 0.88),",
        "color: Colors.white.withValues(alpha: 0.95),",
    ),
    (
        "color: Colors.white.withValues(alpha: 0.52),",
        "color: Colors.white.withValues(alpha: 0.42),",
    ),
]

for old, new in replacements:
    if old not in text:
        raise SystemExit(f'missing expected glass target fragment: {old}')
    text = text.replace(old, new, 1)

path.write_text(text)
