class CurrentWeather {
  final String locationName;
  final double tempC;
  final String conditionText;
  final String iconUrl;
  final int humidity;
  final double windKph;
  final double lat;
  final double lon;

  const CurrentWeather({
    required this.locationName,
    required this.tempC,
    required this.conditionText,
    required this.iconUrl,
    required this.humidity,
    required this.windKph,
    required this.lat,
    required this.lon,
  });
}
