import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this._localizedStrings);

  final Map<String, String> _localizedStrings;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static Future<AppLocalizations> load(Locale locale) async {
    final jsonString = await rootBundle.loadString('lib/l10n/app_${locale.languageCode}.arb');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final strings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return AppLocalizations(strings);
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String _get(String key) => _localizedStrings[key] ?? key;

  String get appTitle => _get('appTitle');
  String get homeTitle => _get('homeTitle');
  String get tryAgain => _get('tryAgain');
  String get errorPrefix => _get('errorPrefix');
  String get weatherDetailsTitle => _get('weatherDetailsTitle');
  String get humidity => _get('humidity');
  String get wind => _get('wind');
  String searchingCity(String city) => _get('searchingCity').replaceFirst('{city}', city);
  String get hintCityName => _get('hintCityName');
  String get currentConditions => _get('currentConditions');
  String get wave => _get('wave');
  String get swell => _get('swell');
  String get water => _get('water');
  String get noCurrentData => _get('noCurrentData');
  String get nextTides => _get('nextTides');
  String get idealWindows => _get('idealWindows');
  String get tideHigh => _get('tideHigh');
  String get tideLow => _get('tideLow');
  String get forecastNextDays => _get('forecastNextDays');
  String get airQuality => _get('airQuality');
  String get usEpaIndex => _get('usEpaIndex');
  String get pollen => _get('pollen');
  String get trees => _get('trees');
  String get herbs => _get('herbs');
  String get grass => _get('grass');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['pt'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
