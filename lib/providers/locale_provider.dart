import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 言語設定を管理するProvider
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  
  Locale _locale = const Locale('ja', 'JP'); // デフォルトは日本語
  
  /// 現在の言語設定
  Locale get locale => _locale;
  
  /// 日本語かどうか
  bool get isJapanese => _locale.languageCode == 'ja';
  
  /// 英語かどうか
  bool get isEnglish => _locale.languageCode == 'en';
  
  /// 初期化
  Future<void> initialize() async {
    await _loadLocale();
  }
  
  /// 言語を設定
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    await _saveLocale();
    notifyListeners();
  }
  
  /// 日本語に設定
  Future<void> setJapanese() async {
    await setLocale(const Locale('ja', 'JP'));
  }
  
  /// 英語に設定
  Future<void> setEnglish() async {
    await setLocale(const Locale('en', 'US'));
  }
  
  /// 言語を切り替え
  Future<void> toggleLanguage() async {
    if (isJapanese) {
      await setEnglish();
    } else {
      await setJapanese();
    }
  }
  
  /// ローカルストレージから言語設定を読み込み
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeString = prefs.getString(_localeKey);
      
      if (localeString != null) {
        final parts = localeString.split('_');
        if (parts.length == 2) {
          _locale = Locale(parts[0], parts[1]);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Failed to load locale: $e');
    }
  }
  
  /// ローカルストレージに言語設定を保存
  Future<void> _saveLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, '${_locale.languageCode}_${_locale.countryCode}');
    } catch (e) {
      debugPrint('Failed to save locale: $e');
    }
  }
  
  /// 言語設定をクリア
  Future<void> clearLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localeKey);
      _locale = const Locale('ja', 'JP'); // デフォルトに戻す
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to clear locale: $e');
    }
  }
}