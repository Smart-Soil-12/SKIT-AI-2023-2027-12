/// Platform-independent HTTP transport interface for SmartSoil API calls.
export 'http_transport_stub.dart'
    if (dart.library.io) 'http_transport_io.dart';
