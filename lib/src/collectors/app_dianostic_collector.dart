import 'package:diagnostic_report_package/src/collectors/diagnostic_context_collector_interface.dart';
import 'package:intl/intl.dart';

class AppDiagnosticCollector implements DiagnosticContextCollector {
  final dynamic sessionRepository;
  final dynamic equipmentRepository;
  final dynamic locationGateway;

  AppDiagnosticCollector({
    required this.sessionRepository,
    required this.equipmentRepository,
    required this.locationGateway,
  });

  @override
  Future<Map<String, dynamic>> collect() async {
    final session = await sessionRepository.current();
    final equipment = await equipmentRepository.current();
    final location = await locationGateway.currentPosition();

    return {
      'cliente': {
        'id': session?.clientId,
        'nome': session?.name,
        'email': session?.email,
      },
      'equipamento': {
        'serialNumber': equipment?.serialNumber,
        'connectionState': equipment?.connectionState,
      },
      'location': {
        'available': location != null,
        if (location != null) ...location.toJson(),
        'data': DateFormat('dd/MM/yyyy').format(DateTime.now()),
        'hora': DateFormat('HH:mm:ss').format(DateTime.now()),
      },
    };
  }
}