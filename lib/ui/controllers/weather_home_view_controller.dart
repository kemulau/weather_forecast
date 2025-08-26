import 'dart:async';

import 'package:signals_flutter/signals_flutter.dart' hide AsyncState;
import 'package:weather_app/core/patterns/command.dart';
import 'package:weather_app/core/patterns/result.dart';
import 'package:weather_app/domain/models/current_weather.dart';
import 'package:weather_app/domain/models/forecast.dart';
import 'package:weather_app/domain/models/location.dart';
import 'package:weather_app/domain/usecases/get_current_weather_usecase.dart';
import 'package:weather_app/domain/usecases/get_forecast_usecase.dart';
import 'package:weather_app/domain/usecases/search_locations_usecase.dart';

import 'async_state.dart';

class WeatherHomeViewController {
  final GetCurrentWeatherUseCase _getCurrent;
  final GetForecastUseCase _getForecast;
  final SearchLocationsUseCase _searchLocations;

  WeatherHomeViewController({
    required GetCurrentWeatherUseCase getCurrentWeatherUseCase,
    required GetForecastUseCase getForecastUseCase,
    required SearchLocationsUseCase searchLocationsUseCase,
  })  : _getCurrent = getCurrentWeatherUseCase,
        _getForecast = getForecastUseCase,
        _searchLocations = searchLocationsUseCase {
    _initCommands();
  }

  final city = signal<String>('Curitiba');
  final currentState =
      signal<AsyncState<CurrentWeather>>(const AsyncState.initial());
  final forecastState =
      signal<AsyncState<Forecast>>(const AsyncState.initial());
  final suggestions = signal<List<Location>>([]);

  late final loadCurrentCmd = _LoadCurrentCmd(_getCurrent);
  late final loadForecastCmd = _LoadForecastCmd(_getForecast);
  late final searchCmd = _SearchCmd(_searchLocations);

  late final isLoading = computed(
    () => currentState.value.isLoading || forecastState.value.isLoading,
  );

  Timer? _debounce;

  void _initCommands() {
    effect(() {
      if (loadCurrentCmd.isExecuting.value) {
        currentState.value = const AsyncState.loading();
      } else {
        final res = loadCurrentCmd.result.value;
        if (res != null) {
          res.fold(
            onSuccess: (data) => currentState.value = AsyncState.data(data),
            onFailure: (err) => currentState.value = AsyncState.error(err),
          );
        }
      }
    });

    effect(() {
      if (loadForecastCmd.isExecuting.value) {
        forecastState.value = const AsyncState.loading();
      } else {
        final res = loadForecastCmd.result.value;
        if (res != null) {
          res.fold(
            onSuccess: (data) => forecastState.value = AsyncState.data(data),
            onFailure: (err) => forecastState.value = AsyncState.error(err),
          );
        }
      }
    });

    effect(() {
      final res = searchCmd.result.value;
      if (res != null && res.isSuccess) {
        suggestions.value = res.successValueOrNull!;
      }
    });
  }

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
}

class _LoadCurrentCmd extends ParameterizedCommand<
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

class _LoadForecastCmd extends ParameterizedCommand<
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

class _SearchCmd
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
