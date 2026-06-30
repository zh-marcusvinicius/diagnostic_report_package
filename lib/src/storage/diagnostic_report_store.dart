import 'package:diagnostic_report_package/src/services/diagnostic_report.dart';

abstract interface class DiagnosticReportStore {
  Future<List<DiagnosticReport>> load();
  Future<void> save(List<DiagnosticReport> reports);
  Future<void> clear();
}