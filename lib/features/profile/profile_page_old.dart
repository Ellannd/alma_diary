import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/features/notifications/controller/notifications_settings_controller.dart';
import 'package:alma_diary/features/profile/domain/profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alma_diary/features/dashboard/alma_theme.dart';
import 'package:alma_diary/features/profile/settings_page_old.dart';
import "package:alma_diary/core/theme/theme_controller.dart";
import "package:alma_diary/features/profile/controller/profile_controller.dart";
import "package:alma_diary/features/profile/data/profile_repository.dart";
import "package:alma_diary/features/auth/auth_controller.dart";
import "package:alma_diary/features/auth/data/auth_repository.dart";


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  SharedPreferences? _prefs;
  late TextEditingController _apiKeyController;
  bool _darkMode = true;
  bool _loading = true;
  late final ProfileController _controller;
  late final AuthController _authController;

  Profile? _profile;

  @override
  void initState() {
    super.initState();

    _apiKeyController = TextEditingController();

    _controller = ProfileController(ProfileRepository());

    _authController = AuthController(AuthRepository());

    _loadData();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    _apiKeyController.text = _prefs?.getString('gemini_api_key') ?? '';

    final savedTheme = _prefs?.getBool('dark_mode') ?? true;

    
    ThemeController.setTheme(savedTheme); // ACTUALIZA EL CONTROLADOR GLOBAL

    _darkMode = savedTheme;

    try{
      _profile = await _controller.loadProfile(
        Supabase.instance.client.auth.currentUser!.id,
      );
    } catch (e) {
      LogService.instance.error('profile.load.failed', error: e);
    }

    if (mounted) {
      setState(() => _loading = false);
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

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _darkMode = value);

    await _prefs?.setBool('dark_mode', value);

    // ACTUALIZA TODA LA APP EN VIVO
    ThemeController.setTheme(value);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tema actualizado')));
    }
  }

  Future<void> _logout() async {
    try{
      await _authController.logout();
      }catch (e) {
        LogService.instance.error('profile.logout_failed', error: e);
        
        }
      
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  String _getEmotionalEmoji(String? state) {
    switch (state) {
      case 'abrumado':
        return '🌊';
      case 'nublado':
        return '🌫️';
      case 'agotado':
        return '🔋';
      case 'inspirado':
        return '🌱';
      default:
        return '🌿';
    }
  }

  String _formatGoal(String? goal) {
    switch (goal) {
      case 'paz':
        return 'Paz mental';
      case 'orden':
        return 'Orden y claridad';
      case 'companero':
        return 'Compañía emocional';
      default:
        return 'Crecimiento personal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'Usuario';
    final avatarUrl = user?.userMetadata?['avatar_url'];
    final authController = AuthController(AuthRepository());

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 👤 HEADER PROFILE
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          backgroundImage: avatarUrl != null
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                )
                              : null,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (_profile?['emotional_state'] != null)
                                Row(
                                  children: [
                                    Text(
                                      _getEmotionalEmoji(
                                        _profile?['emotional_state'],
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Meta: ${_formatGoal(_profile?['hopeful_goal'])}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // USER JOURNEY
                if (_profile?['pain_point'] != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.insights, color: AlmaTheme.accent),
                              SizedBox(width: 12),
                              Text(
                                'Tu viaje',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Actualmente trabajas en: ${_profile!['pain_point'].toString().replaceAll('_', ' ')}',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // THEME
                SwitchListTile(
                  title: Text(
                    'Modo oscuro',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Cambia el tema de la app',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  value: _darkMode,
                  onChanged: _toggleDarkMode,
                  secondary: Icon(
                    Icons.dark_mode,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  activeThumbColor: AlmaTheme.accent,
                ),

                const SizedBox(height: 12),

                // SUPPORT
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: AlmaTheme.accent),
                            SizedBox(width: 12),
                            Text(
                              'Motor de Alma',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Alma utiliza un sistema de IA seguro gestionado por la plataforma para ofrecerte soporte emocional personalizado.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // SETTINGS
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text(
                    'Ajustes generales',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).cardColor,
                    size: 16,
                  ),
                 onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsPage(
                          controller: authController, profileController: ProfileController(ProfileRepository()), notificationController: NotificationSettingsController(),
                        ),
                      ),
                    );
                    },
                ),
                ListTile(
                  leading: Icon(
                    Icons.privacy_tip,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text(
                    'Privacidad y datos',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).cardColor,
                    size: 16,
                  ),
                  onTap: _openPrivacyPolicy,
                ),

                const SizedBox(height: 32),

                // 🚪 LOGOUT
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
