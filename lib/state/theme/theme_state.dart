class ThemeState {
  final bool isDarkMode;

  const ThemeState({
    this.isDarkMode = true,
  });

  ThemeState copyWith({
    bool? isDarkMode,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}