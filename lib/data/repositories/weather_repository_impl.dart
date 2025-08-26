import 'dart:io';

import 'package:http/http.dart' show ClientException;
import 'package:weather_app/data/datasources/weather_mock_datasource.dart';
import 'package:weather_app/data/datasources/weather_remote_datasource.dart';
import 'package:weather_app/core/errors/app_exception.dart';
import 'package:weather_app/domain/models/current_weather.dart';
import 'package:weather_app/domain/models/forecast.dart';
import 'package:weather_app/domain/models/location.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource _remote;
  final WeatherRemoteDataSource _mock;
  final bool useMock;
  final bool fallbackToMockOnError;

  WeatherRepositoryImpl({
    required WeatherRemoteDataSource remote,
    required WeatherMockDataSource mock,
    this.useMock = false,
    this.fallbackToMockOnError = false,
  })  : _remote = remote,
        _mock = mock;

  @override
  Future<CurrentWeather> fetchCurrent(String q, {bool aqi = false}) async {
    if (useMock) {
      return (await _mock.getCurrent(q, aqi: aqi)).toDomain();
    }
    try {
      return (await _remote.getCurrent(q, aqi: aqi)).toDomain();
    } on AppException {
      rethrow;
    } on SocketException catch (_) {
      if (fallbackToMockOnError) {
        return (await _mock.getCurrent(q, aqi: aqi)).toDomain();
      }
      rethrow;
    } on ClientException catch (_) {
      if (fallbackToMockOnError) {
        return (await _mock.getCurrent(q, aqi: aqi)).toDomain();
      }
      rethrow;
    }
  }

  @override
  Future<Forecast> fetchForecast(
    String q, {
    int days = 3,
    bool aqi = false,
    bool alerts = false,
    bool pollen = false,
  }) async {
    if (useMock) {
      return (await _mock.getForecast(
        q,
        days: days,
        aqi: aqi,
        alerts: alerts,
        pollen: pollen,
      )).toDomain();
    }
    try {
      return (await _remote.getForecast(
        q,
        days: days,
        aqi: aqi,
        alerts: alerts,
        pollen: pollen,
      )).toDomain();
    } on AppException {
      rethrow;
    } on SocketException catch (_) {
      if (fallbackToMockOnError) {
        return (await _mock.getForecast(
          q,
          days: days,
          aqi: aqi,
          alerts: alerts,
          pollen: pollen,
        )).toDomain();
      }
      rethrow;
    } on ClientException catch (_) {
      if (fallbackToMockOnError) {
        return (await _mock.getForecast(
          q,
          days: days,
          aqi: aqi,
          alerts: alerts,
          pollen: pollen,
        )).toDomain();
      }
      rethrow;
    }
  }

  @override
  Future<List<Location>> search(String query) async {
    if (useMock) {
      final list = await _mock.search(query);
      return list.map((e) => e.toDomain()).toList();
    }
    try {
      final list = await _remote.search(query);
      return list.map((e) => e.toDomain()).toList();
    } on AppException {
      rethrow;
    } on SocketException catch (_) {
      if (fallbackToMockOnError) {
        final list = await _mock.search(query);
        return list.map((e) => e.toDomain()).toList();
      }
      rethrow;
    } on ClientException catch (_) {
      if (fallbackToMockOnError) {
        final list = await _mock.search(query);
        return list.map((e) => e.toDomain()).toList();
      }
      rethrow;
    }
  }
}
