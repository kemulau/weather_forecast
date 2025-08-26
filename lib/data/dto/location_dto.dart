import 'package:weather_app/domain/models/location.dart';

class LocationDto {
  final String name;
  final String region;
  final String country;
  final double lat;
  final double lon;

  const LocationDto({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory LocationDto.fromJson(Map<String, dynamic> j) => LocationDto(
        name: j['name'] as String,
        region: j['region'] as String? ?? '',
        country: j['country'] as String? ?? '',
        lat: (j['lat'] as num?)?.toDouble() ?? 0,
        lon: (j['lon'] as num?)?.toDouble() ?? 0,
      );

  Location toDomain() => Location(
        name: name,
        region: region,
        country: country,
        lat: lat,
        lon: lon,
      );

  static LocationDto mock({String name = 'Mock City'}) => LocationDto(
        name: name,
        region: 'Nowhere',
        country: 'Mockland',
        lat: 0,
        lon: 0,
      );
}
