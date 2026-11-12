import 'dart:async';

/// Web/fallback HTTP transport stub (delegates to offline resilience mode when
/// no custom executor is provided).
Future<String?> executeHttpRequest({
  required String method,
  required Uri uri,
  Map<String, String>? headers,
  String? body,
  Duration timeout = const Duration(seconds: 4),
}) async {
  return null;
}
