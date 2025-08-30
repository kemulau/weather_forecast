import 'package:weather_app/domain/models/marine_models.dart';

abstract class MarineRepository {
  Future<List<MarineHour>> getMarineHours(
    double lat,
    double lng,
    DateTime start,
    DateTime end,
  );

  Future<List<TideExtreme>> getTideExtremes(
    double lat,
    double lng,
    DateTime start,
    DateTime end,
  );
}

