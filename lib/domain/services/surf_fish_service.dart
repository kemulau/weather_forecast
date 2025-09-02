import 'package:weather_app/domain/models/marine_models.dart';
import 'package:weather_app/domain/usecases/get_marine_hours_usecase.dart';
import 'package:weather_app/domain/usecases/get_tide_extremes_usecase.dart';

class SurfFishWindow {
  final DateTime start;
  final DateTime end;
  final String label; // "SURF" or "PESCA"
  final double score;

  const SurfFishWindow({
    required this.start,
    required this.end,
    required this.label,
    required this.score,
  });
}

class SurfFishService {
  final GetMarineHoursUseCase _getMarineHours;
  final GetTideExtremesUseCase _getTideExtremes;

  SurfFishService(
    this._getMarineHours,
    this._getTideExtremes,
  );

  Future<(
    List<MarineHour>,
    List<TideExtreme>,
    List<SurfFishWindow>,
  )> load(double lat, double lng) async {
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, now.day, now.hour);
    final end = start.add(const Duration(hours: 48));

    final marineHours = await _getMarineHours(lat, lng, start, end);
    final tideExtremes = await _getTideExtremes(lat, lng, start, end);

    final windows = _calculateWindows(marineHours, tideExtremes);

    return (marineHours, tideExtremes, windows);
  }

  List<SurfFishWindow> _calculateWindows(
    List<MarineHour> hours,
    List<TideExtreme> tides,
  ) {
    final windows = <SurfFishWindow>[];
    DateTime? start;
    DateTime? end;
    String? label;
    double totalScore = 0;
    int count = 0;

    for (final hour in hours) {
      final surfScore = _surfScore(hour);
      final fishScore = _fishScore(hour, tides);

      double? bestScore;
      String? bestLabel;

      // Definição dinâmica do limiar para pesca quando não há marés
      final minFish = tides.isEmpty ? 2 : 3;

      if (surfScore >= fishScore && surfScore >= 3) {
        bestScore = surfScore;
        bestLabel = 'SURF';
      } else if (fishScore > surfScore && fishScore >= minFish) {
        bestScore = fishScore;
        bestLabel = 'PESCA';
      }

      if (bestLabel == null) {
        if (label != null) {
          windows.add(SurfFishWindow(
            start: start!,
            end: end!,
            label: label!,
            score: totalScore / count,
          ));
          label = null;
        }
        continue;
      }

      if (label == bestLabel &&
          end != null &&
          hour.time.difference(end!).inHours == 1) {
        end = hour.time;
        totalScore += bestScore!;
        count++;
      } else {
        if (label != null) {
          windows.add(SurfFishWindow(
            start: start!,
            end: end!,
            label: label!,
            score: totalScore / count,
          ));
        }
        start = hour.time;
        end = hour.time;
        label = bestLabel;
        totalScore = bestScore!;
        count = 1;
      }
    }

    if (label != null) {
      windows.add(SurfFishWindow(
        start: start!,
        end: end!,
        label: label!,
        score: totalScore / count,
      ));
    }

    return windows;
  }

  double _surfScore(MarineHour hour) {
    double score = 0;
    if ((hour.swellPeriod ?? 0) >= 8) score++;
    final swell = hour.swellHeight ?? 0;
    if (swell >= 0.8 && swell <= 2.2) score++;
    if ((hour.windSpeed ?? double.infinity) <= 8) score++;
    return score;
  }

  double _fishScore(MarineHour hour, List<TideExtreme> tides) {
    double score = 0;
    if ((hour.windSpeed ?? double.infinity) <= 6) score++;
    if ((hour.waveHeight ?? double.infinity) <= 1.5) score++;
    for (final tide in tides) {
      final diff = tide.time.difference(hour.time).abs();
      if (diff <= const Duration(minutes: 90)) {
        score += 2;
        break;
      }
    }
    return score;
  }
}

