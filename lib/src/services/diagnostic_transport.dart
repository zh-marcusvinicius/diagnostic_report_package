abstract interface class DiagnosticTransport {
  Future<DiagnosticTransportResponse> send(
    DiagnosticSubmissionEnvelope envelope,
  );
}

class DiagnosticSubmissionEnvelope {
  final String incidentId;
  final String schemaName;
  final int schemaVersion;
  final String encoding;
  final String base64Content;
  final Map<String, String> attributes;

  const DiagnosticSubmissionEnvelope({
    required this.incidentId,
    required this.schemaName,
    required this.schemaVersion,
    required this.encoding,
    required this.base64Content,
    this.attributes = const {},
  });
}

class DiagnosticTransportResponse {
  final int statusCode;
  final String? remoteId;
  final String? message;

  bool get accepted => statusCode >= 200 && statusCode < 300;

  const DiagnosticTransportResponse({
    required this.statusCode,
    this.remoteId,
    this.message,
  });
}