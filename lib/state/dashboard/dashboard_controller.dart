import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/state/dashboard/dashboard_state.dart';
import 'package:alma_diary/services/supabase_service.dart';
import "package:alma_diary/state/notifications/notifications_controller.dart";
import 'package:alma_diary/services/fcm_listener_service.dart';

final dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(
  DashboardController.new,
);

class DashboardController extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    _loadUser();
    _setupRouter();
    return DashboardState.initial();
  }

  // =========================
  // INIT USER
  // =========================
  Future<void> _loadUser() async {
    final user = SupabaseService.instance.client.auth.currentUser;

    if (user == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final profile = await SupabaseService.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    state = state.copyWith(
      userId: user.id,
      archetype: profile?['archetype'] ?? 'The Self',
      painNodes: List<String>.from(profile?['pain_nodes'] ?? []),
      profile: profile,
      isLoading: false,
    );

    _initBackgroundServices(user.id);
  }

  // =========================
  // NAVIGATION STATE
  // =========================
  void setTab(int index) {
    state = state.copyWith(currentIndex: index);
  }

  // =========================
  // ROUTER CONNECTION
  // =========================
  void _setupRouter() {
    // si luego migras a router central, aquí conectas
    // ahora lo dejamos desacoplado
  }

  // =========================
  // BACKGROUND SERVICES
  // =========================
  void _initBackgroundServices(String userId) {
    Future.microtask(() async {
      try {
        final notification = NotificationController();

        notification.setUserId(userId);
        await notification.load();

        await FcmService.instance.registerDevice(userId);
      } catch (_) {}
    });
  }

  // =========================
  // RESET
  // =========================
  void reset() {
    state = DashboardState.initial();
  }
}