import 'air_quality.dart';
import 'pollen.dart';

class DailyForecast {
  final DateTime date;
  final double minTempC;
  final double maxTempC;
  final double avgTempC;
  final String conditionText;
  final String iconUrl;

  const DailyForecast({
    required this.date,
    required this.minTempC,
    required this.maxTempC,
    required this.avgTempC,
    required this.conditionText,
    required this.iconUrl,
  });
}

class Forecast {
  final String locationName;
  final List<DailyForecast> days;
  final AirQuality? airQuality;
  final Pollen? pollen;

  const Forecast({
    required this.locationName,
    required this.days,
    this.airQuality,
    this.pollen,
  });
}
