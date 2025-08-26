import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:weather_app/domain/models/location.dart';
import 'package:weather_app/ui/controllers/weather_home_view_controller.dart';

class WeatherSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSearch;
  final WeatherHomeViewController viewController;

  const WeatherSearchBar({
    super.key,
    required this.controller,
    required this.viewController,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Digite o nome da cidade",
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
              ),
              suffixIcon: Watch(
                (_) => viewController.isLoading.value
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          onSearch?.call(controller.text);
                        },
                      ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
            onChanged: viewController.search,
            onSubmitted: (value) {
              FocusScope.of(context).unfocus();
              onSearch?.call(value);
            },
          ),
        ),
        Watch((_) {
          final list = viewController.suggestions.value;
          if (list.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (context, index) {
                final Location loc = list[index];
                return ListTile(
                  title: Text(loc.name),
                  subtitle: Text('${loc.region}, ${loc.country}'),
                  onTap: () {
                    controller.text = loc.name;
                    viewController.suggestions.value = [];
                    onSearch?.call(loc.name);
                  },
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
