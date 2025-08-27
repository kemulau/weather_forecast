import 'package:weather_app/domain/models/current_weather.dart';

class CurrentWeatherDto {
  final String locationName;
  final double tempC;
  final String conditionText;
  final String iconUrl;
  final int humidity;
  final double windKph;
  final double lat;
  final double lon;

  const CurrentWeatherDto({
    required this.locationName,
    required this.tempC,
    required this.conditionText,
    required this.iconUrl,
    required this.humidity,
    required this.windKph,
    required this.lat,
    required this.lon,
  });

  factory CurrentWeatherDto.fromJson(Map<String, dynamic> j) {
    final location = j['location'] as Map<String, dynamic>;
    final current = j['current'] as Map<String, dynamic>;
    final condition = current['condition'] as Map<String, dynamic>;
    return CurrentWeatherDto(
      locationName: location['name'] as String,
      tempC: (current['temp_c'] as num).toDouble(),
      conditionText: condition['text'] as String,
      iconUrl: 'https:${condition['icon']}',
      humidity: (current['humidity'] as num?)?.toInt() ?? 0,
      windKph: (current['wind_kph'] as num?)?.toDouble() ?? 0,
      lat: (location['lat'] as num).toDouble(),
      lon: (location['lon'] as num).toDouble(),
    );
  }

  CurrentWeather toDomain() => CurrentWeather(
        locationName: locationName,
        tempC: tempC,
        conditionText: conditionText,
        iconUrl: iconUrl,
        humidity: humidity,
        windKph: windKph,
        lat: lat,
        lon: lon,
      );

  static CurrentWeatherDto mock({String locationName = 'Mock City'}) =>
      CurrentWeatherDto(
        locationName: locationName,
        tempC: 20,
        conditionText: 'Mocked',
        iconUrl:
            'https://cdn.weatherapi.com/weather/64x64/day/113.png',
        humidity: 50,
        windKph: 10,
        lat: 0,
        lon: 0,
      );
}
