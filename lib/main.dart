import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:weather_app/core/di/injector.dart';
import 'package:weather_app/core/theme/app_theme.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:weather_app/ui/views/weather_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initInjector();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        AppLocalizations.delegate,
      ],
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) => WeatherHomePage(
          title: AppLocalizations.of(context).homeTitle,
        ),
      ),
    ),
  );
}
