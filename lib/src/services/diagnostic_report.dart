import 'package:diagnostic_report_package/src/services/diagnostic_event.dart';

class DiagnosticDeviceInfo {
  final String model;
  final String os;

  const DiagnosticDeviceInfo({
    required this.model,
    required this.os
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'os': os,
    };
  }
}

class DianosticErrorInfo {
  final String message;
  final String diplayedCode;
  final String stackTrace;
  final bool isFatal;

  const DianosticErrorInfo({
    required this.message,
    required this.diplayedCode,
    required this.stackTrace,
    required this.isFatal,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'displayedCode': diplayedCode,
      'stackTrace': stackTrace,
      'isFatal': isFatal,
    };
  }
}

class DiagnosticReport {
  final String incidentId;
  final DateTime createdAt;
  final DiagnosticDeviceInfo deviceInfo;
  final DianosticErrorInfo error;
  final Map<String, dynamic> context;
  final List<DiagnosticEvent> lastEvents;

  DiagnosticReport({
    required this.incidentId,
    required this.createdAt,
    required this.deviceInfo,
    required this.error,
    required this.context,
    required this.lastEvents,
  });

  Map<String, dynamic> toJson() {
    return {
      'incidentId': incidentId,
      'createdAt': createdAt.toIso8601String(),
      'deviceInfo': deviceInfo.toJson(),
      'error': error.toJson(),
      'context': context,
      'lastEvents': lastEvents.map((e) => e.toJson()).toList(),
    };
  }
}