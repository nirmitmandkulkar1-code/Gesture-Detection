class GestureLogEntry {
  GestureLogEntry({
    required this.label,
    required this.phrase,
    required this.sensorValue,
    required this.timestamp,
  });

  final String label;
  final String phrase;
  final int sensorValue;
  final DateTime timestamp;

  String get timeFormatted {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
