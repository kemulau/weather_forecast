import 'package:weather_app/domain/models/forecast.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';

class GetForecastUseCase {
  final WeatherRepository _repository;

  GetForecastUseCase(this._repository);

  Future<Forecast> call(
    String q, {
    int days = 3,
    bool aqi = false,
    bool alerts = false,
    bool pollen = false,
  }) {
    return _repository.fetchForecast(
      q,
      days: days,
      aqi: aqi,
      alerts: alerts,
      pollen: pollen,
    );
  }
}
