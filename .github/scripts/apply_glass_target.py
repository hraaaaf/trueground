from pathlib import Path
import re

path = Path('lib/dashboard/dashboard_v3_screen.dart')
text = path.read_text()

if "import 'dart:ui' show ImageFilter;" not in text:
    text = "import 'dart:ui' show ImageFilter;\n\n" + text

text = text.replace(
    "color: TrueGroundColors.heroBlue.withValues(alpha: 0.18),\n              blurRadius: 18,\n              offset: const Offset(0, 7),",
    "color: TrueGroundColors.heroBlue.withValues(alpha: 0.26),\n              blurRadius: 22,\n              offset: const Offset(0, 8),",
    1,
)
text = text.replace(
    "color: Colors.white.withValues(alpha: 0.48),\n                    width: 1,",
    "color: Colors.white.withValues(alpha: 0.72),\n                    width: 1.2,",
    1,
)
text = text.replace(
    "color: Colors.white.withValues(alpha: 0.4),",
    "color: Colors.white.withValues(alpha: 0.58),",
    1,
)

hero_anchor = """                    const Positioned.fill(
                      child: CustomPaint(painter: _HeroBackdropPainter()),
                    ),
"""
hero_gloss = hero_anchor + """                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                Colors.white.withValues(alpha: 0.16),
                                Colors.white.withValues(alpha: 0.02),
                                Colors.white.withValues(alpha: 0.08),
                              ],
                              stops: const <double>[0, 0.52, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
"""
if "stops: const <double>[0, 0.52, 1]" not in text:
    if hero_anchor not in text:
        raise SystemExit('hero anchor not found')
    text = text.replace(hero_anchor, hero_gloss, 1)

mini = '''class _MiniActionCard extends StatelessWidget {
  const _MiniActionCard({required this.icon, required this.title, required this.description, required this.compact, required this.onTap});
  final IconData icon;
  final String title;
  final String description;
  final bool compact;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $description',
      excludeSemantics: true,
      child: _GlassPanel(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(compact ? 10 : 12, compact ? 10 : 11, compact ? 8 : 10, compact ? 9 : 10),
          child: LayoutBuilder(builder: (context, constraints) {
            final title = Text(this.title, style: TextStyle(fontFamily: 'serif', fontSize: compact ? 13.1 : 14.5, height: 1.05, fontWeight: FontWeight.w600, color: TrueGroundColors.primary));
            final description = Text(this.description, style: TextStyle(fontSize: compact ? 9.1 : 9.8, height: 1.2, color: TrueGroundColors.inkMuted));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _RoundIcon(icon: icon, compact: true),
                const SizedBox(height: 8),
                if (constraints.hasBoundedHeight) SizedBox(height: compact ? 44 : 48, child: Align(alignment: Alignment.topLeft, child: title)) else title,
                const SizedBox(height: 4),
                if (constraints.hasBoundedHeight) SizedBox(height: compact ? 46 : 42, child: Align(alignment: Alignment.topLeft, child: description)) else description,
                if (constraints.hasBoundedHeight) const Spacer() else const SizedBox(height: 8),
                const Align(alignment: Alignment.bottomLeft, child: Icon(Icons.chevron_right_rounded, size: 18, color: TrueGroundColors.inkMuted)),
              ],
            );
          }),
        ),
      ),
    );
  }
}'''

detail = '''class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.icon, required this.title, required this.description, required this.compact, this.onTap});
  final IconData icon;
  final String title;
  final String description;
  final bool compact;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(builder: (context, constraints) {
      final title = Text(this.title, style: TextStyle(fontFamily: 'serif', fontSize: compact ? 12.9 : 14.2, height: 1.05, fontWeight: FontWeight.w600, color: TrueGroundColors.primary));
      final description = Text(this.description, style: TextStyle(fontSize: compact ? 9.0 : 9.7, height: 1.18, color: TrueGroundColors.inkMuted));
      return Padding(
        padding: EdgeInsets.fromLTRB(compact ? 10 : 11, compact ? 9 : 10, compact ? 10 : 11, compact ? 9 : 10),
        child: Column(
          mainAxisAlignment: constraints.hasBoundedHeight ? MainAxisAlignment.center : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[_RoundIcon(icon: icon, compact: true), const Spacer(), const Icon(Icons.chevron_right_rounded, size: 19, color: TrueGroundColors.inkMuted)]),
            const SizedBox(height: 6),
            if (constraints.hasBoundedHeight) SizedBox(height: compact ? 28 : 32, child: Align(alignment: Alignment.topLeft, child: title)) else title,
            const SizedBox(height: 4),
            if (constraints.hasBoundedHeight) SizedBox(height: compact ? 34 : 36, child: Align(alignment: Alignment.topLeft, child: description)) else description,
          ],
        ),
      );
    });
    return Semantics(button: onTap != null, label: '$title. $description', excludeSemantics: true, child: _GlassPanel(onTap: onTap, child: content));
  }
}'''

review_glass = '''class _ReviewCard extends StatelessWidget {
  const _ReviewCard();
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Review patterns when useful. Look at recurring themes, without judgment.',
      excludeSemantics: true,
      child: _GlassPanel(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: <Widget>[
              _RoundIcon(icon: Icons.bar_chart_rounded, compact: true),
              SizedBox(width: 10),
              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text('Review patterns when useful', style: TextStyle(fontFamily: 'serif', fontSize: 14, height: 1.08, fontWeight: FontWeight.w600, color: TrueGroundColors.primary)),
                SizedBox(height: 3),
                Text('Look at recurring themes, without judgment.', style: TextStyle(fontSize: 9.7, height: 1.16, color: TrueGroundColors.inkMuted)),
              ])),
              Icon(Icons.chevron_right_rounded, size: 20, color: TrueGroundColors.inkMuted),
            ]),
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);
    final materialChild = Material(type: MaterialType.transparency, child: onTap == null ? child : InkWell(onTap: onTap, child: child));
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(color: TrueGroundColors.primary.withValues(alpha: 0.13), blurRadius: 22, offset: const Offset(0, 9)),
          BoxShadow(color: Colors.white.withValues(alpha: 0.68), blurRadius: 8, offset: const Offset(-2, -2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Colors.white.withValues(alpha: 0.72), Colors.white.withValues(alpha: 0.48)]),
                borderRadius: borderRadius,
                border: Border.all(color: Colors.white.withValues(alpha: 0.94), width: 1.2),
              ))),
              materialChild,
              Positioned(top: 1, left: 14, right: 14, child: IgnorePointer(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.88)))),
            ],
          ),
        ),
      ),
    );
  }
}'''

def swap(source, start, end, replacement):
    pattern = rf'class {start} extends StatelessWidget \{{.*?\n\}}\n\nclass {end}'
    out, count = re.subn(pattern, replacement + '\n\nclass ' + end, source, count=1, flags=re.S)
    if count != 1:
        raise SystemExit(f'failed replacing {start}: {count}')
    return out

text = swap(text, '_MiniActionCard', '_DetailCard', mini)
text = swap(text, '_DetailCard', '_ReviewCard', detail)
text = swap(text, '_ReviewCard', '_RoundIcon', review_glass)
text = text.replace("color: TrueGroundColors.iconWash.withValues(alpha: 0.76),", "color: Colors.white.withValues(alpha: 0.52),", 1)
text = text.replace("color: Colors.white.withValues(alpha: 0.64),\n          width: 0.8,", "color: Colors.white.withValues(alpha: 0.86),\n          width: 1,", 1)
path.write_text(text)
