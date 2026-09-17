from pathlib import Path

path = Path('lib/dashboard/dashboard_v3_screen.dart')
text = path.read_text()

def replace_block(source, start_marker, end_marker, replacement):
    start = source.index(start_marker)
    end = source.index(end_marker, start)
    return source[:start] + replacement + source[end:]

target_dashboard = r'''class _TargetDashboard extends StatelessWidget {
  const _TargetDashboard();

  static const double _designWidth = 390;
  static const double _designHeight = 760;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: FittedBox(
                alignment: Alignment.topCenter,
                fit: BoxFit.contain,
                child: SizedBox(
                  key: DashboardV3Screen.screenKey,
                  width: _designWidth,
                  height: _designHeight,
                  child: Stack(
                    children: <Widget>[
                      const Positioned(
                        left: 19,
                        right: 19,
                        top: 10,
                        height: 38,
                        child: _BrandHeader(),
                      ),
                      const Positioned(
                        left: 20,
                        top: 58,
                        child: Text(
                          'Good evening',
                          style: TextStyle(
                            fontSize: 14.2,
                            height: 1,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.15,
                            color: TrueGroundColors.inkMuted,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 19,
                        right: 19,
                        top: 78,
                        child: Text(
                          'Choose your next move.',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 28.5,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.65,
                            color: TrueGroundColors.primary,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 20,
                        right: 19,
                        top: 112,
                        child: Text(
                          'Make room for uncertainty.\nChoose what matters.',
                          style: TextStyle(
                            fontSize: 15.6,
                            height: 1.25,
                            fontWeight: FontWeight.w400,
                            color: TrueGroundColors.inkMuted,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 19,
                        right: 19,
                        top: 160,
                        height: 122,
                        child: _HeroCard(onTap: () => context.go('/loop')),
                      ),
                      Positioned(
                        key: DashboardV3Screen.practiceGridKey,
                        left: 19,
                        right: 19,
                        top: 294,
                        height: 198,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              child: _TargetCard(
                                icon: Icons.pause_rounded,
                                title: 'Pause the ritual',
                                description: 'Create space\nbetween the urge\nand the action.',
                                onTap: () => context.go('/practice'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _TargetCard(
                                icon: Icons.eco_outlined,
                                title: 'Practice uncertainty',
                                description: 'Guided exercises to\nbuild tolerance, not\ncertainty.',
                                onTap: () => context.go('/practice'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _TargetCard(
                                icon: Icons.bar_chart_rounded,
                                title: 'Continue planned practice',
                                description: 'Return to your ERP\nexercises at your\npace.',
                                onTap: () => context.go('/practice'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        key: DashboardV3Screen.valuesGridKey,
                        left: 19,
                        right: 19,
                        top: 504,
                        height: 144,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const Expanded(
                              child: _WideCard(
                                icon: Icons.explore_outlined,
                                title: 'Return to what matters',
                                description: 'Work • Family • Rest • Faith •\nFriends',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _WideCard(
                                icon: Icons.groups_2_outlined,
                                title: 'Need a person, not an answer?',
                                description: 'Find support from a therapist or\na trusted person.',
                                onTap: () => context.go('/support'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        left: 19,
                        right: 19,
                        top: 660,
                        height: 68,
                        child: _ReviewCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

'''
text = replace_block(text, 'class _TargetDashboard extends StatelessWidget {', 'class _AccessibleDashboard extends StatelessWidget {', target_dashboard)

target_card = r'''class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${title.replaceAll('\n', ' ')}. ${description.replaceAll('\n', ' ')}',
      excludeSemantics: true,
      child: _GlassPanel(
        onTap: onTap,
        child: Stack(
          children: <Widget>[
            Positioned(left: 12, top: 13, child: _RoundIcon(icon: icon, size: 44)),
            Positioned(
              left: 12,
              right: 8,
              top: 68,
              height: 52,
              child: Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15.8,
                  height: 1.04,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.22,
                  color: TrueGroundColors.primary,
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 6,
              top: 126,
              height: 40,
              child: Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.3,
                  height: 1.18,
                  color: TrueGroundColors.inkMuted,
                ),
              ),
            ),
            const Positioned(
              left: 10,
              bottom: 7,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: TrueGroundColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

'''
text = replace_block(text, 'class _TargetCard extends StatelessWidget {', 'class _WideCard extends StatelessWidget {', target_card)

wide_card = r'''class _WideCard extends StatelessWidget {
  const _WideCard({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '${title.replaceAll('\n', ' ')}. ${description.replaceAll('\n', ' ')}',
      excludeSemantics: true,
      child: _GlassPanel(
        onTap: onTap,
        child: Stack(
          children: <Widget>[
            Positioned(left: 12, top: 12, child: _RoundIcon(icon: icon, size: 42)),
            const Positioned(
              right: 10,
              top: 22,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 21,
                color: TrueGroundColors.inkMuted,
              ),
            ),
            Positioned(
              left: 12,
              right: 10,
              top: 62,
              height: 38,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15.2,
                  height: 1.04,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.18,
                  color: TrueGroundColors.primary,
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 10,
              top: 105,
              height: 30,
              child: Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.3,
                  height: 1.16,
                  color: TrueGroundColors.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

'''
text = replace_block(text, 'class _WideCard extends StatelessWidget {', 'class _ReviewCard extends StatelessWidget {', wide_card)

old = """                Text(\n                  'TrueGround',\n                  style: TextStyle("""
new = """                Text(\n                  'TrueGround',\n                  textScaler: TextScaler.noScaling,\n                  style: TextStyle("""
if old not in text:
    raise SystemExit('brand wordmark fragment not found')
text = text.replace(old, new, 1)

path.write_text(text)
