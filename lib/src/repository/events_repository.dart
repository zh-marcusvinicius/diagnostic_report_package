import 'package:diagnostic_report_package/src/services/diagnostic_event.dart';

abstract interface class DiagnosticEventRepository {
  void add(DiagnosticEvent event);
  List<DiagnosticEvent> getEvents();
  void clear();
}

class InMemoryDiagnosticEventRepository implements DiagnosticEventRepository {
  final int maxCapacity;
  final List<DiagnosticEvent> _events = [];

  InMemoryDiagnosticEventRepository({this.maxCapacity = 100});

  @override
  void add(DiagnosticEvent event) {
    if (_events.length >= maxCapacity) {
      _events.removeAt(0);
    }
    _events.add(event);
  }

  @override
  List<DiagnosticEvent> getEvents() {
    return List.unmodifiable(_events);
  }

  @override
  void clear() {
    _events.clear();
  }
}
