class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult(this.isValid, [this.error]);

  factory ValidationResult.ok() => const ValidationResult(true);

  factory ValidationResult.fail(String message) =>
      ValidationResult(false, message);
}