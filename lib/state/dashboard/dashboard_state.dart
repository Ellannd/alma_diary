import 'package:equatable/equatable.dart';

class DashboardState extends Equatable {
  final String? userId;
  final bool isLoading;

  final int currentIndex;

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
    this.currentIndex = 0,
    this.archetype = 'The Self',
    this.painNodes = const [],
    this.profile,

    this.mood = 'Neutral',
    this.moodTitle = 'Tu estado hoy',
    this.moodSubtitle = 'Explora cómo te sientes hoy',
    this.moodIconKey = "self_improvement",

    this.quoteText = "No eres lo que te pasó, eres lo que decides ser.",
    this.quoteSource = "Alma"
  });

  factory DashboardState.initial() {
    return DashboardState();
  }

  DashboardState copyWith({
    String? userId,
    bool? isLoading,
    int? currentIndex,
    String? archetype,
    List<String>? painNodes,
    Map<String, dynamic>? profile,
    String? mood,
    String? moodTitle,
    String? moodSubtitle,
    String? moodIconkey,
    String? quoteText,
    String? quoteSource
  }) {
    return DashboardState(
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      currentIndex: currentIndex ?? this.currentIndex,
      archetype: archetype ?? this.archetype,
      painNodes: painNodes ?? this.painNodes,
      profile: profile ?? this.profile,

      mood: mood ?? this.mood,
      moodTitle: moodTitle ?? this.moodTitle,
      moodSubtitle: moodSubtitle ?? this.moodSubtitle,
      moodIconKey: moodIconKey,

      quoteText: quoteText ?? this.quoteText,
      quoteSource: quoteSource ?? this.quoteSource,
      
    );
  }

  @override
  List<Object?> get props => [
        userId,
        isLoading,
        currentIndex,
        archetype,
        painNodes,
        profile,
        mood,
        moodTitle,
        moodSubtitle,
        moodIconKey,
        quoteText,
        quoteSource
      ];
}