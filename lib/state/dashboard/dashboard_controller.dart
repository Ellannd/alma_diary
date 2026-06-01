import 'package:alma_diary/state/profile/profile_controller.dart';
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

    final profile = await ref.read(profileControllerProvider.future);

    state = state.copyWith(
    userId: user.id,
    archetype: profile?.archetype?.displayName ?? 'The Self',
    painNodes: profile?.painNodes ?? [],
    isLoading: false,
  );

    _initBackgroundServices(user.id);
  }

  // =========================
  // NAVIGATION STATE
  // =========================
  void setTab(NavbarTab tab) {
    if (state.navCurrentTab == tab) return;

      state = state.copyWith(
        navCurrentTab: tab,
      );
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
      await ref.read(notificationControllerProvider.notifier)
          .handlePostLogin(userId); 
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