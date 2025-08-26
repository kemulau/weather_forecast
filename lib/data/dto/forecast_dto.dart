import 'package:weather_app/domain/models/air_quality.dart';
import 'package:weather_app/domain/models/forecast.dart';
import 'package:weather_app/domain/models/pollen.dart';

class ForecastDayDto {
  final DateTime date;
  final double minTempC;
  final double maxTempC;
  final double avgTempC;
  final String conditionText;
  final String iconUrl;

  const ForecastDayDto({
    required this.date,
    required this.minTempC,
    required this.maxTempC,
    required this.avgTempC,
    required this.conditionText,
    required this.iconUrl,
  });

  factory ForecastDayDto.fromJson(Map<String, dynamic> j) {
    final day = j['day'] as Map<String, dynamic>;
    final condition = day['condition'] as Map<String, dynamic>;
    return ForecastDayDto(
      date: DateTime.parse(j['date'] as String),
      minTempC: (day['mintemp_c'] as num).toDouble(),
      maxTempC: (day['maxtemp_c'] as num).toDouble(),
      avgTempC: (day['avgtemp_c'] as num).toDouble(),
      conditionText: condition['text'] as String,
      iconUrl: 'https:${condition['icon']}',
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
  final Map<String, dynamic>? pollen;

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
    return ForecastDto(
      locationName: location['name'] as String,
      days: dayList,
      alerts: j['alerts'] as Map<String, dynamic>?,
      aqi: (j['current'] as Map<String, dynamic>?)?['air_quality']
          as Map<String, dynamic>?,
      pollen: forecast['forecastday'] is List &&
              (forecast['forecastday'] as List).isNotEmpty
          ? ((forecast['forecastday'] as List)[0]['day']
                  as Map<String, dynamic>?)?['pollen']
              as Map<String, dynamic>?
          : null,
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
      tree: (m['tree_pollen'] as num?)?.toInt(),
      weed: (m['weed_pollen'] as num?)?.toInt(),
      grass: (m['grass_pollen'] as num?)?.toInt(),
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
