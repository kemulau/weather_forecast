import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weather_app/core/di/injector.dart';
import 'package:weather_app/domain/usecases/get_marine_hours_usecase.dart';
import 'package:weather_app/domain/usecases/get_tide_extremes_usecase.dart';
import 'package:weather_app/domain/models/marine_models.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:weather_app/ui/controllers/surf_fish_controller.dart';

class SurfFishPanel extends StatefulWidget {
  final double lat;
  final double lng;

  const SurfFishPanel({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  State<SurfFishPanel> createState() => _SurfFishPanelState();
}

class _SurfFishPanelState extends State<SurfFishPanel> {
  late final SurfFishController _controller;
  late Future<(
    List<MarineHour>,
    List<TideExtreme>,
    List<SurfFishWindow>,
  )> _future;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _controller = SurfFishController(
      injector.get<GetMarineHoursUseCase>(),
      injector.get<GetTideExtremesUseCase>(),
    );
    _future = _controller.load(widget.lat, widget.lng);
    _autoTimer = Timer.periodic(const Duration(minutes: 30), (_) => _refresh());
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _controller.load(widget.lat, widget.lng);
    });
    await _future;
  }

  String _formatTime(DateTime time) {
    final t = time.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.day)}/${two(t.month)} ${two(t.hour)}:${two(t.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final content = FutureBuilder<(
      List<MarineHour>,
      List<TideExtreme>,
      List<SurfFishWindow>,
    )>(
      future: _future,
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('${l10n.errorPrefix} ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final (
          List<MarineHour> hours,
          List<TideExtreme> tides,
          List<SurfFishWindow> windows,
        ) = snapshot.data!;

        if (hours.isEmpty && tides.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppLocalizations.of(context).noMarineData,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final MarineHour? current = hours.isNotEmpty ? hours.first : null;
        final scheme = Theme.of(context).colorScheme;

        return Column(
          children: [
            // Header com gradiente e cards compactos
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFD6E8FF), Color(0xFFB4D3FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.currentConditions,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  if (current != null)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _MetricCard(
                          icon: Icons.waves,
                          label: l10n.wave,
                          value: current.waveHeight != null
                              ? '${current.waveHeight!.toStringAsFixed(1)} m'
                              : '--',
                        ),
                        _MetricCard(
                          icon: Icons.trending_up,
                          label: l10n.swell,
                          value:
                              '${current.swellHeight?.toStringAsFixed(1) ?? '--'} m\n${current.swellPeriod?.toStringAsFixed(0) ?? '--'} s',
                        ),
                        _MetricCard(
                          icon: Icons.air,
                          label: l10n.wind,
                          value:
                              '${current.windSpeed?.toStringAsFixed(1) ?? '--'} m/s${current.windDirection != null ? "\n${current.windDirection!.toStringAsFixed(0)}°" : ''}',
                        ),
                        _MetricCard(
                          icon: Icons.water,
                          label: l10n.water,
                          value: current.waterTemperature != null
                              ? '${current.waterTemperature!.toStringAsFixed(1)} °C'
                              : '--',
                        ),
                      ],
                    )
                  else
                    Text(l10n.noCurrentData),
                ],
              ),
              ),

            if (tides.isNotEmpty)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.waves, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.nextTides,
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tides.map((t) {
                          final isHigh = t.type == 'high';
                          final color = isHigh
                              ? Colors.blue
                              : Colors.lightBlue;
                          final icon = isHigh
                              ? Icons.arrow_upward
                              : Icons.arrow_downward;
                          final text = '${_formatTime(t.time)}' +
                              (t.height != null
                                  ? ' • ${t.height!.toStringAsFixed(2)} m'
                                  : '');
                          return _ChipCard(
                            icon: icon,
                            color: color,
                            label: isHigh ? l10n.tideHigh : l10n.tideLow,
                            subtitle: text,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            if (tides.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  AppLocalizations.of(context).noTideData,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),

            if (windows.isNotEmpty)
              Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.idealWindows,
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: windows.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final w = windows[index];
                            final color = w.label == 'SURF'
                                ? Colors.blueAccent
                                : Colors.lightBlueAccent;
                            return _WindowCard(
                              color: color,
                              label: w.label,
                              score: w.score,
                              start: _formatTime(w.start),
                              end: _formatTime(w.end),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (windows.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Text(
                  AppLocalizations.of(context).noWindows,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        );
      },
    );

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: content,
      ),
    );
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetricCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.blue.shade600),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _ChipCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  const _ChipCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          )
        ],
      ),
    );
  }
}

class _WindowCard extends StatelessWidget {
  final Color color;
  final String label;
  final double score;
  final String start;
  final String end;
  const _WindowCard({
    required this.color,
    required this.label,
    required this.score,
    required this.start,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text('$label  (${score.toStringAsFixed(1)})',
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 6),
          Text('$start → $end', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
