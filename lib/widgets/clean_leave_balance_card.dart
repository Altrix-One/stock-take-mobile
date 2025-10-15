import 'package:flutter/material.dart';

class CleanLeaveBalanceCard extends StatelessWidget {
  final Map<String, dynamic>? balances;

  const CleanLeaveBalanceCard({super.key, required this.balances});

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final map = balances ?? {};
    final entries = map.entries.toList();

    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 48,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            const Text(
              'No leave balances available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your leave balances will appear here',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Leave Balances',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Balance tiles
          SizedBox(
            height: 120,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final e = entries[i];
                final title = e.key.toString();
                final data = (e.value is Map<String, dynamic>)
                    ? e.value as Map<String, dynamic>
                    : <String, dynamic>{};

                final allocated = _toDouble(data['allocated_leaves']);
                final balance = _toDouble(data['balance_leaves']);
                final used = allocated - balance;
                final pct =
                    allocated > 0 ? (used / allocated).clamp(0.0, 1.0) : 0.0;

                // Progress color based on remaining balance
                final remaining =
                    allocated > 0 ? (balance / allocated).clamp(0.0, 1.0) : 1.0;
                Color progressColor;
                if (remaining >= 0.5) {
                  progressColor = Colors.green;
                } else if (remaining >= 0.25) {
                  progressColor = Colors.orange;
                } else {
                  progressColor = Colors.red;
                }

                return Container(
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: progressColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: progressColor.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${balance.toStringAsFixed(1)} days',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: progressColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(pct * 100).toStringAsFixed(0)}% used',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: progressColor,
                            ),
                          ),
                          Text(
                            '${used.toStringAsFixed(1)} / ${allocated.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 4,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
