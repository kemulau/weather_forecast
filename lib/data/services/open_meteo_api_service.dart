import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:weather_app/data/services/marine_api_service.dart';

/// Adapter para Open-Meteo que expõe a interface MarineApiService.
///
/// Retorna JSON compatível com os modelos existentes (hours/data) para evitar
/// mudanças na UI/controladores.
class OpenMeteoApiService implements MarineApiService {
  final http.Client _client;

  OpenMeteoApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _marineBase = 'https://marine-api.open-meteo.com/v1/marine';
  static const _tideBase = 'https://marine-api.open-meteo.com/v1/tide';
  static const _forecastBase = 'https://api.open-meteo.com/v1/forecast';

  @override
  Future<Map<String, dynamic>> getMarinePoint(
    double lat,
    double lng,
    DateTime start,
    DateTime end,
    List<String> params,
  ) async {
    // Open-Meteo usa datas (YYYY-MM-DD) e lista de variáveis em `hourly`.
    final s = start.toUtc();
    final e = end.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    String d(DateTime t) => '${t.year}-${two(t.month)}-${two(t.day)}';

    // Variáveis marinhas (Open-Meteo Marine)
    const marineVars = [
      'wave_height',
      'swell_wave_height',
      'swell_wave_period',
      'sea_surface_temperature',
    ];

    final marineUri = Uri.parse(_marineBase).replace(queryParameters: {
      'latitude': lat.toString(),
      'longitude': lng.toString(),
      'hourly': marineVars.join(','),
      'start_date': d(s),
      'end_date': d(e),
      'timezone': 'UTC',
    });

    // Variáveis de vento vêm do endpoint forecast
    const windVars = ['wind_speed_10m', 'wind_direction_10m'];
    final forecastUri = Uri.parse(_forecastBase).replace(queryParameters: {
      'latitude': lat.toString(),
      'longitude': lng.toString(),
      'hourly': windVars.join(','),
      'start_date': d(s),
      'end_date': d(e),
      'timezone': 'UTC',
      'windspeed_unit': 'ms',
    });

    final results = await Future.wait([
      _client.get(marineUri),
      _client.get(forecastUri),
    ]);
    if (kDebugMode) {
      debugPrint('OpenMeteo marine: ${marineUri.toString()}');
      debugPrint('OpenMeteo forecast: ${forecastUri.toString()}');
    }

    final marineRes = results[0];
    final windRes = results[1];

    Map<String, dynamic> marineJson = {};
    Map<String, dynamic> windJson = {};
    if (marineRes.statusCode >= 200 && marineRes.statusCode < 300) {
      marineJson = jsonDecode(marineRes.body) as Map<String, dynamic>;
    }
    if (windRes.statusCode >= 200 && windRes.statusCode < 300) {
      windJson = jsonDecode(windRes.body) as Map<String, dynamic>;
    }
    if (kDebugMode) {
      debugPrint('marine status: ${marineRes.statusCode}');
      debugPrint('wind status: ${windRes.statusCode}');
    }

    final marineHourly = (marineJson['hourly'] as Map<String, dynamic>?);
    final windHourly = (windJson['hourly'] as Map<String, dynamic>?);

    List<T> _mlist<T>(String k) => (marineHourly?[k] as List?)?.cast<T>() ?? <T>[];
    List<T> _wlist<T>(String k) => (windHourly?[k] as List?)?.cast<T>() ?? <T>[];

    final timesMarine = _mlist<String>('time');
    final timesWind = _wlist<String>('time');

    final setTimes = {...timesMarine, ...timesWind};
    if (setTimes.isEmpty) return {'hours': <Map<String, dynamic>>[]};

    double? _mapLookup(List<String> times, List<num> values, String time) {
      final idx = times.indexOf(time);
      if (idx < 0 || idx >= values.length) return null;
      return values[idx].toDouble();
    }

    final waveHeight = _mlist<num>('wave_height');
    final swellHeight = _mlist<num>('swell_wave_height');
    final swellPeriod = _mlist<num>('swell_wave_period');
    final waterTemp = _mlist<num>('sea_surface_temperature');
    final windSpeed = _wlist<num>('wind_speed_10m');
    final windDir = _wlist<num>('wind_direction_10m');

    String normalize(String t) => t.endsWith('Z') ? t : '${t}Z';

    Map<String, dynamic> wrap(String key, double? v) => v == null
        ? {key: {}}
        : {key: {'sg': v}};

    final hours = <Map<String, dynamic>>[];
    for (final raw in setTimes) {
      final iso = normalize(raw);
      final t = DateTime.parse(iso).toUtc();
      if (t.isBefore(s) || t.isAfter(e)) continue;

      final wh = _mapLookup(timesMarine, waveHeight, raw);
      final sh = _mapLookup(timesMarine, swellHeight, raw);
      final sp = _mapLookup(timesMarine, swellPeriod, raw);
      final wt = _mapLookup(timesMarine, waterTemp, raw);
      final ws = _mapLookup(timesWind, windSpeed, raw);
      final wd = _mapLookup(timesWind, windDir, raw);

      final entry = <String, dynamic>{
        'time': t.toIso8601String(),
        ...wrap('waveHeight', wh),
        ...wrap('swellHeight', sh),
        ...wrap('swellPeriod', sp),
        ...wrap('windSpeed', ws),
        ...wrap('windDirection', wd),
        ...wrap('waterTemperature', wt),
      };
      hours.add(entry);
    }

    hours.sort((a, b) => (a['time'] as String).compareTo(b['time'] as String));
    return {'hours': hours};
  }

