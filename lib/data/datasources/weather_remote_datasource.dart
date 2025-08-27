import 'dart:convert';

import 'package:weather_app/core/config/api_config.dart';
import 'package:weather_app/data/dto/current_weather_dto.dart';
import 'package:weather_app/data/dto/forecast_dto.dart';
import 'package:weather_app/data/dto/location_dto.dart';
import 'package:weather_app/data/services/api_http_client_service.dart';
import 'package:weather_app/core/errors/app_exception.dart';

/// Contract for fetching weather information from a remote source.
abstract interface class WeatherRemoteDataSource {
  Future<CurrentWeatherDto> getCurrent(String q, {bool aqi = false});

  Future<ForecastDto> getForecast(
    String q, {
    int days = 3,
    bool aqi = false,
    bool alerts = false,
    bool pollen = false,
  });

  Future<List<LocationDto>> search(String query);
}

class WeatherApiRemoteDataSource implements WeatherRemoteDataSource {
  final ApiHttpClientService _client;

  WeatherApiRemoteDataSource({ApiHttpClientService? client})
      : _client = client ?? ApiHttpClientService();

  Uri _buildUri(String path, Map<String, String> params) {
    final base = ApiConfig.baseUrl;
    final query = {'key': ApiConfig.apiKey, ...params};
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  Never _throwFromResponse(int status, dynamic data) {
    if (data is Map && data['error'] is Map) {
      final err = data['error'] as Map;
      final code = err['code'] as int? ?? status;
      final message = err['message'] as String? ?? 'Unknown error';
      throw _mapException(status, code, message);
    }
    throw UnknownApiError(status, status, 'Unknown error');
  }

  AppException _mapException(int status, int code, String message) {
    switch (code) {
      case 1002:
        return ApiKeyMissing(status, message);
      case 1003:
        return QueryMissing(status, message);
      case 1006:
        return LocationNotFound(status, message);
      case 2006:
        return InvalidKey(status, message);
      case 2007:
        return QuotaExceeded(status, message);
      case 2008:
        return KeyDisabled(status, message);
      case 2009:
        return PlanNotAllowed(status, message);
      default:
        return UnknownApiError(status, code, message);
    }
  }

  @override
  Future<CurrentWeatherDto> getCurrent(String q, {bool aqi = false}) async {
    final uri = _buildUri('/current.json', {'q': q, 'aqi': aqi ? 'yes' : 'no'});
    final response = await _client.get(uri);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      _throwFromResponse(response.statusCode, data);
    }
    return CurrentWeatherDto.fromJson(data);
  }

  @override
  Future<ForecastDto> getForecast(
    String q, {
    int days = 3,
    bool aqi = false,
    bool alerts = false,
    bool pollen = false,
  }) async {
    if (days < 1 || days > 14) {
      throw ArgumentError('days must be between 1 and 14');
    }
    final uri = _buildUri('/forecast.json', {
      'q': q,
      'days': '$days',
      'aqi': aqi ? 'yes' : 'no',
      'alerts': alerts ? 'yes' : 'no',
      'pollen': pollen ? 'yes' : 'no',
    });
    final response = await _client.get(uri);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      _throwFromResponse(response.statusCode, data);
    }
    return ForecastDto.fromJson(data);
  }

  @override
  Future<List<LocationDto>> search(String query) async {
    final uri = _buildUri('/search.json', {'q': query});
    final response = await _client.get(uri);
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      _throwFromResponse(response.statusCode, data);
    }
    final list = data as List<dynamic>;
    return list
        .map((e) => LocationDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
