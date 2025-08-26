import '../models/current_weather.dart';
import '../models/forecast.dart';
import '../models/location.dart';

abstract interface class WeatherRepository {
  Future<CurrentWeather> fetchCurrent(String q, {bool aqi = false});

  Future<Forecast> fetchForecast(
    String q, {
    int days = 3,
    bool aqi = false,
    bool alerts = false,
    bool pollen = false,
  });

  Future<List<Location>> search(String query);
}
