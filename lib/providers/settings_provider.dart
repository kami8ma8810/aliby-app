import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アプリの設定を管理するProvider
/// テーマやリアルタイム表示のON/OFFなどの設定を保持
/// 
/// ChangeNotifierについて：
/// https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html
class SettingsProvider extends ChangeNotifier {
  static const String _darkModeKey = 'isDarkMode';
  static const String _realtimeKey = 'isRealtimeEnabled';
  
  bool _isDarkMode = false;
  bool _isRealtimeEnabled = true;
  
  /// ダークモードが有効かどうか
  bool get isDarkMode => _isDarkMode;
  
  /// リアルタイム表示が有効かどうか
  bool get isRealtimeEnabled => _isRealtimeEnabled;
  
  /// 現在のテーマモード
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  
  SettingsProvider();
  
  /// 初期化メソッド（アプリ起動時に呼び出す）
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
      _isRealtimeEnabled = prefs.getBool(_realtimeKey) ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize settings: $e');
    }
  }
  
  /// ダークモードの切り替え
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _saveSettings();
    notifyListeners();
  }
  
  /// リアルタイム表示の切り替え
  Future<void> toggleRealtimeDisplay() async {
    _isRealtimeEnabled = !_isRealtimeEnabled;
    await _saveSettings();
    notifyListeners();
  }
  
  /// 設定をローカルストレージから読み込み
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // ダークモード設定を読み込み（デフォルト: false）
      _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
      
      // リアルタイム表示設定を読み込み（デフォルト: true）
      _isRealtimeEnabled = prefs.getBool(_realtimeKey) ?? true;
      
      notifyListeners();
    } catch (e) {
      // エラーが発生した場合はデフォルト値を使用
      // TODO: 本番環境ではログ出力など
      debugPrint('Failed to load settings: $e');
    }
  }
  
  /// 設定をローカルストレージに保存
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, _isDarkMode);
      await prefs.setBool(_realtimeKey, _isRealtimeEnabled);
    } catch (e) {
      // TODO: 本番環境ではログ出力など
      debugPrint('Failed to save settings: $e');
    }
  }
}