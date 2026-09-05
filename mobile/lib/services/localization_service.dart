import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  String _currentLanguage = 'hi'; // Default Hindi
  Map<String, String> _localizedStrings = {};

  String get currentLanguage => _currentLanguage;

  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('dhatu_app_lang') ?? 'hi';
    await loadLanguage(_currentLanguage);
  }

  Future<void> loadLanguage(String langCode) async {
    _currentLanguage = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dhatu_app_lang', langCode);

    try {
      final jsonString = await rootBundle.loadString('assets/i18n/$langCode.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      // Fallback
      _localizedStrings = {};
    }
    notifyListeners();
  }

  String tr(String key, {Map<String, String>? params}) {
    String text = _localizedStrings[key] ?? key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }
    return text;
  }
}
