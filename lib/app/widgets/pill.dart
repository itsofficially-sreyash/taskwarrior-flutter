import 'package:flutter/material.dart';
import 'package:taskwarrior/app/utils/constants/taskwarrior_fonts.dart';
import 'package:taskwarrior/app/utils/gen/fonts.gen.dart';

class Pill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;

  const Pill({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: FontFamily.poppins,
              fontSize: 10,
              fontWeight: TaskWarriorFonts.semiBold,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
