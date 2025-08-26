import 'package:http/http.dart' as http;

/// Simple wrapper around [http.Client] used by data sources.
class ApiHttpClientService {
  final http.Client _client;

  ApiHttpClientService({http.Client? client}) : _client = client ?? http.Client();

  /// Performs a GET request to the provided [uri].
  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) {
    return _client.get(uri, headers: headers);
  }
}
