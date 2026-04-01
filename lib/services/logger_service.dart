import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error, critical }

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  final List<String> _logs = [];
  bool _enableLogging = true;
  bool _enableConsoleOutput = true;

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal();

  void setLoggingEnabled(bool enabled) {
    _enableLogging = enabled;
  }

  void setConsoleOutput(bool enabled) {
    _enableConsoleOutput = enabled;
  }

  void log(
    String message, {
    LogLevel level = LogLevel.info,
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!_enableLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag ?? 'APP';
    final levelName = level.toString().split('.').last.toUpperCase();

    final logMessage = '[$timestamp] [$levelName] [$logTag] $message';
    final fullLog = error != null ? '$logMessage\nError: $error\n$stackTrace' : logMessage;

    _logs.add(fullLog);

    if (_enableConsoleOutput) {
      if (kDebugMode) {
        print(fullLog);
      }
    }

    if (level == LogLevel.critical || level == LogLevel.error) {
      _reportError(fullLog, error, stackTrace);
    }
  }

  void debug(String message, {String? tag}) {
    log(message, level: LogLevel.debug, tag: tag);
  }

  void info(String message, {String? tag}) {
    log(message, level: LogLevel.info, tag: tag);
  }

  void warning(String message, {String? tag}) {
    log(message, level: LogLevel.warning, tag: tag);
  }

  void error(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.error, tag: tag, error: error, stackTrace: stackTrace);
  }

  void critical(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.critical, tag: tag, error: error, stackTrace: stackTrace);
  }

  List<String> getLogs() {
    return List.unmodifiable(_logs);
  }

  String getLogsAsString() {
    return _logs.join('\n');
  }

  void clearLogs() {
    _logs.clear();
  }

  Future<void> saveLogs(String filePath) async {
    // Implementation for saving logs to file
    // This would require file_picker or similar package
    debug('Logs saved to $filePath');
  }

  void _reportError(String message, dynamic error, StackTrace? stackTrace) {
    // Implementation for reporting errors to crash reporting service
    // This could integrate with Firebase Crashlytics or similar
    if (kDebugMode) {
      print('ERROR REPORTED: $message');
    }
  }

  void logApiCall({
    required String endpoint,
    required String method,
    Map<String, dynamic>? parameters,
    int? statusCode,
    dynamic response,
  }) {
    final message = 'API Call: $method $endpoint\n'
        'Parameters: $parameters\n'
        'Status: $statusCode\n'
        'Response: $response';
    info(message, tag: 'API');
  }

  void logUserAction({
    required String action,
    required String screen,
    Map<String, dynamic>? details,
  }) {
    final message = 'User Action: $action on $screen\nDetails: $details';
    info(message, tag: 'USER_ACTION');
  }

  void logGameEvent({
    required String gameName,
    required String event,
    int? score,
    int? timeSpent,
  }) {
    final message = 'Game Event: $event in $gameName\n'
        'Score: $score\n'
        'Time: ${timeSpent}s';
    info(message, tag: 'GAME');
  }

  void logPerformance({
    required String operation,
    required Duration duration,
  }) {
    final message = 'Performance: $operation took ${duration.inMilliseconds}ms';
    info(message, tag: 'PERFORMANCE');
  }
}
