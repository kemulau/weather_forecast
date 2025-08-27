import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:weather_app/core/errors/app_exception.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:weather_app/ui/controllers/weather_home_view_controller.dart';

class WeatherDetailsCard extends StatelessWidget {
  final WeatherHomeViewController controller;

  const WeatherDetailsCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Watch((_) {
      final state = controller.currentState.value;
      final l10n = AppLocalizations.of(context);
      if (state.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state.error != null) {
        final err = state.error!;
        String message = err.toString();
        if (err is AppException) {
          message = '${l10n.errorPrefix} ${err.userMessage}';
        }
        return Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => controller.loadCurrent(),
              child: Text(l10n.tryAgain),
            ),
          ],
        );
      }
      final weather = state.data;
      if (weather == null) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.weatherDetailsTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    icon: Icons.water_drop,
                    title: l10n.humidity,
                    value: "${weather.humidity}%",
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    icon: Icons.air,
                    title: l10n.wind,
                    value: "${weather.windKph} km/h",
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}