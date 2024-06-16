import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const List<Map<String, dynamic>> languages = [
    {
      'name': 'English',
      'locale': 'en',
    },
    {
      'name': 'हिंदी',
      'locale': 'hi',
    },
    {
      'name': 'தமிழ்',
      'locale': 'ta',
    },
    {
      'name': 'বাংলা',
      'locale': 'bn',
    },
    {
      'name': 'ગુજરાતી',
      'locale': 'gu',
    },
    {
      'name': 'ಕನ್ನಡ',
      'locale': 'kn',
    },
    {
      'name': 'മലയാളം',
      'locale': 'ml',
    },
    {
      'name': 'मराठी',
      'locale': 'mr',
    },
    {
      'name': 'ਪੰਜਾਬੀ',
      'locale': 'pa',
    },
    {
      'name': 'తెలుగు',
      'locale': 'te',
    },
    {
      'name': 'ଓଡ଼ିଆ',
      'locale': 'or',
    },
    {
      'name': 'اردو',
      'locale': 'ur',
    },
  ];

  Locale selectedLocale = const Locale('en');

  void changeLanguage(String language) async {
    selectedLocale = Locale(language);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
    notifyListeners();
  }

  Future<void> loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('selectedLanguage');
    if (language != null) {
      selectedLocale = Locale(language);
      notifyListeners();
    }
  }
}
