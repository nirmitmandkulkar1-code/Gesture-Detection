import 'package:flutter/material.dart';
import '../models/gesture_log_entry.dart';
import '../models/gesture_sign.dart';

class GestureLogCard extends StatelessWidget {
  const GestureLogCard({
    super.key,
    required this.entries,
    required this.signs,
    required this.onClear,
  });

  final List<GestureLogEntry> entries;
  final List<GestureSign> signs;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF2F8FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded,
                      color: Color(0xFF0D3B66), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gesture Log',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 14),
                    ),
                  ),
                  // entry count badge
                  if (entries.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D3B66).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${entries.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D3B66),
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  // clear button
                  if (entries.isNotEmpty)
                    TextButton(
                      onPressed: onClear,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFD64545),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Clear',
                          style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFDDEAF3)),

            // ── Log entries ────────────────────────────────────────────────
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 28, horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.sensors_off_rounded,
                        color: Color(0xFFAEC6D4), size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'No gestures detected yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFAEC6D4),
                          ),
                    ),
                  ],
                ),
              )
            else
              // show latest first, cap to 20 visible rows
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length > 20 ? 20 : entries.length,
                separatorBuilder: (_, __) => const Divider(
                    height: 1, indent: 16, color: Color(0xFFEEF4F8)),
                itemBuilder: (context, index) {
                  final entry = entries[index]; // already reversed in parent
                  // find the matching sign to get its color/icon
                  final sign = signs.firstWhere(
                    (s) => s.label == entry.label,
                    orElse: () => signs.first,
                  );
                  final isFirst = index == 0;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    color: isFirst
                        ? sign.color.withValues(alpha: 0.06)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // icon pill
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: sign.color.withValues(alpha: 0.13),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(sign.icon,
                              size: 16, color: sign.color),
                        ),
                        const SizedBox(width: 12),
                        // label + phrase
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    entry.label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: sign.color,
                                    ),
                                  ),
                                  if (isFirst) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: sign.color
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'LATEST',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: sign.color,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.phrase,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF486378),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // timestamp + sensor value
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              entry.timeFormatted,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8AAABB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'val: ${entry.sensorValue}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFAEC6D4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
