import 'package:flutter/material.dart';
import 'package:weather_app/core/di/injector.dart';
import 'package:weather_app/core/theme/app_theme.dart';
import 'package:weather_app/ui/views/weather_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initInjector();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Previsão do Tempo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const WeatherHomePage(title: 'Aula Nova Saindo do Forno'),
    ),
  );
}
