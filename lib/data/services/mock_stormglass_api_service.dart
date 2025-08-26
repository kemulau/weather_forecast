import 'package:weather_app/data/services/stormglass_api_service.dart';

/// A mock implementation of [StormGlassApiService] returning static data.
class MockStormGlassApiService implements StormGlassApiService {
  @override
  Future<Map<String, dynamic>> getMarinePoint(
    double lat,
    double lng,
    DateTime start,
    DateTime end,
    List<String> params,
  ) async {
    return {
      'hours': [
        {
          'time': start.toIso8601String(),
          'waveHeight': {'sg': 1.2},
          'swellHeight': {'sg': 1.0},
          'swellPeriod': {'sg': 10},
          'windSpeed': {'sg': 5},
          'windDirection': {'sg': 180},
          'waterTemperature': {'sg': 20},
        },
        {
          'time': start.add(const Duration(hours: 1)).toIso8601String(),
          'waveHeight': {'sg': 1.3},
          'swellHeight': {'sg': 1.1},
          'swellPeriod': {'sg': 9},
          'windSpeed': {'sg': 6},
          'windDirection': {'sg': 190},
          'waterTemperature': {'sg': 21},
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getTideExtremes(
    double lat,
    double lng,
    DateTime start,
    DateTime end,
  ) async {
    return {
      'data': [
        {
          'time': start.add(const Duration(hours: 3)).toIso8601String(),
          'type': 'high',
          'height': 1.2,
        },
        {
          'time': start.add(const Duration(hours: 9)).toIso8601String(),
          'type': 'low',
          'height': 0.1,
        },
      ],
    };
  }
}

