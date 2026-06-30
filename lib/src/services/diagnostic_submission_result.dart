enum DiagnosticSubmissionStatus { success, offline, timeout, failure }

class DiagnosticSubmissionResult {
  final DiagnosticSubmissionStatus status;
  final String incidentId;
  final String? remoteId;
  final String? message;

  const DiagnosticSubmissionResult({
    required this.status,
    required this.incidentId,
    this.remoteId,
    this.message,
  });

  bool get isSuccess => status == DiagnosticSubmissionStatus.success;
  bool get isOffline => status == DiagnosticSubmissionStatus.offline;
  bool get isTimeout => status == DiagnosticSubmissionStatus.timeout;
  bool get isFailure => status == DiagnosticSubmissionStatus.failure;

  factory DiagnosticSubmissionResult.success(
    String incidentId, {
    String? remoteId,
  }) =>
      DiagnosticSubmissionResult(
        status: DiagnosticSubmissionStatus.success,
        incidentId: incidentId,
        remoteId: remoteId,
      );

  factory DiagnosticSubmissionResult.offline(String incidentId) =>
      DiagnosticSubmissionResult(
        status: DiagnosticSubmissionStatus.offline,
        incidentId: incidentId,
      );

  factory DiagnosticSubmissionResult.timeout(String incidentId) =>
      DiagnosticSubmissionResult(
        status: DiagnosticSubmissionStatus.timeout,
        incidentId: incidentId,
      );

  factory DiagnosticSubmissionResult.failure(
    String incidentId, {
    String? message,
  }) =>
      DiagnosticSubmissionResult(
        status: DiagnosticSubmissionStatus.failure,
        incidentId: incidentId,
        message: message,
      );
}
