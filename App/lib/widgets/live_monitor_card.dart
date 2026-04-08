import 'package:flutter/material.dart';

import '../models/gesture_sign.dart';
import 'status_chip.dart';

class LiveMonitorCard extends StatelessWidget {
  const LiveMonitorCard({
    super.key,
    required this.sign,
    required this.arduinoConnected,
    required this.currentAngle,
  });

  final GestureSign sign;
  final bool arduinoConnected;
  final int currentAngle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(18),
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
                const Icon(Icons.sensors_rounded, color: Color(0xFF0D3B66)),
                const SizedBox(width: 8),
                Text(
                  'Arduino Gesture Stream',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                StatusChip(
                  text: arduinoConnected ? 'Connected' : 'Disconnected',
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
            _InfoRow(label: 'Detected Sign', value: sign.label),
            const SizedBox(height: 10),
            _InfoRow(label: 'Expected Angle', value: sign.angleHint),
            const SizedBox(height: 10),
            _InfoRow(label: 'Current Angle', value: '$currentAngle degrees'),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: (currentAngle.clamp(0, 90)) / 90,
                minHeight: 10,
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
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF19354A),
                ),
          ),
        ),
      ],
    );
  }
}
