from pathlib import Path


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if old not in text:
        raise SystemExit(f'missing target-first fragment: {label}')
    return text.replace(old, new, 1)


dashboard_path = Path('lib/dashboard/dashboard_v3_screen.dart')
text = dashboard_path.read_text()

replacements = [
    ("            8,\n            compactPhone ? 16 : 18,\n            12,", "            10,\n            compactPhone ? 16 : 18,\n            14,", 'screen vertical padding'),
    ("                  const SizedBox(height: 10),\n                  const Text(\n                    'Good evening',", "                  const SizedBox(height: 13),\n                  const Text(\n                    'Good evening',", 'header greeting gap'),
    ("                      fontSize: 13.5,", "                      fontSize: 15.5,", 'greeting font'),
    ("                        fontSize: compactPhone ? 28 : 29,", "                        fontSize: compactPhone ? 29 : 32,", 'headline font'),
    ("                      fontSize: 14,\n                      height: 1.25,", "                      fontSize: 16,\n                      height: 1.22,", 'subtitle font'),
    ("                  const SizedBox(height: 14),\n                  _PrimaryActionCard(", "                  const SizedBox(height: 15),\n                  _PrimaryActionCard(", 'hero lead gap'),
    ("      width: 32,\n      height: 32,", "      width: 34,\n      height: 34,", 'brand mark'),
    ("        fontSize: 22,", "        fontSize: 26,", 'wordmark font'),
    ("        size: 21,", "        size: 23,", 'theme icon'),
    ("              height: 38,", "              height: 44,", 'brand row height'),
    ("              constraints: BoxConstraints(minHeight: compact ? 118 : 118),", "              constraints: BoxConstraints(minHeight: compact ? 126 : 132),", 'hero height'),
    ("                        horizontal: 14,\n                        vertical: 13,", "                        horizontal: 16,\n                        vertical: 15,", 'hero padding'),
    ("                            width: 52,\n                            height: 52,", "                            width: 58,\n                            height: 58,", 'hero icon size'),
    ("                              size: 28,", "                              size: 30,", 'hero glyph'),
    ("                          const SizedBox(width: 12),", "                          const SizedBox(width: 14),", 'hero icon gap'),
    ("                                    fontSize: 20,", "                                    fontSize: 22.5,", 'hero title'),
    ("                                    fontSize: 11.5,", "                                    fontSize: 13.2,", 'hero description'),
    ("                              size: 24,", "                              size: 26,", 'hero chevron'),
    ("      height: compact ? 220 : 214,", "      height: compact ? 206 : 196,", 'practice row height'),
    ("      height: compact ? 154 : 156,", "      height: compact ? 154 : 158,", 'detail row height'),
    ("            compact ? 10 : 12,\n            compact ? 10 : 11,\n            compact ? 8 : 10,\n            compact ? 9 : 10,", "            compact ? 11 : 13,\n            compact ? 12 : 13,\n            compact ? 9 : 11,\n            compact ? 10 : 11,", 'mini card padding'),
    ("                  fontSize: compact ? 13.1 : 14.5,", "                  fontSize: compact ? 14.5 : 16.5,", 'mini title font'),
    ("                  fontSize: compact ? 9.1 : 9.8,", "                  fontSize: compact ? 10.4 : 11.5,", 'mini description font'),
    ("                      height: compact ? 44 : 48,", "                      height: compact ? 50 : 52,", 'mini title zone'),
    ("                      height: compact ? 46 : 42,", "                      height: compact ? 54 : 48,", 'mini description zone'),
    ("                      size: 18,", "                      size: 19,", 'mini chevron'),
    ("            fontSize: compact ? 12.9 : 14.2,", "            fontSize: compact ? 14.2 : 16.5,", 'detail title font'),
    ("            fontSize: compact ? 9.0 : 9.7,", "            fontSize: compact ? 10.2 : 11.5,", 'detail description font'),
    ("            compact ? 10 : 11,\n            compact ? 9 : 10,\n            compact ? 10 : 11,\n            compact ? 9 : 10,", "            compact ? 11 : 13,\n            compact ? 10 : 11,\n            compact ? 11 : 13,\n            compact ? 10 : 11,", 'detail padding'),
    ("                  height: compact ? 28 : 32,", "                  height: compact ? 34 : 38,", 'detail title zone'),
    ("                  height: compact ? 34 : 36,", "                  height: compact ? 40 : 42,", 'detail description zone'),
    ("          constraints: const BoxConstraints(minHeight: 60),", "          constraints: const BoxConstraints(minHeight: 68),", 'review height'),
    ("            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),", "            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),", 'review padding'),
    ("                SizedBox(width: 10),", "                SizedBox(width: 12),", 'review icon gap'),
    ("                          fontSize: 14,", "                          fontSize: 15.5,", 'review title'),
    ("                          fontSize: 9.7,", "                          fontSize: 11,", 'review description'),
    ("    final borderRadius = BorderRadius.circular(18);", "    final borderRadius = BorderRadius.circular(20);", 'glass radius'),
    ("    final size = compact ? 38.0 : 44.0;", "    final size = compact ? 42.0 : 46.0;", 'round icon size'),
]

for old, new, label in replacements:
    text = replace_once(text, old, new, label)

dashboard_path.write_text(text)


theme_path = Path('lib/design/app_theme.dart')
theme = theme_path.read_text()
theme = replace_once(theme, "        height: 64,", "        height: 72,", 'nav height')
theme = replace_once(theme, "          TextStyle(fontSize: 11.5, color: TrueGroundColors.primary),", "          TextStyle(fontSize: 12.5, color: TrueGroundColors.primary),", 'nav label size')
theme = replace_once(theme, "          IconThemeData(size: 22, color: TrueGroundColors.primary),", "          IconThemeData(size: 24, color: TrueGroundColors.primary),", 'nav icon size')
theme_path.write_text(theme)


shell_path = Path('lib/shell/app_shell.dart')
shell = shell_path.read_text()
shell = replace_once(shell, "            child: ClipRect(\n              child: BackdropFilter(", "            child: ClipRRect(\n              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),\n              child: BackdropFilter(", 'nav rounded top')
shell = replace_once(shell, "                    height: usesLargeTextLayout ? 96 : null,", "                    height: usesLargeTextLayout ? 100 : null,", 'large text nav height')
shell_path.write_text(shell)
