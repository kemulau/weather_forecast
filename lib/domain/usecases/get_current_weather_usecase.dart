import 'package:weather_app/domain/models/current_weather.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';

class GetCurrentWeatherUseCase {
  final WeatherRepository _repository;

  GetCurrentWeatherUseCase(this._repository);

  Future<CurrentWeather> call(String q, {bool aqi = false}) {
    return _repository.fetchCurrent(q, aqi: aqi);
  }
}
