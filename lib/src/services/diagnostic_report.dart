import 'package:diagnostic_report_package/src/config/diagnostic_level.dart';
import 'package:diagnostic_report_package/src/services/diagnostic_event.dart';

class DiagnosticDeviceInfo {
  final String model;
  final String os;
  final String osVersion;
  final String manufacturer;
  final String appVersion;

  const DiagnosticDeviceInfo({
    required this.model,
    required this.os,
    this.osVersion = '',
    this.manufacturer = '',
    this.appVersion = '',
  });

  Map<String, dynamic> toJson() => {
        'model': model,
        'os': os,
        'osVersion': osVersion,
        'manufacturer': manufacturer,
        'appVersion': appVersion,
      };
}

class DiagnosticErrorInfo {
  final String message;
  final String displayedCode;
  final String? realErrorCode;
  final String stackTrace;
  final bool isFatal;
  final bool isRecoverable;
  final String source;

  const DiagnosticErrorInfo({
    required this.message,
    required this.displayedCode,
    required this.stackTrace,
    required this.isFatal,
    this.realErrorCode,
    this.isRecoverable = true,
    this.source = 'unknown',
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'displayedCode': displayedCode,
        if (realErrorCode != null) 'realErrorCode': realErrorCode,
        'stackTrace': stackTrace,
        'isFatal': isFatal,
        'isRecoverable': isRecoverable,
        'source': source,
      };
}

class DiagnosticReport {
  final String incidentId;
  final DateTime createdAt;
  final DiagnosticDeviceInfo deviceInfo;
  final DiagnosticErrorInfo error;
  final DiagnosticLevel severity;
  final Map<String, dynamic> context;
  final List<DiagnosticEvent> lastEvents;

  DiagnosticReport({
    required this.incidentId,
    required this.createdAt,
    required this.deviceInfo,
    required this.error,
    required this.context,
    required this.lastEvents,
    this.severity = DiagnosticLevel.error,
  });

  Map<String, dynamic> toJson() => {
        'incidentId': incidentId,
        'createdAt': createdAt.toIso8601String(),
        'deviceInfo': deviceInfo.toJson(),
        'error': error.toJson(),
        'severity': severity.name,
        'context': context,
        'lastEvents': lastEvents.map((e) => e.toJson()).toList(),
      };
}
