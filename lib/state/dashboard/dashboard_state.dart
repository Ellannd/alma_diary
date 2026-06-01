import 'package:equatable/equatable.dart';
import 'package:alma_diary/core/navigation/app_routes.dart';

class DashboardState extends Equatable {
  final String? userId;
  final bool isLoading;

  final NavbarTab navCurrentTab;

  final String archetype;
  final List<String> painNodes;

  final Map<String, dynamic>? profile;

  // =========================
  // EMOTIONAL LAYER
  // =========================
  final String mood;
  final String moodTitle;
  final String moodSubtitle;
  final String moodIconKey;

  // ========================
  //  DASHBOARD QUOTE
  // ========================
  final String quoteText;
  final String quoteSource;

  const DashboardState({
    this.userId,
    this.isLoading = true,
    this.navCurrentTab = NavbarTab.dashboard,
    this.archetype = 'The Self',
    this.painNodes = const [],
    this.profile,

    this.mood = 'Neutral',
    this.moodTitle = 'Tu estado hoy',
    this.moodSubtitle = 'Explora cómo te sientes hoy',
    this.moodIconKey = "self_improvement",

    this.quoteText = "No eres lo que te pasó, eres lo que decides ser.",
    this.quoteSource = "Alma",
  });

  factory DashboardState.initial() {
    return DashboardState();
  }

  DashboardState copyWith({
    String? userId,
    bool? isLoading,
    NavbarTab? navCurrentTab,
    String? archetype,
    List<String>? painNodes,
    Map<String, dynamic>? profile,
    String? mood,
    String? moodTitle,
    String? moodSubtitle,
    String? moodIconKey,
    String? quoteText,
    String? quoteSource,
  }) {
    return DashboardState(
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      navCurrentTab: navCurrentTab ?? this.navCurrentTab,
      archetype: archetype ?? this.archetype,
      painNodes: painNodes ?? this.painNodes,
      profile: profile ?? this.profile,

      mood: mood ?? this.mood,
      moodTitle: moodTitle ?? this.moodTitle,
      moodSubtitle: moodSubtitle ?? this.moodSubtitle,
      moodIconKey: moodIconKey ?? this.moodIconKey,

      quoteText: quoteText ?? this.quoteText,
      quoteSource: quoteSource ?? this.quoteSource,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    isLoading,
    navCurrentTab,
    archetype,
    painNodes,
    profile,
    mood,
    moodTitle,
    moodSubtitle,
    moodIconKey,
    quoteText,
    quoteSource,
  ];
}

enum NavbarTab { dashboard, search, create, notifications, profile }

extension NavbarTabX on NavbarTab {
  String get route {
    switch (this) {
      case NavbarTab.dashboard:
        return AppRoutes.dashboard;

      case NavbarTab.search:
        return AppRoutes.search;

      case NavbarTab.create:
        return AppRoutes.create;

      case NavbarTab.notifications:
        return AppRoutes.notifications;

      case NavbarTab.profile:
        return AppRoutes.profile;
    }
  }
}
