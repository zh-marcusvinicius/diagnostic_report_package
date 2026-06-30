class DiagnosticSubmissionResult {
  final String incidentId;
  final bool isSuccess;
  final bool isOffline;
  final bool isTimeout;
  final String? remoteId;
  final String? message;

  const DiagnosticSubmissionResult({
    required this.incidentId,
    this.isSuccess = false,
    this.isOffline = false,
    this.isTimeout = false,
    this.remoteId,
    this.message,
  });

  factory DiagnosticSubmissionResult.success(String incidentId, {String? remoteId}) {
    return DiagnosticSubmissionResult(
      incidentId: incidentId,
      isSuccess: true,
      remoteId: remoteId,
    );
  }

  factory DiagnosticSubmissionResult.offline(String incidentId) {
    return DiagnosticSubmissionResult(
      incidentId: incidentId,
      isOffline: true,
    );
  }

  factory DiagnosticSubmissionResult.timeout(String incidentId) {
    return DiagnosticSubmissionResult(
      incidentId: incidentId,
      isTimeout: true,
    );
  }

  factory DiagnosticSubmissionResult.failure(String incidentId, {String? message}) {
    return DiagnosticSubmissionResult(
      incidentId: incidentId,
      message: message,
    );
  }
}
