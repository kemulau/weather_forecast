import 'package:auto_injector/auto_injector.dart';
import 'package:weather_app/core/config/api_config.dart';
import 'package:weather_app/data/datasources/weather_mock_datasource.dart';
import 'package:weather_app/data/datasources/weather_remote_datasource.dart';
import 'package:weather_app/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/data/services/api_http_client_service.dart';
import 'package:weather_app/data/services/stormglass_api_service.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/domain/usecases/get_current_weather_usecase.dart';
import 'package:weather_app/domain/usecases/get_forecast_usecase.dart';
import 'package:weather_app/domain/usecases/search_locations_usecase.dart';
import 'package:weather_app/ui/controllers/weather_home_view_controller.dart';

final injector = AutoInjector();

void initInjector() {
  injector.addSingleton(ApiHttpClientService.new);

  injector.addSingleton(StormGlassApiService.new);

  injector.addSingleton<WeatherRemoteDataSource>(
      WeatherApiRemoteDataSource.new);
  injector.addSingleton<WeatherMockDataSource>(WeatherMockDataSource.new);

  injector.addSingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(
      remote: injector.get<WeatherRemoteDataSource>(),
      mock: injector.get<WeatherMockDataSource>(),
      useMock: useMock,
      fallbackToMockOnError: true,
    ),
  );

  injector.addSingleton(GetCurrentWeatherUseCase.new);
  injector.addSingleton(GetForecastUseCase.new);
  injector.addSingleton(SearchLocationsUseCase.new);


  injector.addSingleton(
    () => WeatherHomeViewController(
      getCurrentWeatherUseCase: injector.get<GetCurrentWeatherUseCase>(),
      getForecastUseCase: injector.get<GetForecastUseCase>(),
      searchLocationsUseCase: injector.get<SearchLocationsUseCase>(),
    ),
  );

  injector.commit();
}
