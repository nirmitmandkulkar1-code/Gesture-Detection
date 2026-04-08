import 'package:flutter/material.dart';

class GestureSign {
  const GestureSign({
    required this.id,
    required this.label,
    required this.description,
    required this.angleHint,
    required this.phrase,
    required this.icon,
    required this.color,
  });

  final int id;
  final String label;
  final String description;
  final String angleHint;
  final String phrase;
  final IconData icon;
  final Color color;
}
