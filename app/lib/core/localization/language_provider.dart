import 'package:flutter/material.dart';
import 'app_strings.dart';

/// Pure Flutter language state controller for English and Hindi.
class LanguageProvider extends ChangeNotifier {
  String _currentLocale = 'en';

  String get currentLocale => _currentLocale;
  bool get isHindi => _currentLocale == 'hi';

  void setLocale(String locale) {
    if (_currentLocale != locale && (locale == 'en' || locale == 'hi')) {
      _currentLocale = locale;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _currentLocale = _currentLocale == 'en' ? 'hi' : 'en';
    notifyListeners();
  }

  String tr(String key) {
    return AppStrings.get(key, locale: _currentLocale);
  }
}
