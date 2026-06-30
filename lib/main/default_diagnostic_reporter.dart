import 'dart:convert';
import 'package:diagnostic_report_package/main/diagnostic_reporter.dart';
import 'package:diagnostic_report_package/src/collectors/diagnostic_context_collector_interface.dart';
import 'package:diagnostic_report_package/src/config/diagnostic_category.dart';
import 'package:diagnostic_report_package/src/config/diagnostic_level.dart';
import 'package:diagnostic_report_package/src/repository/events_repository.dart';
import 'package:diagnostic_report_package/src/services/diagnostic_connectivity.dart';
import 'package:diagnostic_report_package/src/services/diagnostic_event.dart';
import 'package:diagnostic_report_package/src/services/diagnostic_report.dart';
import 'package:diagnostic_report_package/src/services/diagnostic_submission_result.dart';
import 'package:diagnostic_report_package/src/services/diagnostic_transport.dart';
import 'package:diagnostic_report_package/src/storage/diagnostic_report_store.dart';
import 'package:uuid/uuid.dart';

class DefaultDiagnosticReporter implements DiagnosticReporter {
  final DiagnosticContextCollector collector;
  final DiagnosticDeviceInfo deviceInfo;
  final DiagnosticEventRepository eventRepository;
  final DiagnosticConnectivity connectivity;
  final DiagnosticTransport transport;
  final DiagnosticReportStore reportStore;
  final List<DiagnosticReport> _capturedReports = [];
  static const _uuid = Uuid();

  DefaultDiagnosticReporter({
    required this.collector,
    required this.deviceInfo,
    required this.connectivity,
    required this.transport,
    required this.reportStore,
    DiagnosticEventRepository? eventRepository,
  }) : eventRepository = eventRepository ?? InMemoryDiagnosticEventRepository();

  @override
  DiagnosticEvent recordEvent({
    required DiagnosticCategory category,
    required DiagnosticLevel level,
    required String message,
    Map<String, dynamic> metadata = const {},
    String? incidentId,
  }) {
    final event = DiagnosticEvent(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      level: level,
      category: category,
      message: message,
      metadata: metadata,
      incidentId: incidentId,
    );
    eventRepository.add(event);
    return event;
  }

  @override
  Future<DiagnosticReport> captureError(
    Object error,
    StackTrace? stackTrace, {
    String? displayedCode,
    DiagnosticLevel severity = DiagnosticLevel.error,
    bool isFatal = false,
    Map<String, dynamic> domainContext = const {},
  }) async {
    final contextData = await collector.collect();
    final report = DiagnosticReport(
      incidentId: _uuid.v4(),
      createdAt: DateTime.now(),
      deviceInfo: deviceInfo,
      error: DianosticErrorInfo(
        message: error.toString(),
        diplayedCode: displayedCode ?? 'ERR',
        stackTrace: stackTrace?.toString() ?? '',
        isFatal: isFatal,
      ),
      context: contextData,
      lastEvents: eventRepository.getEvents(),
    );
    _capturedReports.add(report);
    if (_capturedReports.length > 10) {
      _capturedReports.removeAt(0); // Mantém apenas os últimos 10 relatórios em memória
    }
    return report;
  }

  @override
  Future<DiagnosticSubmissionResult> submit(DiagnosticReport report) async {
    final isOnline = await connectivity.isOnline;
    if (!isOnline) {
      final existing = await reportStore.load();
      await reportStore.save([...existing, report]);
      return DiagnosticSubmissionResult.offline(report.incidentId);
    }

    try {
      final jsonString = jsonEncode(report.toJson());
      final base64Content = base64Encode(utf8.encode(jsonString));

      final envelope = DiagnosticSubmissionEnvelope(
        incidentId: report.incidentId,
        schemaName: 'diagnostic_report',
        schemaVersion: 1,
        encoding: 'base64',
        base64Content: base64Content,
      );

      final response = await transport.send(envelope);

      if (response.accepted) {
        return DiagnosticSubmissionResult.success(
          report.incidentId,
          remoteId: response.remoteId,
        );
      } else {
        // timeout, salva offline
        if (response.statusCode == 408) {
          final existing = await reportStore.load();
          await reportStore.save([...existing, report]);
          return DiagnosticSubmissionResult.timeout(report.incidentId);
        }
        return DiagnosticSubmissionResult.failure(
          report.incidentId,
          message: response.message,
        );
      }
    } catch (e) {
      final existing = await reportStore.load();
      await reportStore.save([...existing, report]);
      return DiagnosticSubmissionResult.failure(
        report.incidentId,
        message: e.toString(),
      );
    }
  }

  @override
  List<DiagnosticReport> get recentReports => List.unmodifiable(_capturedReports);

  @override
  DiagnosticReport? get latestReport => _capturedReports.isEmpty ? null : _capturedReports.last;
}