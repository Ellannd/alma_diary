// widgets/notification_card.dart

import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:alma_diary/models/alma_notification.dart';

import '../utils/notification_icon_mapper.dart';
import '../utils/notification_color_mapper.dart';

import 'notification_action_button.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class NotificationCard
    extends StatelessWidget {
  final AlmaNotification notification;

  final VoidCallback? onTap;
  final VoidCallback? onAction;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final color =
        NotificationColorMapper.fromKey(
      notification.color,
      isDark,
    );

    final icon =
        NotificationIconMapper.fromKey(
      notification.icon,
    );

    return AnimatedOpacity(
      duration: const Duration(
        milliseconds: 220,
      ),
      opacity:
          notification.isRead ? .45 : 1,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: AlmaSpacing.md,
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(
            AlmaRadius.xl,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 8,
              sigmaY: 8,
            ),
            child: Material(
              color:
                  AlmaColors.surface(
                isDark,
              ).withValues(alpha: .65),

              borderRadius:
                  BorderRadius.circular(
                AlmaRadius.xl,
              ),

              child: InkWell(
                onTap: onTap,
                borderRadius:
                    BorderRadius.circular(
                  AlmaRadius.xl,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.all(
                    AlmaSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      AlmaRadius.xl,
                    ),

                    border: Border.all(
                      color:
                          AlmaColors.border(
                        isDark,
                      ),
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,
                          color:
                              color.withValues(
                            alpha: .14,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                        ),
                      ),

                      const SizedBox(
                        width:
                            AlmaSpacing.md,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              notification.title,
                              style:
                                  AlmaTypography
                                      .bodyLarge(
                                isDark,
                              ).copyWith(
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),

                            const SizedBox(
                              height:
                                  AlmaSpacing
                                      .xs,
                            ),

                            Text(
                              notification
                                  .subtitle,
                              style:
                                  AlmaTypography
                                      .bodyMedium(
                                isDark,
                              ).copyWith(
                                color:
                                    AlmaColors
                                        .textSecondary(
                                  isDark,
                                ),
                                height:
                                    1.45,
                              ),
                            ),

                            const SizedBox(
                              height:
                                  AlmaSpacing
                                      .md,
                            ),

                            NotificationActionButton(
                              label:
                                  notification
                                      .action,
                              onTap:
                                  onAction ??
                                      () {},
                              color: color,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}