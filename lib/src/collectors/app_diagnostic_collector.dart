import 'package:diagnostic_report_package/src/collectors/diagnostic_context_collector_interface.dart';
import 'package:intl/intl.dart';

/// Fornece dados da sessão do usuário ativo para o coletor de diagnóstico.
abstract interface class DiagnosticSessionProvider {
  Future<Map<String, dynamic>?> current();
}

/// Fornece dados do equipamento conectado para o coletor de diagnóstico.
abstract interface class DiagnosticEquipmentProvider {
  Future<Map<String, dynamic>?> current();
}

/// Fornece dados de posição/localização para o coletor de diagnóstico.
abstract interface class DiagnosticLocationProvider {
  Future<Map<String, dynamic>?> currentPosition();
}

/// Implementação concreta de [DiagnosticContextCollector] para uso no app.
///
/// Receba as dependências via interfaces tipadas — nenhuma referência direta
/// a repositórios concretos do app deve aparecer neste arquivo.
class AppDiagnosticCollector implements DiagnosticContextCollector {
  final DiagnosticSessionProvider sessionProvider;
  final DiagnosticEquipmentProvider equipmentProvider;
  final DiagnosticLocationProvider locationProvider;

  AppDiagnosticCollector({
    required this.sessionProvider,
    required this.equipmentProvider,
    required this.locationProvider,
  });

  @override
  Future<Map<String, dynamic>> collect() async {
    final session = await sessionProvider.current();
    final equipment = await equipmentProvider.current();
    final location = await locationProvider.currentPosition();

    return {
      'cliente': session ?? {},
      'equipamento': equipment ?? {},
      'location': {
        'available': location != null,
        if (location != null) ...location,
        'data': DateFormat('dd/MM/yyyy').format(DateTime.now()),
        'hora': DateFormat('HH:mm:ss').format(DateTime.now()),
      },
    };
  }
}