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

  factory DiagnosticDeviceInfo.fromJson(Map<String, dynamic> json) => DiagnosticDeviceInfo(
    model: json['model'] as String,
    os: json['os'] as String,
    osVersion: json['osVersion'] as String,
    manufacturer: json['manufacturer'] as String,
    appVersion: json['appVersion'] as String,
  );

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

  factory DiagnosticErrorInfo.fromJson(Map<String, dynamic> json) => DiagnosticErrorInfo(
    message: json['message'] as String,
    displayedCode: json['displayedCode'] as String,
    realErrorCode: json['realErrorCode'] as String?,
    stackTrace: json['stackTrace'] as String,
    isFatal: json['isFatal'] as bool,
    isRecoverable: json['isRecoverable'] as bool,
    source: json['source'] as String,
  );

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

  factory DiagnosticReport.fromJson(Map<String, dynamic> json) => DiagnosticReport(
    incidentId: json['incidentId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    deviceInfo: DiagnosticDeviceInfo.fromJson(json['deviceInfo'] as Map<String, dynamic>),
    error: DiagnosticErrorInfo.fromJson(json['error'] as Map<String, dynamic>),
    severity: DiagnosticLevel.fromString(json['severity'] as String),
    context: json['context'] as Map<String, dynamic>,
    lastEvents: (json['lastEvents'] as List<dynamic>? ?? [])
        .map((e) => DiagnosticEvent.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

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
