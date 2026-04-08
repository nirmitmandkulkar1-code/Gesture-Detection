import 'package:flutter/material.dart';

import '../models/gesture_sign.dart';

class SpeechOutputCard extends StatelessWidget {
  const SpeechOutputCard({
    super.key,
    required this.sign,
  });

  final GestureSign sign;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF5FAFD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.record_voice_over_rounded, color: sign.color),
                const SizedBox(width: 8),
                Text(
                  'Voice Preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play'),
                  style: FilledButton.styleFrom(
                    backgroundColor: sign.color,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Generated Sentence',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: sign.color.withValues(alpha: 0.1),
                border: Border.all(color: sign.color.withValues(alpha: 0.25)),
              ),
              child: Text(
                sign.phrase,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF19354A),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
