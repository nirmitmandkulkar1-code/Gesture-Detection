import 'package:flutter/material.dart';

import '../models/gesture_sign.dart';

const List<GestureSign> medicalSigns = [
  GestureSign(
    id: 1,
    label: 'Need Water',
    description: 'Patient asks for drinking water.',
    angleHint: 'Palm tilt 15 degrees left',
    phrase: 'Nurse, please give me water.',
    icon: Icons.local_drink_rounded,
    color: Color(0xFF1679AB),
  ),
  GestureSign(
    id: 2,
    label: 'Need Doctor',
    description: 'Patient requests doctor visit.',
    angleHint: 'Palm tilt 30 degrees upward',
    phrase: 'Please call the doctor.',
    icon: Icons.medical_services_rounded,
    color: Color(0xFF0D3B66),
  ),
  GestureSign(
    id: 3,
    label: 'Pain Alert',
    description: 'Patient reports pain or discomfort.',
    angleHint: 'Palm rotation 45 degrees inward',
    phrase: 'I am feeling pain, please help.',
    icon: Icons.warning_amber_rounded,
    color: Color(0xFFD64545),
  ),
  GestureSign(
    id: 4,
    label: 'Need Assistance',
    description: 'Patient asks for immediate assistance.',
    angleHint: 'Palm held steady at 60 degrees',
    phrase: 'I need assistance right now.',
    icon: Icons.support_agent_rounded,
    color: Color(0xFF8947D1),
  ),
  GestureSign(
    id: 5,
    label: 'Emergency',
    description: 'Critical emergency alert from patient.',
    angleHint: 'Palm rapid tilt beyond 75 degrees',
    phrase: 'Emergency, call the response team.',
    icon: Icons.emergency_rounded,
    color: Color(0xFFB42318),
  ),
];
