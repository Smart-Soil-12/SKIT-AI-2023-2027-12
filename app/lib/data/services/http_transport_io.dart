import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Native `dart:io` HTTP transport for Android/Desktop FastAPI communication.
/// Returns response body on HTTP 2xx, or null if server is unreachable.
Future<String?> executeHttpRequest({
  required String method,
  required Uri uri,
  Map<String, String>? headers,
  String? body,
  Duration timeout = const Duration(seconds: 4),
}) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final request = await client.openUrl(method, uri).timeout(timeout);
    headers?.forEach((key, value) => request.headers.set(key, value));
    if (body != null) {
      request.write(body);
    }
    final response = await request.close().timeout(timeout);
    final responseBody =
        await response.transform(utf8.decoder).join().timeout(timeout);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    }
    return null;
  } catch (_) {
    return null;
  } finally {
    client.close(force: true);
  }
}
