import 'package:flutter/material.dart';
import 'package:weather_app/ui/controllers/weather_home_view_controller.dart';
import 'package:weather_app/ui/widgets/surf_fish_panel.dart';
import 'package:weather_app/ui/widgets/weather_search_bar.dart';

class SurfFishTab extends StatelessWidget {
  final WeatherHomeViewController controller;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;

  const SurfFishTab({
    super.key,
    required this.controller,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: WeatherSearchBar(
            controller: searchController,
            viewController: controller,
            onSearch: onSearch,
          ),
        ),
        Expanded(
          child: SurfFishPanel(controller: controller),
        ),
      ],
    );
  }
}
