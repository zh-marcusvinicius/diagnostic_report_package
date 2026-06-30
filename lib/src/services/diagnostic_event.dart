import 'package:diagnostic_report_package/src/config/diagnostic_category.dart';
import 'package:diagnostic_report_package/src/config/diagnostic_level.dart';

class DiagnosticEvent {
  final String id;
  final DateTime timestamp;
  final DiagnosticLevel level;
  final DiagnosticCategory category;
  final String message;
  final Map<String, dynamic> metadata;
  final String? incidentId;

  const DiagnosticEvent({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.category,
    required this.message,
    this.metadata = const {},
    this.incidentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'category': category.name,
      'message': message,
      'metadata': metadata,
      'incidentId': incidentId,
    };
  }
}