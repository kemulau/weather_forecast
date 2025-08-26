import 'package:auto_injector/auto_injector.dart';
import 'package:weather_app/data/repositories/weather_repository_contract.dart';
import 'package:weather_app/data/repositories/weather_repositoty_impl.dart';
import 'package:weather_app/data/services/weather_service_api_impl.dart';
import 'package:weather_app/data/services/weather_service_contract.dart';
import 'package:weather_app/domain/usecases/weather_usecases_contracts.dart';
import 'package:weather_app/domain/usecases/weather_usecases_facade_contract.dart';
import 'package:weather_app/domain/usecases/weather_usecases_facade_impl.dart';
import 'package:weather_app/domain/usecases/weather_usecases_impl.dart';
import 'package:weather_app/ui/controllers/home_weather_view_model.dart';
import 'package:weather_app/ui/controllers/home_page_controller.dart';

final injector = AutoInjector();
void setupDependencyInjection() {
  injector.addSingleton<IWeatherService>(WeatherApiService.new);
  injector.addSingleton<IWeatherRepository>(WeatherRepository.new);
  injector.addSingleton<IGetCurrentWeatherUseCase>(
    GetCurrentWeatherUseCase.new,
  );
  injector.addSingleton<IGetForecastUseCase>(GetForecastUseCase.new);
  injector.addSingleton<IGetCompleteWeatherUseCase>(
    GetCompleteWeatherUseCase.new,
  );
  injector.addSingleton<IGetWeatherByCoordinatesUseCase>(
    GetWeatherByCoordinatesUseCase.new,
  );
  injector.addSingleton<IGetForecastByCoordinatesUseCase>(
    GetForecastByCoordinatesUseCase.new,
  );
  injector.addSingleton<IWeatherUseCasesFacade>(
    WeatherFacade.new,
  );
  injector.addSingleton<WeatherHomeViewController>(
    WeatherHomeViewController.new,
  );

  setupHomePageInjection();

  injector.commit();

}
