import 'package:weather_app/domain/models/marine_models.dart';
import 'package:weather_app/domain/repositories/marine_repository.dart';

class GetTideExtremesUseCase {
  final MarineRepository _repo;
  GetTideExtremesUseCase(this._repo);

  Future<List<TideExtreme>> call(
    double lat,
    double lng,
    DateTime start,
    DateTime end,
  ) => _repo.getTideExtremes(lat, lng, start, end);
}

