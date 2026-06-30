import 'package:diagnostic_report_package/src/config/diagnostic_category.dart';
import 'package:diagnostic_report_package/src/config/diagnostic_level.dart';
import 'package:diagnostic_report_package/src/services/diagnostic_event.dart';
import 'package:diagnostic_report_package/src/services/diagnostic_report.dart';
import 'package:diagnostic_report_package/src/services/diagnostic_submission_result.dart';

abstract interface class DiagnosticReporter {
  DiagnosticEvent recordEvent({
    required DiagnosticCategory category,
    required DiagnosticLevel level,
    required String message,
    Map<String, dynamic> metadata = const {},
    String? incidentId,
    DateTime? timestamp,
  });

  Future<DiagnosticReport> captureError(
    Object error,
    StackTrace? stackTrace, {
    String? displayedCode,
    String? realErrorCode,
    String source = 'unknown',
    DiagnosticLevel severity = DiagnosticLevel.error,
    bool isFatal = false,
    bool isRecoverable = true,
    Map<String, dynamic> domainContext = const {},
  });

  Future<DiagnosticSubmissionResult> submit(DiagnosticReport report);

  List<DiagnosticReport> get recentReports;
  DiagnosticReport? get latestReport;
}
