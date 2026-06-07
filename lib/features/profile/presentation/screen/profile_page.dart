import 'package:alma_diary/design_system/components/feedback/alma_loader.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/features/psych_profile/widgets/psych_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:alma_diary/features/profile/presentation/widgets/profile_header.dart';
import 'package:alma_diary/features/profile/presentation/widgets/profile_journey_card.dart';
import 'package:alma_diary/features/profile/presentation/widgets/profile_support_card.dart';

import "package:alma_diary/core/logging/log_service.dart";

import "../../settings/screen/settings_page.dart";

import "package:alma_diary/state/profile/profile_controller.dart";

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Future<void> _openPrivacyPolicy() async {
    try {
      await launchUrl(
        Uri.parse('https://alma-web-z.vercel.app/privacy'),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      LogService.instance.error(
        'profile.privacy_policy_launch_failed',
        error: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);

    final name =
        ref.watch(
          profileControllerProvider.select((s) => s.value?.displayName),
        ) ??
        'Usuario';
    final email =
        ref.watch(profileControllerProvider.select((s) => s.value?.email)) ??
        '';
    final avatar = ref.watch(
      profileControllerProvider.select((s) => s.value?.avatarUrl),
    );

    if (state.isLoading) {
      return const Scaffold(body: Center(child: AlmaLoader()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ProfileHeader(name: name, email: email, avatarUrl: avatar),

          SizedBox(height: AlmaSpacing.r(context, 16)),

          ProfileJourneyCard(
            painPoint: state.value?.painPoint?.toString().split(".").last,
            hopefulGoal: state.value?.hopefulGoal?.toString().split(".").last,
          ),

          SizedBox(height: AlmaSpacing.r(context, 16)),

          const PsychProfileCard(),

          SizedBox(height: 16),

          const ProfileSupportCard(),

          SizedBox(height: AlmaSpacing.r(context, 24)),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ajustes generales'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacidad y datos'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _openPrivacyPolicy();
            },
          ),
        ],
      ),
    );
  }
}
