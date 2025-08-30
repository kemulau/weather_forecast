import 'dart:async';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:weather_app/core/di/injector.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:weather_app/data/services/marine_api_service.dart';
import 'package:weather_app/ui/controllers/weather_home_view_controller.dart';
import 'package:weather_app/ui/widgets/current_weather_card.dart';
import 'package:weather_app/ui/widgets/forecast_list.dart';
import 'package:weather_app/ui/widgets/surf_fish_panel.dart';
import 'package:weather_app/ui/widgets/weather_detail_card.dart';
import 'package:weather_app/ui/widgets/weather_search_bar.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key, required this.title});

  final String title;
  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  late WeatherHomeViewController _viewController;
  // Controller para campo de busca
  final searchController = TextEditingController();
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _viewController = injector.get<WeatherHomeViewController>();
    _viewController.loadCurrent();
    _viewController.loadForecast();

    // Atualização automática a cada 30 minutos
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(minutes: 30), (_) async {
      await _viewController.loadCurrent();
      await _viewController.loadForecast();
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onSearch(String cityName) async {
    cityName = searchController.text.trim();
    if (cityName.isNotEmpty) {
      // Mostrar indicador de busca
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.searchingCity(cityName)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );

      _viewController.city.value = cityName;
      await _viewController.loadCurrent();
      await _viewController.loadForecast();
      searchController.clear();
    }
  }

  Widget _buildWeatherTab() {
    return SafeArea(
      // use refresh indicator para permitir que o usuário atualize os dados puxando para baixo
      child: RefreshIndicator(
        onRefresh: () async {
          await _viewController.loadCurrent();
          await _viewController.loadForecast();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WeatherSearchBar(
                controller: searchController,
                viewController: _viewController,
                onSearch: _onSearch,
              ),
              CurrentWeatherCard(controller: _viewController),
              const SizedBox(height: 16),
              WeatherDetailsCard(controller: _viewController),
              const SizedBox(height: 16),
              ForecastList(controller: _viewController),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.1),
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Clima'),
              Tab(text: 'Surf/Pesca'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildWeatherTab(),
            Watch((context) {
              final state = _viewController.currentState.value;
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final weather = state.data;
              if (weather == null) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: WeatherSearchBar(
                      controller: searchController,
                      viewController: _viewController,
                      onSearch: _onSearch,
                    ),
                  ),
                  Expanded(
                    child: SurfFishPanel(
                      lat: weather.lat,
                      lng: weather.lon,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
