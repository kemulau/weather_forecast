import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/core/config/stormglass_config.dart';
import 'package:weather_app/core/errors/errors_classes.dart';

class StormGlassApiService {
  final http.Client _client;

  StormGlassApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> getMarinePoint(
    double lat,
    double lng,
    DateTime start,
    DateTime end,
    List<String> params,
  ) async {
    final uri = Uri.parse(
      '${StormGlassConfig.baseUrl}${StormGlassConfig.apiV2}/marine/point',
    ).replace(queryParameters: {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'start': start.toUtc().toIso8601String(),
      'end': end.toUtc().toIso8601String(),
      'params': params.join(','),
      'source': StormGlassConfig.defaultSource,
    });

    final response = await _client.get(uri, headers: _buildHeaders());
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw ApiException('Erro na API: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getTideExtremes(
    double lat,
    double lng,
    DateTime start,
    DateTime end,
  ) async {
    final uri = Uri.parse(
      '${StormGlassConfig.baseUrl}${StormGlassConfig.apiV2}/tide/extremes/point',
    ).replace(queryParameters: {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'start': start.toUtc().toIso8601String(),
      'end': end.toUtc().toIso8601String(),
    });

    final response = await _client.get(uri, headers: _buildHeaders());
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw ApiException('Erro na API: ${response.statusCode}');
    }
  }

  Map<String, String> _buildHeaders() {
    final apiKey = StormGlassConfig.apiKey;
    if (apiKey.isNotEmpty) {
      return {'Authorization': apiKey};
    }
    return {};
  }
}

