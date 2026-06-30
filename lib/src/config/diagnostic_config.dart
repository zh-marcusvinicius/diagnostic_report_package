class DiagnosticConfig {
  final String schemaName;
  final int schemaVersion;
  final String environment;
  final int maxEventsInMemory;
  final int maxEventsPerReport;
  final int maxReportsInMemory;
  final int maxStoredReports;
  final int maxCollectionItems;
  final int maxTextLength;
  final Duration connectivityTimeout;
  final Duration collectionTimeout;
  final Duration uploadTimeout;
  final bool persistReports;
  final bool includeLocation;
  final bool prettyPrintDebugPayload;

  const DiagnosticConfig({
    required this.schemaName,
    this.schemaVersion = 1,
    this.environment = '',
    this.maxEventsInMemory = 300,
    this.maxEventsPerReport = 150,
    this.maxReportsInMemory = 10,
    this.maxStoredReports = 10,
    this.maxCollectionItems = 200,
    this.maxTextLength = 20000,
    this.connectivityTimeout = const Duration(seconds: 8),
    this.collectionTimeout = const Duration(seconds: 20),
    this.uploadTimeout = const Duration(seconds: 45),
    this.persistReports = true,
    this.includeLocation = false,
    this.prettyPrintDebugPayload = false,
  });
}