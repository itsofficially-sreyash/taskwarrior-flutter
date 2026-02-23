import 'package:flutter/material.dart';
import 'package:taskwarrior/app/models/json/task.dart';
import 'package:taskwarrior/app/utils/constants/taskwarrior_fonts.dart';
import 'package:taskwarrior/app/utils/gen/fonts.gen.dart';
import 'package:taskwarrior/app/utils/language/sentence_manager.dart';
import 'package:taskwarrior/app/utils/language/supported_language.dart';
import 'package:taskwarrior/app/utils/taskfunctions/datetime_differences.dart';
import 'package:taskwarrior/app/utils/taskfunctions/modify.dart';
import 'package:taskwarrior/app/utils/taskfunctions/urgency.dart';
import 'package:taskwarrior/app/utils/themes/theme_extension.dart';
import 'package:taskwarrior/app/utils/priority/priority.dart';
import 'package:taskwarrior/app/widgets/pill.dart';

class TaskListItem extends StatelessWidget {
  const TaskListItem(
    this.task, {
    this.pendingFilter = false,
    this.waitingFilter = false,
    super.key,
    required this.useDelayTask,
    required this.modify,
    required this.selectedLanguage,
  });

  final Task task;
  final bool pendingFilter;
  final bool waitingFilter;
  final Modify modify;
  final bool useDelayTask;
  final SupportedLanguage selectedLanguage;

  // ── Due state helpers ──────────────────────────────────────────────────────

  bool _isDueWithinOneDay(DateTime due) {
    final diff = due.difference(DateTime.now());
    return diff.inDays < 1 && diff.inMicroseconds > 0;
  }

  bool _isOverdue(DateTime due) =>
      due.difference(DateTime.now()).inMicroseconds < 0;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tColors = Theme.of(context).extension<TaskwarriorColorTheme>()!;

    final bool isPending = task.status[0].toUpperCase() == 'P';
    final p = getPriorityStyle(task.priority);
    final sentences =
        SentenceManager(currentLanguage: selectedLanguage).sentences;

    final Color textColor = tColors.primaryTextColor!;
    final Color subColor = tColors.dimCol!;

    // Due urgency states
    final bool overdue =
        task.due != null && _isOverdue(task.due!) && useDelayTask;
    final bool dueSoon =
        task.due != null && _isDueWithinOneDay(task.due!) && useDelayTask;

    // Left accent bar: priority color, overridden by due urgency
    Color accentColor = p.accent;
    if (dueSoon && !overdue) accentColor = const Color(0xFFFFA726);
    if (overdue) accentColor = const Color(0xFFEF5350);

    // Subtle card tint when overdue
    final Color cardBg = overdue
        ? const Color(0xFFEF5350).withOpacity(0.05)
        : tColors.primaryBackgroundColor!;

    // Urgency score → color ramp
    final double urgencyVal = urgency(task);
    Color urgencyColor;
    if (urgencyVal >= 10) {
      urgencyColor = const Color(0xFFEF5350);
    } else if (urgencyVal >= 5) {
      urgencyColor = const Color(0xFFFFA726);
    } else {
      urgencyColor = subColor.withOpacity(0.7);
    }

    // Metadata strings
    final String modifiedStr = task.modified != null
        ? age(task.modified!)
        : (task.start != null ? age(task.start!) : '-');
    final String dueStr = task.due != null ? when(task.due!) : '-';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: overdue
              ? const Color(0xFFEF5350).withOpacity(0.3)
              : dueSoon
                  ? const Color(0xFFFFA726).withOpacity(0.3)
                  : subColor.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: accentColor.withOpacity(0.06),
          highlightColor: accentColor.withOpacity(0.04),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Left accent bar ──────────────────────────────────────
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),

                // ── Card content ─────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Row 1: Task ID + description + annotation count
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ID badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '#${task.id == 0 ? '-' : task.id}',
                                style: TextStyle(
                                  fontFamily: FontFamily.poppins,
                                  fontSize: 10,
                                  fontWeight: TaskWarriorFonts.semiBold,
                                  color: accentColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Description
                            Expanded(
                              child: Text(
                                task.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: FontFamily.poppins,
                                  fontSize: 13.5,
                                  fontWeight: isPending
                                      ? TaskWarriorFonts.medium
                                      : TaskWarriorFonts.regular,
                                  color: isPending
                                      ? textColor
                                      : textColor.withOpacity(0.45),
                                  decoration: isPending
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough,
                                  decorationColor: subColor.withOpacity(0.4),
                                  height: 1.35,
                                ),
                              ),
                            ),

                            // Annotation count
                            if (task.annotations != null &&
                                task.annotations!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Pill(
                                label: '${task.annotations!.length}',
                                bg: subColor.withOpacity(0.1),
                                fg: subColor,
                                icon: Icons.comment_outlined,
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 8),

                        // ── Row 2: Priority pill + due badge + urgency score
                        Row(
                          children: [
                            Pill(
                              label: p.label,
                              bg: p.chipBg,
                              fg: p.chipFg,
                            ),
                            const SizedBox(width: 6),

                            if (overdue)
                              Pill(
                                label: 'Overdue',
                                bg: const Color(0x15EF5350),
                                fg: const Color(0xFFEF5350),
                                icon: Icons.warning_amber_rounded,
                              )
                            else if (dueSoon)
                              Pill(
                                label: 'Due soon',
                                bg: const Color(0x15FFA726),
                                fg: const Color(0xFFFFA726),
                                icon: Icons.schedule_rounded,
                              ),

                            const Spacer(),

                            // Urgency value
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  formatUrgency(urgencyVal),
                                  style: TextStyle(
                                    fontFamily: FontFamily.poppins,
                                    fontSize: 11,
                                    fontWeight: TaskWarriorFonts.semiBold,
                                    color: Colors.white,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        // ── Row 3: Modified + Due metadata ────────────────
                        Row(
                          children: [
                            // Modified
                            Icon(
                              Icons.edit_outlined,
                              size: 11,
                              color: subColor.withOpacity(0.5),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                modifiedStr,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: FontFamily.poppins,
                                  fontSize: TaskWarriorFonts.fontSizeSmall,
                                  color: subColor.withOpacity(0.6),
                                ),
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              child: Text(
                                '·',
                                style: TextStyle(
                                  fontFamily: FontFamily.poppins,
                                  color: subColor.withOpacity(0.25),
                                  fontSize: 13,
                                ),
                              ),
                            ),

                            // Due
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: overdue
                                  ? const Color(0xFFEF5350).withOpacity(0.6)
                                  : subColor.withOpacity(0.5),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                dueStr,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: FontFamily.poppins,
                                  fontSize: TaskWarriorFonts.fontSizeSmall,
                                  color: overdue
                                      ? const Color(0xFFEF5350)
                                          .withOpacity(0.75)
                                      : subColor.withOpacity(0.6),
                                ),
                              ),
                            ),

                            // Status badge — shown for completed/waiting tasks
                            if (!pendingFilter && !isPending) ...[
                              const Spacer(),
                              Pill(
                                label: task.status[0].toUpperCase() +
                                    task.status.substring(1).toLowerCase(),
                                bg: subColor.withOpacity(0.08),
                                fg: subColor.withOpacity(0.55),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
