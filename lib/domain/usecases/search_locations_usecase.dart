import 'package:weather_app/domain/models/location.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';

class SearchLocationsUseCase {
  final WeatherRepository _repository;

  SearchLocationsUseCase(this._repository);

  Future<List<Location>> call(String query) {
    return _repository.search(query);
  }
}
