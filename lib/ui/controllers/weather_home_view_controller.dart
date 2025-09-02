import 'dart:async';

import 'package:signals_flutter/signals_flutter.dart';
import 'package:weather_app/core/patterns/command.dart';
import 'package:weather_app/core/patterns/result.dart';
import 'package:weather_app/domain/models/current_weather.dart';
import 'package:weather_app/domain/models/forecast.dart';
import 'package:weather_app/domain/models/location.dart';
import 'package:weather_app/domain/models/marine_models.dart';
import 'package:weather_app/domain/usecases/get_current_weather_usecase.dart';
import 'package:weather_app/domain/usecases/get_forecast_usecase.dart';
import 'package:weather_app/domain/usecases/search_locations_usecase.dart';
import 'package:weather_app/domain/services/surf_fish_service.dart';

class WeatherHomeViewController {
  final GetCurrentWeatherUseCase _getCurrent;
  final GetForecastUseCase _getForecast;
  final SearchLocationsUseCase _searchLocations;
  final SurfFishService _surfFish;

  WeatherHomeViewController({
    required GetCurrentWeatherUseCase getCurrentWeatherUseCase,
    required GetForecastUseCase getForecastUseCase,
    required SearchLocationsUseCase searchLocationsUseCase,
    required SurfFishService surfFishController,
  })  : _getCurrent = getCurrentWeatherUseCase,
        _getForecast = getForecastUseCase,
        _searchLocations = searchLocationsUseCase,
        _surfFish = surfFishController {
    _initCommands();
  }

  final city = signal<String>('Matinhos, PR');
  final suggestions = signal<List<Location>>([]);

  // Current weather signals
  final current = signal<CurrentWeather?>(null);
  final currentLoading = signal<bool>(false);
  final currentError = signal<Object?>(null);

  // Forecast signals
  final forecast = signal<Forecast?>(null);
  final forecastLoading = signal<bool>(false);
  final forecastError = signal<Object?>(null);

  // Marine signals
  final marineHours = signal<List<MarineHour>>([]);
  final tideExtremes = signal<List<TideExtreme>>([]);
  final surfFishWindows = signal<List<SurfFishWindow>>([]);
  final marineLoading = signal<bool>(false);
  final marineError = signal<Object?>(null);

  late final loadCurrentCmd = _LoadCurrentCmd(_getCurrent);
  late final loadForecastCmd = _LoadForecastCmd(_getForecast);
  late final searchCmd = _SearchCmd(_searchLocations);

  late final isLoading = computed(
    () => currentLoading.value || forecastLoading.value || marineLoading.value,
  );

  Timer? _debounce;
  Timer? _autoTimer;

  void _initCommands() {
    effect(() {
      // Wire current weather command -> signals
      currentLoading.value = loadCurrentCmd.isExecuting.value;
      final res = loadCurrentCmd.result.value;
      if (res != null) {
        res.fold(
          onSuccess: (data) {
            current.value = data;
            currentError.value = null;
          },
          onFailure: (err) {
            currentError.value = err;
          },
        );
      }
    });

    effect(() {
      // Wire forecast command -> signals
      forecastLoading.value = loadForecastCmd.isExecuting.value;
      final res = loadForecastCmd.result.value;
      if (res != null) {
        res.fold(
          onSuccess: (data) {
            forecast.value = data;
            forecastError.value = null;
          },
          onFailure: (err) {
            forecastError.value = err;
          },
        );
      }
    });

    effect(() {
      final res = searchCmd.result.value;
      if (res != null && res.isSuccess) {
        suggestions.value = res.successValueOrNull!;
      }
    });
  }

  /// Realiza atualização completa (clima atual + previsão)
  Future<void> refresh() async {
    await Future.wait([
      loadCurrent(),
      loadForecast(),
    ]);
  }

  /// Inicia agendamento de atualização automática com o intervalo informado.
  void startAutoRefresh({Duration interval = const Duration(minutes: 30)}) {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(interval, (_) async {
      await refresh();
    });
  }

  /// Cancela o agendamento de atualização automática.
  void stopAutoRefresh() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }

  /// Atualiza a cidade atual controlada pelo ViewController
  void setCity(String value) {
    city.value = value;
    // Auto-load marine when current weather updates
    effect(() {
      final cw = current.value;
      if (cw != null) {
        // Debounce marine load to avoid bursts
        _marineDebounce?.cancel();
        _marineDebounce = Timer(const Duration(milliseconds: 100), () {
          loadMarine(cw.lat, cw.lon);
        });
      }
    });
  }

  Timer? _marineDebounce;

  Future<void> loadCurrent({bool aqi = false}) async {
    await loadCurrentCmd.executeWith((q: city.value, aqi: aqi));
  }

  Future<void> loadForecast({
    int days = 3,
    bool aqi = false,
    bool alerts = false,
    bool pollen = false,
  }) async {
    if (days < 1 || days > 14) {
      throw ArgumentError.value(days, 'days', 'must be between 1 and 14');
    }
    await loadForecastCmd.executeWith((
      q: city.value,
      days: days,
      aqi: aqi,
      alerts: alerts,
      pollen: pollen,
    ));
  }

  void search(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      suggestions.value = [];
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchCmd.executeWith(query);
    });
  }

  /// Libera recursos internos (timers/debounce) caso necessário
  void dispose() {
    _debounce?.cancel();
    _marineDebounce?.cancel();
    stopAutoRefresh();
  }

  Future<void> loadMarine(double lat, double lng) async {
    try {
      marineLoading.value = true;
      marineError.value = null;
      final (List<MarineHour> h, List<TideExtreme> t, List<SurfFishWindow> w) =
          await _surfFish.load(lat, lng);
      marineHours.value = h;
      tideExtremes.value = t;
      surfFishWindows.value = w;
    } catch (e) {
      marineError.value = e;
    } finally {
      marineLoading.value = false;
    }
  }
}

final class _LoadCurrentCmd extends ParameterizedCommand<
    CurrentWeather, Object, ({String q, bool aqi})> {
  final GetCurrentWeatherUseCase _useCase;
  _LoadCurrentCmd(this._useCase);

  @override
  Future<Result<CurrentWeather, Object>> execute() async {
    final p = parameter!;
    try {
      final weather = await _useCase(p.q, aqi: p.aqi);
      return Success(weather);
    } catch (e) {
      return Error(e);
    }
  }
}

final class _LoadForecastCmd extends ParameterizedCommand<
    Forecast,
    Object,
    ({String q, int days, bool aqi, bool alerts, bool pollen})> {
  final GetForecastUseCase _useCase;
  _LoadForecastCmd(this._useCase);

  @override
  Future<Result<Forecast, Object>> execute() async {
    final p = parameter!;
    try {
      final forecast = await _useCase(
        p.q,
        days: p.days,
        aqi: p.aqi,
        alerts: p.alerts,
        pollen: p.pollen,
      );
      return Success(forecast);
    } catch (e) {
      return Error(e);
    }
  }
}

final class _SearchCmd
    extends ParameterizedCommand<List<Location>, Object, String> {
  final SearchLocationsUseCase _useCase;
  _SearchCmd(this._useCase);

  @override
  Future<Result<List<Location>, Object>> execute() async {
    final q = parameter!;
    try {
      final list = await _useCase(q);
      return Success(list);
    } catch (e) {
      return Error(e);
    }
  }
}
