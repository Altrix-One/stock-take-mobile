import 'package:flutter/material.dart';

class LeaveBalanceCard extends StatelessWidget {
  final Map<String, dynamic>? balances;
  final EdgeInsetsGeometry padding;
  final bool showTitle;

  const LeaveBalanceCard({super.key, required this.balances, this.padding = const EdgeInsets.all(16), this.showTitle = true});

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  // A small, modern accent palette
  static const List<Color> _palette = [
    Color(0xFF6C63FF), // indigo
    Color(0xFF00BFA6), // teal
    Color(0xFFFF6584), // pink/red
    Color(0xFFFFB74D), // orange
    Color(0xFF29B6F6), // light blue
    Color(0xFFAB47BC), // purple
  ];

  // Build a stable color map based on order so each leave type gets a distinct color.
  Map<String, Color> _buildAccentMap(List<String> titles, Brightness brightness) {
    final map = <String, Color>{};
    for (var i = 0; i < titles.length; i++) {
      final base = _palette[i % _palette.length];
      map[titles[i]] = brightness == Brightness.dark ? base.withOpacity(0.9) : base;
    }
    return map;
  }

  Widget _balanceTile(BuildContext context, String title, Map<String, dynamic> data, Color accent) {
    final theme = Theme.of(context);
    final allocated = _toDouble(data['allocated_leaves']);
    final usedRaw = _toDouble(data['leaves_taken']);
    final balance = _toDouble(data['balance_leaves']);
    final used = usedRaw > 0 ? usedRaw : (allocated - balance).clamp(0.0, allocated);
    final pct = allocated > 0 ? (used / allocated).clamp(0.0, 1.0) : 0.0;

    final tileBg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        accent.withOpacity(0.14),
        accent.withOpacity(0.06),
      ],
    );

    IconData iconFor(String t) {
      final lt = t.toLowerCase();
      if (lt.contains('sick')) return Icons.healing_outlined;
      if (lt.contains('annual') || lt.contains('vac') || lt.contains('holiday')) return Icons.beach_access_outlined;
      if (lt.contains('casual')) return Icons.weekend_outlined;
      if (lt.contains('comp') || lt.contains('time off') || lt.contains('off')) return Icons.timer_outlined;
      return Icons.event_available_outlined;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: tileBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(color: accent.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [accent, accent.withOpacity(0.7)]),
                ),
                child: Icon(iconFor(title), size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: accent.withOpacity(0.2)),
                ),
                child: Text('Bal: ${balance.toStringAsFixed(1)}', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
              )
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                // Bar color based on remaining balance ratio
                final remaining = allocated > 0 ? (balance / allocated).clamp(0.0, 1.0) : 1.0;
                Color barColor;
                if (remaining >= 0.5) {
                  barColor = Colors.green;
                } else if (remaining >= 0.25) {
                  barColor = Colors.orange;
                } else {
                  barColor = Colors.redAccent;
                }
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: theme.colorScheme.onSurface.withOpacity(0.06),
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _pill(theme, 'Allocated', allocated, accent),
              _pill(theme, 'Used', used, accent.withOpacity(0.85)),
              _pill(theme, 'Balance', balance, accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(ThemeData theme, String label, double value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(label == 'Balance' ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
          Text(value.toStringAsFixed(2), style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
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
      colors: theme.brightness == Brightness.dark
          ? [
              theme.colorScheme.surfaceVariant.withOpacity(0.22),
              theme.colorScheme.surface.withOpacity(0.12),
            ]
          : [
              theme.colorScheme.surface, 
              theme.colorScheme.surfaceVariant.withOpacity(0.45),
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
                    Icon(Icons.event_available_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Text('Leave Balances', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              if (entries.isEmpty)
                Text('No balances', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)))
              else
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.92),
                    itemCount: entries.length,
                    padEnds: false,
                    itemBuilder: (context, i) {
                      final e = entries[i];
                      final title = e.key.toString();
                      final data = (e.value is Map<String, dynamic>) ? e.value as Map<String, dynamic> : <String, dynamic>{};
                      final accent = accentMap[title] ?? _palette[i % _palette.length];
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
