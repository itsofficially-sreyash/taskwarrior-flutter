import 'package:flutter/material.dart';
import 'package:taskwarrior/app/utils/constants/constants.dart';
import 'package:taskwarrior/app/utils/constants/taskwarrior_fonts.dart';
import 'package:taskwarrior/app/utils/themes/theme_extension.dart';

class NavDrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  const NavDrawerMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    TaskwarriorColorTheme tColors =
        Theme.of(context).extension<TaskwarriorColorTheme>()!;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: iconColor,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: TaskWarriorFonts.fontSizeMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        splashColor: tColors.primaryTextColor!.withOpacity(0.1),
        hoverColor: tColors.primaryTextColor!.withOpacity(0.05),
      ),
    );
  }
}
