import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:weather_app/domain/models/air_quality.dart';
import 'package:weather_app/domain/models/forecast.dart';
import 'package:weather_app/domain/models/pollen.dart';
import 'package:weather_app/ui/controllers/weather_home_view_controller.dart';
import 'package:weather_app/core/errors/app_exception.dart';

class ForecastList extends StatelessWidget {
  final WeatherHomeViewController controller;

  const ForecastList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Watch((_) {
      final state = controller.forecastState.value;
      if (state.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state.error != null) {
        final err = state.error!;
        String message = err.toString();
        if (err is AppException) {
          message = 'error.code ${err.code}: ${err.userMessage}';
        }
        return Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => controller.loadForecast(),
              child: const Text('Tentar novamente'),
            ),
          ],
        );
      }
      final forecast = state.data;
      if (forecast == null) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Previsão dos próximos dias",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children:
                  forecast.days.map((f) => _buildForecastItem(context, f, forecast.days)).toList(),
            ),
          ),
          if (forecast.airQuality != null)
            _buildAqiSection(context, forecast.airQuality!),
          if (forecast.pollen != null)
            _buildPollenSection(context, forecast.pollen!),
        ],
      );
    });
  }

  Widget _buildForecastItem(
      BuildContext context, DailyForecast forecast, List<DailyForecast> list) {
    final isLast = list.indexOf(forecast) == list.length - 1;
    const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final dayOfWeek = days[forecast.date.weekday - 1];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.1),
                ),
              ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              dayOfWeek,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          Image.network(
            forecast.iconUrl,
            width: 28,
            height: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              forecast.conditionText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            "${forecast.minTempC.toInt()}°",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(width: 8),
          Text(
            "${forecast.maxTempC.toInt()}°",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAqiSection(BuildContext context, AirQuality aqi) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Qualidade do ar',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('US EPA Index: ${aqi.usEpaIndex ?? '-'}'),
        ],
      ),
    );
  }

  Widget _buildPollenSection(BuildContext context, Pollen pollen) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pólen',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('Árvores: ${pollen.tree ?? '-'}'),
          Text('Ervas: ${pollen.weed ?? '-'}'),
          Text('Grama: ${pollen.grass ?? '-'}'),
        ],
      ),
    );
  }
}
