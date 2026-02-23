import 'package:flutter/material.dart';

class PriorityStyle {
  final Color accent;
  final Color chipBg;
  final Color chipFg;
  final String label;

  const PriorityStyle({
    required this.accent,
    required this.chipBg,
    required this.chipFg,
    required this.label,
  });
}

PriorityStyle getPriorityStyle(String? priority) {
  switch (priority) {
    case 'H':
      return const PriorityStyle(
        accent: Color(0xFFEF5350),
        chipBg: Color(0x15EF5350),
        chipFg: Color(0xFFEF5350),
        label: 'High',
      );
    case 'M':
      return const PriorityStyle(
        accent: Color(0xFFFFA726),
        chipBg: Color(0x15FFA726),
        chipFg: Color(0xFFFFA726),
        label: 'Med',
      );
    case 'L':
      return const PriorityStyle(
        accent: Color(0xFF66BB6A),
        chipBg: Color(0x1566BB6A),
        chipFg: Color(0xFF66BB6A),
        label: 'Low',
      );
    default:
      return const PriorityStyle(
        accent: Color(0xFF78909C),
        chipBg: Color(0x1278909C),
        chipFg: Color(0xFF78909C),
        label: 'None',
      );
  }
}
