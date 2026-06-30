enum DiagnosticLevel {
  debug,
  info,
  warning,
  error,
  critical;

  bool get isFatal => this == error || this == critical;
}
