import 'package:flutter/material.dart';
import '../models/gesture_sign.dart';
import 'status_chip.dart';

class LiveMonitorCard extends StatelessWidget {
  const LiveMonitorCard({
    super.key,
    required this.sign,
    required this.arduinoConnected,
    // FIX: receives the raw analog sensor value (0–1023), not a pre-divided angle
    required this.currentAngle,
  });

  final GestureSign sign;
  final bool arduinoConnected;
  final int currentAngle; // raw analog value 0–1023

  @override
  Widget build(BuildContext context) {
    // Map raw 0–1023 range to a 0.0–1.0 progress fraction
    final double progress = (currentAngle.clamp(0, 1023)) / 1023;

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Row(
              children: [
                const Icon(Icons.sensors_rounded,
                    color: Color(0xFF0D3B66), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Arduino Stream',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusChip(
                  text: arduinoConnected ? 'Connected' : 'Offline',
                  color: arduinoConnected
                      ? const Color(0xFF2F9E44)
                      : const Color(0xFFD64545),
                  icon: arduinoConnected
                      ? Icons.check_circle
                      : Icons.error_rounded,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Sign', value: sign.label),
            const SizedBox(height: 10),
            _InfoRow(label: 'Expected', value: sign.angleHint),
            const SizedBox(height: 10),
            // Show the raw sensor reading, not an artificial degree value
            _InfoRow(label: 'Sensor', value: currentAngle.toString()),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFDDEAF3),
                color: sign.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF486378),
                ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: const Color(0xFF19354A),
                ),
          ),
        ),
      ],
    );
  }
}
