import 'dart:convert';
import 'package:diagnostic_report_package/diagnostic_report_package.dart';
import 'package:http/http.dart' as http;

class HttpDiagnosticTransport implements DiagnosticTransport {
  final Uri endpoint;
  final Map<String, String>? headers;

  HttpDiagnosticTransport({
    required this.endpoint,
    this.headers,
  });

  @override
  Future<DiagnosticTransportResponse> send(DiagnosticSubmissionEnvelope envelope) async {
    try{
      final response = await http.post(
        endpoint,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: json.encode({
          'incidentId': envelope.incidentId,
          'schemaName': envelope.schemaName,
          'schemaVersion': envelope.schemaVersion,
          'encoding': envelope.encoding,
          'base64Content': envelope.base64Content,
        }),
      );

      return DiagnosticTransportResponse(
        statusCode: response.statusCode,
        message: response.body,
      );
    } catch (e) {
      return DiagnosticTransportResponse(statusCode: 500, message: e.toString());
    }
  }
}