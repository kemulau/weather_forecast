import 'package:weather_app/data/services/marine_api_service.dart';
import 'package:weather_app/domain/models/marine_models.dart';
import 'package:weather_app/domain/repositories/marine_repository.dart';

class MarineRepositoryImpl implements MarineRepository {
  final MarineApiService _service;
  MarineRepositoryImpl(this._service);

  @override
  Future<List<MarineHour>> getMarineHours(
    double lat,
    double lng,
    DateTime start,
    DateTime end,
  ) async {
    final json = await _service.getMarinePoint(lat, lng, start, end, const [
      'waveHeight',
      'swellHeight',
      'swellPeriod',
      'windSpeed',
      'windDirection',
      'waterTemperature',
    ]);
    final list = (json['hours'] as List<dynamic>? ?? [])
        .map((e) => MarineHour.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  @override
  Future<List<TideExtreme>> getTideExtremes(
    double lat,
    double lng,
    DateTime start,
    DateTime end,
  ) async {
    final json = await _service.getTideExtremes(lat, lng, start, end);
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => TideExtreme.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }
}

