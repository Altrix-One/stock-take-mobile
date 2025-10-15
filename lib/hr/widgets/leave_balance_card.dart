import 'package:flutter/material.dart';

class LeaveBalanceCard extends StatelessWidget {
  final Map<String, dynamic>? balances;
  final EdgeInsetsGeometry padding;
  final bool showTitle;

  const LeaveBalanceCard(
      {super.key,
      required this.balances,
      this.padding = const EdgeInsets.all(16),
      this.showTitle = true});

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  // Professional, cohesive color palette for leave types - Royal Blue theme
  static const List<Color> _palette = [
    Color(0xFF1436AC), // Royal Blue (Primary)
    Color(0xFF1483EB), // Ocean Blue (Primary Light)
    Color(0xFF27AE60), // Professional Green (Success)
    Color(0xFFF39C12), // Warm Amber (Warning)
    Color(0xFF0D5EAF), // Medium Blue
    Color(0xFF0A2F6B), // Dark Royal Blue
  ];

  // Build a stable color map based on order so each leave type gets a distinct color.
  Map<String, Color> _buildAccentMap(
      List<String> titles, Brightness brightness) {
    final map = <String, Color>{};
    for (var i = 0; i < titles.length; i++) {
      final base = _palette[i % _palette.length];
      map[titles[i]] =
          brightness == Brightness.dark ? base.withOpacity(0.9) : base;
    }
    return map;
  }

  Widget _balanceTile(BuildContext context, String title,
      Map<String, dynamic> data, Color accent) {
    final theme = Theme.of(context);
    final allocated = _toDouble(data['allocated_leaves']);
    final usedRaw = _toDouble(data['leaves_taken']);
    final balance = _toDouble(data['balance_leaves']);
    final used =
        usedRaw > 0 ? usedRaw : (allocated - balance).clamp(0.0, allocated);
    final pct = allocated > 0 ? (used / allocated).clamp(0.0, 1.0) : 0.0;

    IconData iconFor(String t) {
      final lt = t.toLowerCase();
      if (lt.contains('sick')) return Icons.healing_outlined;
      if (lt.contains('annual') || lt.contains('vac') || lt.contains('holiday'))
        return Icons.beach_access_outlined;
      if (lt.contains('casual')) return Icons.weekend_outlined;
      if (lt.contains('comp') || lt.contains('time off') || lt.contains('off'))
        return Icons.timer_outlined;
      return Icons.event_available_outlined;
    }

    // Calculate remaining balance percentage for semantic color coding
    final remaining =
        allocated > 0 ? (balance / allocated).clamp(0.0, 1.0) : 1.0;
    Color progressColor;
    if (remaining >= 0.5) {
      progressColor =
          const Color(0xFF27AE60); // Professional Green - Good balance
    } else if (remaining >= 0.25) {
      progressColor =
          const Color(0xFFF39C12); // Warm Amber - Warning low balance
    } else {
      progressColor =
          const Color(0xFFE74C3C); // Professional Red - Critical low balance
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white
            .withOpacity(0.1), // Glass effect on royal blue background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row with icon, title, and balance
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconFor(title), size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${balance.toStringAsFixed(1)} days',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar with usage info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(pct * 100).toStringAsFixed(0)}% used',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: progressColor,
                          ),
                        ),
                        Text(
                          '${used.toStringAsFixed(1)} / ${allocated.toStringAsFixed(1)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: pct),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 6,
                            backgroundColor: theme.colorScheme.surfaceVariant
                                .withOpacity(0.3),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(progressColor),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(
      BuildContext context, String label, double value, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final map = balances ?? {};
    final entries = map.entries.toList();

    final cardBg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.15),
        Colors.white.withOpacity(0.05),
      ],
    );

    // Precompute distinct accents per title using current brightness
    final titles = entries.map((e) => e.key.toString()).toList();
    final accentMap = _buildAccentMap(titles, theme.brightness);

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(gradient: cardBg),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTitle) ...[
                Row(
                  children: [
                    Icon(Icons.event_available_outlined,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Text('Leave Balances',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        size: 48,
                        color:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No leave balances available',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your leave balances will appear here',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 140,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.95),
                    itemCount: entries.length,
                    padEnds: false,
                    itemBuilder: (context, i) {
                      final e = entries[i];
                      final title = e.key.toString();
                      final data = (e.value is Map<String, dynamic>)
                          ? e.value as Map<String, dynamic>
                          : <String, dynamic>{};
                      final accent =
                          accentMap[title] ?? _palette[i % _palette.length];
                      return _balanceTile(context, title, data, accent);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
