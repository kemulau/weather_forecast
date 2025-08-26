import 'package:weather_app/data/datasources/weather_remote_datasource.dart';
import 'package:weather_app/data/dto/current_weather_dto.dart';
import 'package:weather_app/data/dto/forecast_dto.dart';
import 'package:weather_app/data/dto/location_dto.dart';

/// Mock implementation of [WeatherRemoteDataSource] returning static data.
class WeatherMockDataSource implements WeatherRemoteDataSource {
  @override
  Future<CurrentWeatherDto> getCurrent(String q, {bool aqi = false}) async {
    return CurrentWeatherDto.mock(locationName: q);
  }

  @override
  Future<ForecastDto> getForecast(
    String q, {
    int days = 3,
    bool aqi = false,
    bool alerts = false,
    bool pollen = false,
  }) async {
    return ForecastDto.mock(locationName: q, days: days);
  }

  @override
  Future<List<LocationDto>> search(String query) async {
    return [LocationDto.mock(name: query)];
  }
}
