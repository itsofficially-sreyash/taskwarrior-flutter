import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskwarrior/app/modules/reports/views/reports_view_replica.dart';
import 'package:taskwarrior/app/utils/app_settings/app_settings.dart';
import 'package:taskwarrior/app/modules/home/controllers/home_controller.dart';
import 'package:taskwarrior/app/modules/home/views/theme_clipper.dart';
import 'package:taskwarrior/app/modules/reports/views/reports_view_taskc.dart';
import 'package:taskwarrior/app/routes/app_pages.dart';
import 'package:taskwarrior/app/utils/constants/constants.dart';
import 'package:taskwarrior/app/utils/constants/taskwarrior_fonts.dart';
import 'package:taskwarrior/app/utils/constants/utilites.dart';
import 'package:taskwarrior/app/utils/gen/assets.gen.dart';
import 'package:taskwarrior/app/utils/language/sentence_manager.dart';
import 'package:taskwarrior/app/utils/themes/theme_extension.dart';
import 'package:taskwarrior/app/utils/themes/dark_theme.dart';
import 'package:taskwarrior/app/utils/themes/light_theme.dart';

/// A smooth animated moon/sun theme toggle slider.
class _ThemeToggleSlider extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  const _ThemeToggleSlider({
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tColors = Theme.of(context).extension<TaskwarriorColorTheme>()!;

    // Track background: dark = deep navy, light = pale amber
    final trackColor = isDarkMode
        ? const Color(0xFF1E2340)
        : const Color(0xFFFFF3CC);

    // Thumb color: dark = soft indigo, light = warm amber
    final thumbColor = isDarkMode
        ? const Color(0xFF7C83FD)
        : const Color(0xFFFFA726);

    const double trackW = 56;
    const double trackH = 28;
    const double thumbD = 22;
    const double padding = 3;

    return GestureDetector(
      onTap: () => onChanged(!isDarkMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: trackW,
        height: trackH,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(trackH / 2),
          border: Border.all(
            color: isDarkMode
                ? const Color(0xFF3A3F6A)
                : const Color(0xFFFFD54F),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Sun icon (right side)
            Positioned(
              right: padding + 1,
              child: AnimatedOpacity(
                opacity: isDarkMode ? 0.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.wb_sunny_rounded,
                  size: 14,
                  color: const Color(0xFFFFA726),
                ),
              ),
            ),
            // Moon icon (left side)
            Positioned(
              left: padding + 1,
              child: AnimatedOpacity(
                opacity: isDarkMode ? 0.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.nightlight_round,
                  size: 14,
                  color: const Color(0xFF7C83FD),
                ),
              ),
            ),
            // Animated thumb with icon
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: isDarkMode
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: padding),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: thumbD,
                  height: thumbD,
                  decoration: BoxDecoration(
                    color: thumbColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: thumbColor.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      isDarkMode
                          ? Icons.nightlight_round
                          : Icons.wb_sunny_rounded,
                      key: ValueKey(isDarkMode),
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single nav item — flat, no card shadow, just clean tap feedback.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool isDestructive;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final tColors = Theme.of(context).extension<TaskwarriorColorTheme>()!;
    final resolvedIconColor = iconColor ??
        (isDestructive ? TaskWarriorColors.red : tColors.primaryTextColor);
    final resolvedTextColor = textColor ??
        (isDestructive ? TaskWarriorColors.red : tColors.primaryTextColor);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: resolvedIconColor!.withOpacity(0.08),
        highlightColor: resolvedIconColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              Icon(icon, size: 20, color: resolvedIconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: TaskWarriorFonts.medium,
                    color: resolvedTextColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              if (!isDestructive)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: tColors.primaryDisabledTextColor?.withOpacity(0.4),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavDrawer extends StatelessWidget {
  final HomeController homeController;
  const NavDrawer({super.key, required this.homeController});

  @override
  Widget build(BuildContext context) {
    final tColors = Theme.of(context).extension<TaskwarriorColorTheme>()!;

    return Drawer(
      backgroundColor: tColors.dialogBackgroundColor,
      surfaceTintColor: tColors.dialogBackgroundColor,
      elevation: 0,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo row + theme toggle
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Assets.svg.logo.svg(height: 40, width: 40),
                      const Spacer(),
                      // Moon/Sun slider toggle
                      _ThemeToggleSlider(
                        isDarkMode: AppSettings.isDarkMode,
                        onChanged: (bool newMode) async {
                          Get.changeThemeMode(
                              newMode ? ThemeMode.dark : ThemeMode.light);
                          AppSettings.isDarkMode = newMode;
                          await SelectedTheme.saveMode(AppSettings.isDarkMode);
                          homeController.initLanguageAndDarkMode();
                          Get.changeTheme(
                              AppSettings.isDarkMode ? darkTheme : lightTheme);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Obx(() => Text(
                        SentenceManager(
                                currentLanguage:
                                    homeController.selectedLanguage.value)
                            .sentences
                            .homePageMenu,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: TaskWarriorFonts.bold,
                          color: tColors.primaryTextColor,
                          letterSpacing: -0.3,
                          height: 1.1,
                        ),
                      )),
                  const SizedBox(height: 4),
                  // Subtle tagline / app name
                  Text(
                    'Taskwarrior',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: TaskWarriorFonts.regular,
                      color: tColors.primaryDisabledTextColor?.withOpacity(0.5),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Thin separator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: tColors.primaryTextColor!.withOpacity(0.07),
                height: 1,
                thickness: 1,
              ),
            ),

            // ── Nav Items ────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                children: [
                  // Profile
                  Obx(() => _NavItem(
                        icon: Icons.person_outline_rounded,
                        label: SentenceManager(
                          currentLanguage:
                              homeController.selectedLanguage.value,
                        ).sentences.navDrawerProfile,
                        onTap: () => Get.toNamed(Routes.PROFILE),
                      )),

                  // Reports — default (no sync backend)
                  Obx(() => Visibility(
                        visible: !homeController.taskchampion.value &&
                            !homeController.taskReplica.value,
                        child: _NavItem(
                          icon: Icons.bar_chart_rounded,
                          label: SentenceManager(
                            currentLanguage:
                                homeController.selectedLanguage.value,
                          ).sentences.navDrawerReports,
                          onTap: () => Get.toNamed(Routes.REPORTS),
                        ),
                      )),

                  // Reports — taskchampion
                  Obx(() => Visibility(
                        visible: homeController.taskchampion.value &&
                            !homeController.taskReplica.value,
                        child: _NavItem(
                          icon: Icons.bar_chart_rounded,
                          label: SentenceManager(
                            currentLanguage:
                                homeController.selectedLanguage.value,
                          ).sentences.navDrawerReports,
                          onTap: () => Get.to(() => ReportsHomeTaskc()),
                        ),
                      )),

                  // Reports — replica
                  Obx(() => Visibility(
                        visible: !homeController.taskchampion.value &&
                            homeController.taskReplica.value,
                        child: _NavItem(
                          icon: Icons.bar_chart_rounded,
                          label: SentenceManager(
                            currentLanguage:
                                homeController.selectedLanguage.value,
                          ).sentences.navDrawerReports,
                          onTap: () => Get.to(() => ReportsHomeReplica()),
                        ),
                      )),

                  // Section divider
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Divider(
                      color: tColors.primaryTextColor!.withOpacity(0.07),
                      height: 1,
                      thickness: 1,
                    ),
                  ),

                  // About
                  Obx(() => _NavItem(
                        icon: Icons.info_outline_rounded,
                        label: SentenceManager(
                          currentLanguage:
                              homeController.selectedLanguage.value,
                        ).sentences.navDrawerAbout,
                        onTap: () => Get.toNamed(Routes.ABOUT),
                      )),

                  // Settings
                  Obx(() => _NavItem(
                        icon: Icons.tune_rounded,
                        label: SentenceManager(
                          currentLanguage:
                              homeController.selectedLanguage.value,
                        ).sentences.navDrawerSettings,
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          homeController.syncOnStart.value =
                              prefs.getBool('sync-onStart') ?? false;
                          homeController.syncOnTaskCreate.value =
                              prefs.getBool('sync-OnTaskCreate') ?? false;
                          homeController.delaytask.value =
                              prefs.getBool('delaytask') ?? false;
                          Get.toNamed(Routes.SETTINGS);
                        },
                      )),
                ],
              ),
            ),

            // ── Footer / Exit ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              child: Column(
                children: [
                  Divider(
                    color: tColors.primaryTextColor!.withOpacity(0.07),
                    height: 1,
                    thickness: 1,
                  ),
                  const SizedBox(height: 8),
                  Obx(() => _NavItem(
                        icon: Icons.logout_rounded,
                        label: SentenceManager(
                          currentLanguage:
                              homeController.selectedLanguage.value,
                        ).sentences.navDrawerExit,
                        onTap: () => _showExitConfirmationDialog(context),
                        isDestructive: true,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    final tColors = Theme.of(context).extension<TaskwarriorColorTheme>()!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Utils.showAlertDialog(
          title: Text(
            SentenceManager(
                    currentLanguage: homeController.selectedLanguage.value)
                .sentences
                .homePageExitApp,
            style: TextStyle(color: tColors.primaryTextColor),
          ),
          content: Text(
            SentenceManager(
                    currentLanguage: homeController.selectedLanguage.value)
                .sentences
                .homePageAreYouSureYouWantToExit,
            style: TextStyle(color: tColors.primaryTextColor),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                SentenceManager(
                        currentLanguage: homeController.selectedLanguage.value)
                    .sentences
                    .homePageCancel,
                style: TextStyle(color: tColors.primaryTextColor),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                SentenceManager(
                        currentLanguage: homeController.selectedLanguage.value)
                    .sentences
                    .homePageExit,
                style: TextStyle(color: TaskWarriorColors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
            ),
          ],
        );
      },
    );
  }
}