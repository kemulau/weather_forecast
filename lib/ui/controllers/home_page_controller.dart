import 'package:http/http.dart' as http;
import 'package:weather_app/core/config/stormglass_config.dart';
import 'package:weather_app/core/dependencies/injection_dependencies.dart';
import 'package:weather_app/data/services/mock_stormglass_api_service.dart';
import 'package:weather_app/data/services/stormglass_api_service.dart';

/// Registers dependencies for the Home page.
void setupHomePageInjection() {
  injector.addSingleton<http.Client>(() => http.Client());
  if (StormGlassConfig.apiKey.isEmpty) {
    injector.addSingleton<StormGlassApiService>(
      () => MockStormGlassApiService(),
    );
  } else {
    injector.addSingleton<StormGlassApiService>(
      () => StormGlassApiService(client: injector.get<http.Client>()),
    );
  }
}
