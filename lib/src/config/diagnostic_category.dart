/// Classifica a origem ou domínio de um evento ou erro de diagnóstico.
///
/// O pacote expõe constantes para as categorias mais comuns. Para categorias
/// específicas do seu app, crie novas instâncias diretamente:
///
/// ```dart
/// static const ble = DiagnosticCategory(name: 'ble');
/// static const ebs = DiagnosticCategory(name: 'ebs');
/// ```
class DiagnosticCategory {
  final String name;

  const DiagnosticCategory({required this.name});

  // Genéricas — comuns a qualquer aplicação
  const DiagnosticCategory.unknown() : name = 'unknown';
  const DiagnosticCategory.network() : name = 'network';
  const DiagnosticCategory.database() : name = 'database';
  const DiagnosticCategory.ui() : name = 'ui';
  const DiagnosticCategory.business() : name = 'business';

  // Ciclo de vida do app
  const DiagnosticCategory.startup() : name = 'startup';
  const DiagnosticCategory.auth() : name = 'auth';
  const DiagnosticCategory.navigation() : name = 'navigation';
  const DiagnosticCategory.storage() : name = 'storage';

  // Hardware / conectividade de baixo nível
  const DiagnosticCategory.hardware() : name = 'hardware';
  const DiagnosticCategory.ble() : name = 'ble';

  // Dados / sincronismo
  const DiagnosticCategory.sync() : name = 'sync';

  // O próprio sistema de diagnóstico
  const DiagnosticCategory.diagnostics() : name = 'diagnostics';

  /// Cria uma categoria a partir de uma string arbitrária.
  /// Útil para desserialização ou categorias definidas em tempo de execução.
  factory DiagnosticCategory.fromString(String value) =>
      DiagnosticCategory(name: value.isEmpty ? 'unknown' : value);

  @override
  bool operator ==(Object other) =>
      other is DiagnosticCategory && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'DiagnosticCategory($name)';
}
