import 'package:flutter/material.dart';
import 'package:nasa_app/utils/hive_functions.dart';

class LanguageProvider with ChangeNotifier {
  String _code = 'en'; // default
  LanguageProvider() {
    _loadFromHive();
  }

  String get code => _code;
  Locale get locale => Locale(_code);

  Future<void> _loadFromHive() async {
    try {
      final stored = await HiveFunctions.getData('lang');
      if (stored is String && stored.isNotEmpty) {
        _code = stored;
        notifyListeners();
      }
    } catch (e) {
      // optional: print('Hive load lang error: $e');
    }
  }

  Future<void> changeLanguage(String code) async {
    if (code == _code) return;
    _code = code;
    await HiveFunctions.putData('lang', code);
    notifyListeners();
  }
}
