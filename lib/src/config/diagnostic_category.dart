class DiagnosticCategory {
  final String name;

  const DiagnosticCategory({required this.name});

  const DiagnosticCategory.unknown() : name = 'unknown';
  const DiagnosticCategory.network() : name = 'network';
  const DiagnosticCategory.database() : name = 'database';
  const DiagnosticCategory.ui() : name = 'ui';
  const DiagnosticCategory.business() : name = 'business';
}