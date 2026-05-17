import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? email;
  final String? avatarUrl;

  const ProfileHeader({
    super.key,
    required this.name,
    this.email,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AlmaSpacing.lg),
      decoration: BoxDecoration(
        color: AlmaColors.surface(isDark),
        borderRadius: BorderRadius.circular(AlmaRadius.lg),
      ),
      child: Row(
        children: [
       CircleAvatar(
            radius: 28,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            backgroundColor:
                AlmaColors.textPrimary(isDark).withValues(alpha: 0.2),
            child: avatarUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: AlmaTypography.h3(isDark).copyWith(
                      color: AlmaColors.textPrimary(isDark),
                    ),
                  )
                : null,
          ),

          SizedBox(width: AlmaSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AlmaTypography.h2(isDark),
                ),

                if (email != null) ...[
                  SizedBox(height: AlmaSpacing.xs),
                  Text(
                    email!,
                    style: AlmaTypography.bodySmall(isDark).copyWith(
                      color: AlmaColors.textMuted(isDark),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}