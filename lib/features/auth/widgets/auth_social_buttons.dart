import 'package:alma_diary/design_system/components/feedback/alma_loader.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';

class AuthSocialButtons extends StatelessWidget {
  final bool loading;
  final VoidCallback? onGoogle;
  final VoidCallback? onFacebook;
  final VoidCallback? onApple;

  const AuthSocialButtons({
    super.key,
    this.loading = false,
    this.onGoogle,
    this.onFacebook,
    this.onApple,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        _SocialButton(
          icon: FontAwesomeIcons.google,
          color: const Color(0xFFEA4335),
          label: 'Google',
          loading: loading,
          onPressed: onGoogle,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _SocialButton(
          icon: FontAwesomeIcons.facebook,
          color: const Color(0xFF1877F2),
          label: 'Facebook',
          loading: loading,
          onPressed: onFacebook,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _SocialButton(
          icon: FontAwesomeIcons.apple,
          color: isDark ? Colors.white : Colors.black,
          label: 'Apple',
          loading: loading,
          onPressed: onApple,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final FaIconData icon;
  final Color color;
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final bool isDark;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.loading,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AlmaColors.surfaceVariant(isDark),
            foregroundColor: AlmaColors.textPrimary(isDark),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AlmaRadius.button),
              side: BorderSide(
                color: AlmaColors.border(isDark).withValues(alpha: .1),
              ),
            ),
          ),
          child: loading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: AlmaLoader(
                    color: AlmaColors.textMuted(isDark),
                  ),
                )
              : FaIcon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
