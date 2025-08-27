import 'package:weather_app/domain/models/air_quality.dart';
import 'package:weather_app/domain/models/forecast.dart';
import 'package:weather_app/domain/models/pollen.dart';

class PollenDto {
  final int? grass, tree, weed;
  const PollenDto({this.grass, this.tree, this.weed});
  factory PollenDto.fromJson(Map<String, dynamic> j) => PollenDto(
        grass: (j['grass_pollen'] as num?)?.toInt(),
        tree: (j['tree_pollen'] as num?)?.toInt(),
        weed: (j['weed_pollen'] as num?)?.toInt(),
      );
}

class ForecastDayDto {
  final DateTime date;
  final double minTempC;
  final double maxTempC;
  final double avgTempC;
  final String conditionText;
  final String iconUrl;
  final PollenDto? pollen;

  const ForecastDayDto({
    required this.date,
    required this.minTempC,
    required this.maxTempC,
    required this.avgTempC,
    required this.conditionText,
    required this.iconUrl,
    this.pollen,
  });

  factory ForecastDayDto.fromJson(Map<String, dynamic> j) {
    final d = j['day'] as Map<String, dynamic>;
    final condition = d['condition'] as Map<String, dynamic>;
    final pj = d['pollen'] as Map<String, dynamic>?;
    return ForecastDayDto(
      date: DateTime.parse(j['date'] as String),
      minTempC: (d['mintemp_c'] as num).toDouble(),
      maxTempC: (d['maxtemp_c'] as num).toDouble(),
      avgTempC: (d['avgtemp_c'] as num).toDouble(),
      conditionText: condition['text'] as String,
      iconUrl: 'https:${condition['icon']}',
      pollen: pj != null ? PollenDto.fromJson(pj) : null,
    );
  }

  DailyForecast toDomain() => DailyForecast(
        date: date,
        minTempC: minTempC,
        maxTempC: maxTempC,
        avgTempC: avgTempC,
        conditionText: conditionText,
        iconUrl: iconUrl,
      );

  static ForecastDayDto mock(int offset) => ForecastDayDto(
        date: DateTime.now().add(Duration(days: offset)),
        minTempC: 15 + offset.toDouble(),
        maxTempC: 25 + offset.toDouble(),
        avgTempC: 20 + offset.toDouble(),
        conditionText: 'Sunny',
        iconUrl: 'https://cdn.weatherapi.com/weather/64x64/day/113.png',
      );
}

class ForecastDto {
  final String locationName;
  final List<ForecastDayDto> days;
  final Map<String, dynamic>? alerts;
  final Map<String, dynamic>? aqi;
  final PollenDto? pollen;

  const ForecastDto({
    required this.locationName,
    required this.days,
    this.alerts,
    this.aqi,
    this.pollen,
  });

  factory ForecastDto.fromJson(Map<String, dynamic> j) {
    final location = j['location'] as Map<String, dynamic>;
    final forecast = j['forecast'] as Map<String, dynamic>;
    final dayList = (forecast['forecastday'] as List<dynamic>)
        .map((e) => ForecastDayDto.fromJson(e as Map<String, dynamic>))
        .toList();
    final pollen = dayList.isNotEmpty ? dayList[0].pollen : null;
    return ForecastDto(
      locationName: location['name'] as String,
      days: dayList,
      alerts: j['alerts'] as Map<String, dynamic>?,
      aqi: (j['current'] as Map<String, dynamic>?)?['air_quality']
          as Map<String, dynamic>?,
      pollen: pollen,
    );
  }

  AirQuality? _mapAqi() {
    final m = aqi;
    if (m == null) return null;
    return AirQuality(
      co: (m['co'] as num?)?.toDouble(),
      no2: (m['no2'] as num?)?.toDouble(),
      o3: (m['o3'] as num?)?.toDouble(),
      so2: (m['so2'] as num?)?.toDouble(),
      pm25: (m['pm2_5'] as num?)?.toDouble(),
      pm10: (m['pm10'] as num?)?.toDouble(),
      usEpaIndex: (m['us-epa-index'] as num?)?.toInt(),
      gbDefraIndex: (m['gb-defra-index'] as num?)?.toInt(),
    );
  }

  Pollen? _mapPollen() {
    final m = pollen;
    if (m == null) return null;
    return Pollen(
      tree: m.tree,
      weed: m.weed,
      grass: m.grass,
    );
  }

  Forecast toDomain() => Forecast(
        locationName: locationName,
        days: days.map((d) => d.toDomain()).toList(),
        airQuality: _mapAqi(),
        pollen: _mapPollen(),
      );

  static ForecastDto mock({String locationName = 'Mock City', int days = 3}) =>
      ForecastDto(
        locationName: locationName,
        days: List.generate(days, ForecastDayDto.mock),
      );
}