  @override
  Future<Map<String, dynamic>> getTideExtremes(
    double lat,
    double lng,
    DateTime start,
    DateTime end,
  ) async {
    final startUtc = start.toUtc();
    final endUtc = end.toUtc();
    // limitar a 72h para evitar respostas 400 em alguns pontos
    final hours = endUtc.difference(startUtc).inHours.clamp(1, 72);

    final uri = Uri.parse(_tideBase).replace(queryParameters: {
      'latitude': lat.toString(),
      'longitude': lng.toString(),
      'length': hours.toString(),
      'timezone': 'UTC',
    });

    final response = await _client.get(uri);
    if (kDebugMode) {
      debugPrint('OpenMeteo tide: ${uri.toString()} status=${response.statusCode}');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return {'data': <Map<String, dynamic>>[]};
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    // Caso 1: API já retorna extremos como lista
    final tideList = decoded['tide'] ?? decoded['tides'] ?? decoded['extremes'] ?? decoded['events'];
    if (tideList is List) {
      final extremes = <Map<String, dynamic>>[];
      for (final item in tideList) {
        if (item is Map) {
          final ts = (item['time'] ?? item['timestamp']) as String?;
          if (ts == null) continue;
          final t = DateTime.parse(ts.endsWith('Z') ? ts : '${ts}Z').toUtc();
          if (t.isBefore(startUtc) || t.isAfter(endUtc)) continue;
          final typeRaw = (item['type'] ?? item['tide_type'] ?? item['state'])?.toString().toLowerCase();
          final type = (typeRaw == 'high' || typeRaw == 'alta') ? 'high' : (typeRaw == 'low' || typeRaw == 'baixa') ? 'low' : 'high';
          final height = (item['height'] ?? item['value']) as num?;
          extremes.add({
            'time': t.toIso8601String(),
            'type': type,
            'height': height?.toDouble(),
          });
        }
      }
      return {'data': extremes};
    }

    // Caso 2: séries de altura horária -> derivar extremos
    List<String> times = [];
    List<double> heights = [];

    final hourly = decoded['hourly'];
    if (hourly is Map) {
      final t = (hourly['time'] as List?)?.cast<String>();
      // Algumas respostas usam "tide_height" e outras "height"
      final rawH = (hourly['tide_height'] ?? hourly['height']) as List?;
      final h = rawH?.cast<num>();
      if (t != null && h != null && t.length == h.length) {
        times = t;
        heights = h.map((n) => n.toDouble()).toList();
      }
    }

    if (times.isEmpty || heights.isEmpty) {
      // Fallback: tentar obter a série de "tide_height" pelo endpoint Marine
      String two(int n) => n.toString().padLeft(2, '0');
      String d(DateTime t) => '${t.year}-${two(t.month)}-${two(t.day)}';
      final tideMarineUri = Uri.parse(_marineBase).replace(queryParameters: {
        'latitude': lat.toString(),
        'longitude': lng.toString(),
        'hourly': 'tide_height',
        'start_date': d(startUtc),
        'end_date': d(endUtc),
        'timezone': 'UTC',
      });
      final res = await _client.get(tideMarineUri);
      if (kDebugMode) {
        debugPrint('OpenMeteo fallback tide_height via marine: ${res.statusCode}');
      }
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final m = jsonDecode(res.body) as Map<String, dynamic>;
        final hourly2 = m['hourly'];
        if (hourly2 is Map) {
          final t2 = (hourly2['time'] as List?)?.cast<String>();
          final h2 = (hourly2['tide_height'] as List?)?.cast<num>();
          if (t2 != null && h2 != null && t2.length == h2.length) {
            times = t2;
            heights = h2.map((n) => n.toDouble()).toList();
          }
        }
      }
      if (times.isEmpty || heights.isEmpty) {
        return {'data': <Map<String, dynamic>>[]};
      }
    }

    final extremes = <Map<String, dynamic>>[];
    for (var i = 1; i < heights.length - 1; i++) {
      final prev = heights[i - 1];
      final cur = heights[i];
      final next = heights[i + 1];
      final ts = times[i];
      final t = DateTime.parse(ts.endsWith('Z') ? ts : '${ts}Z').toUtc();
      if (t.isBefore(startUtc) || t.isAfter(endUtc)) continue;

      const eps = 1e-6;
      final isHigh = (cur - prev) >= -eps && (cur - next) > eps;
      final isLow = (cur - prev) <= eps && (cur - next) < -eps;
      if (isHigh || isLow) {
        extremes.add({
          'time': t.toIso8601String(),
          'type': isHigh ? 'high' : 'low',
          'height': cur,
        });
      }
    }

    return {'data': extremes};
  }
}
