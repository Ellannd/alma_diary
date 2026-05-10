sealed class SearchAction {
  const SearchAction();
}

/// Abrir entrada de diario
class OpenJournalAction extends SearchAction {
  final Map<String, dynamic> entry;
  const OpenJournalAction(this.entry);
}

/// Abrir reflexión
class OpenReflectionAction extends SearchAction {
  final Map<String, dynamic> entry;
  const OpenReflectionAction(this.entry);
}

/// Abrir challenge
class OpenChallengeAction extends SearchAction {
  final Map<String, dynamic> entry;
  const OpenChallengeAction(this.entry);
}

/// Ver cita / quote
class OpenQuoteAction extends SearchAction {
  final Map<String, dynamic> entry;
  const OpenQuoteAction(this.entry);
}