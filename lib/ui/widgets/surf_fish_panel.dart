import 'package:flutter/material.dart';
import 'package:weather_app/data/services/stormglass_api_service.dart';
import 'package:weather_app/ui/controllers/surf_fish_controller.dart';
import 'package:weather_app/domain/models/marine_models.dart';

class SurfFishPanel extends StatefulWidget {
  final double lat;
  final double lng;
  final StormGlassApiService api;

  const SurfFishPanel({
    super.key,
    required this.lat,
    required this.lng,
    required this.api,
  });

  @override
  State<SurfFishPanel> createState() => _SurfFishPanelState();
}

class _SurfFishPanelState extends State<SurfFishPanel> {
  late final SurfFishController _controller;
  late final Future<(
    List<MarineHour>,
    List<TideExtreme>,
    List<SurfFishWindow>,
  )> _future;

  @override
  void initState() {
    super.initState();
    _controller = SurfFishController(widget.api);
    _future = _controller.load(widget.lat, widget.lng);
  }

  String _formatTime(DateTime time) {
    final t = time.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.day)}/${two(t.month)} ${two(t.hour)}:${two(t.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(
      List<MarineHour>,
      List<TideExtreme>,
      List<SurfFishWindow>,
    )>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final (
          List<MarineHour> hours,
          List<TideExtreme> tides,
          List<SurfFishWindow> windows,
        ) = snapshot.data!;
        final MarineHour? current = hours.isNotEmpty ? hours.first : null;

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Condições atuais',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (current != null) ...[
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Onda'),
                    trailing: Text(
                      '${current.waveHeight?.toStringAsFixed(1) ?? '--'} m',
                    ),
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Swell'),
                    trailing: Text(
                      '${current.swellHeight?.toStringAsFixed(1) ?? '--'} m / '
                      '${current.swellPeriod?.toStringAsFixed(0) ?? '--'} s',
                    ),
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Vento'),
                    trailing: Text(
                      '${current.windSpeed?.toStringAsFixed(1) ?? '--'} m/s'
                      '${current.windDirection != null ? ' (${current.windDirection!.toStringAsFixed(0)}°)' : ''}',
                    ),
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Água'),
                    trailing: Text(
                      '${current.waterTemperature?.toStringAsFixed(1) ?? '--'} °C',
                    ),
                  ),
                ] else
                  const Text('Sem dados atuais'),
                const SizedBox(height: 8),
                ExpansionTile(
                  title: const Text('Próximas marés'),
                  children: tides
                      .map(
                        (t) => ListTile(
                          title: Text(t.type == 'high' ? 'Alta' : 'Baixa'),
                          subtitle: Text(_formatTime(t.time)),
                          trailing: t.height != null
                              ? Text('${t.height!.toStringAsFixed(2)} m')
                              : null,
                        ),
                      )
                      .toList(),
                ),
                ExpansionTile(
                  title: const Text('Janelas ideais'),
                  children: windows
                      .map(
                        (w) => ListTile(
                          title: Text(
                            '${w.label} (${w.score.toStringAsFixed(1)})',
                          ),
                          subtitle: Text(
                            '${_formatTime(w.start)} - ${_formatTime(w.end)}',
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

