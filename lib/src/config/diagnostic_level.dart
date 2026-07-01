enum DiagnosticLevel {
  debug,
  info,
  warning,
  error,
  critical;

  bool get isFatal => this == error || this == critical;

  /// Retorna o [DiagnosticLevel] correspondente a uma string.
  /// Caso não encontre, retorna [DiagnosticLevel.error] por padrão.
  static DiagnosticLevel fromString(String name) {
    return DiagnosticLevel.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase(),
      orElse: () => DiagnosticLevel.error,
    );
  }
}

