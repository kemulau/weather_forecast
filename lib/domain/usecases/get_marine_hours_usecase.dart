import 'package:weather_app/domain/models/marine_models.dart';
import 'package:weather_app/domain/repositories/marine_repository.dart';

class GetMarineHoursUseCase {
  final MarineRepository _repo;
  GetMarineHoursUseCase(this._repo);

  Future<List<MarineHour>> call(
    double lat,
    double lng,
    DateTime start,
    DateTime end,
  ) => _repo.getMarineHours(lat, lng, start, end);
}

