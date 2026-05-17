import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


import 'package:alma_diary/features/profile/presentation/widgets/profile_header.dart';
import 'package:alma_diary/features/profile/presentation/widgets/profile_journey_card.dart';
import 'package:alma_diary/features/profile/presentation/widgets/profile_support_card.dart';

import "package:alma_diary/core/logging/log_service.dart";

import "../../settings/screen/settings_page.dart";
import 'package:alma_diary/state/auth/auth_controller.dart';


import "package:alma_diary/state/profile/profile_controller.dart";

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();

    

    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      Future.microtask(() {
        ref
            .read(profileControllerProvider.notifier)
            .init(user.id, user);
      });
    }
  }

   Future<void> _openPrivacyPolicy() async {
      try {
        await launchUrl(
          Uri.parse('https://alma-web-z.vercel.app/privacy'),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        LogService.instance.error('profile.privacy_policy_launch_failed', error: e);
      }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);

    final user = state.user;

    final name = controller.displayName;
    final email = controller.email;
    final avatar = controller.avatarUrl;

    if (state.isLoading && !state.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ProfileHeader(
            name: name,
            email: email,
            avatarUrl: avatar,
          ),

          const SizedBox(height: 16),

          ProfileJourneyCard(
            painPoint: state.profile?.painPoint.toString(),
            hopefulGoal: state.profile?.hopefulGoal.toString(),
          ),

          const SizedBox(height: 16),

          const ProfileSupportCard(),

          const SizedBox(height: 24),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ajustes generales'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(),
                ),
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

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if(context.mounted){
                  Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false );
                }
              }, 
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
            ),
          ),
        ],
      ),
    );
  }
}