import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aliby/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsProvider', () {
    late SettingsProvider settingsProvider;

    setUp(() {
      // SharedPreferencesのモックを初期化
      SharedPreferences.setMockInitialValues({});
      settingsProvider = SettingsProvider();
    });

    test('should have default values initially', () {
      // Assert
      expect(settingsProvider.isDarkMode, isFalse);
      expect(settingsProvider.isRealtimeEnabled, isTrue);
      expect(settingsProvider.themeMode, ThemeMode.light);
    });

    test('should toggle dark mode', () async {
      // Arrange
      expect(settingsProvider.isDarkMode, isFalse);

      // Act
      await settingsProvider.toggleDarkMode();

      // Assert
      expect(settingsProvider.isDarkMode, isTrue);
      expect(settingsProvider.themeMode, ThemeMode.dark);
    });

    test('should toggle realtime display', () async {
      // Arrange
      expect(settingsProvider.isRealtimeEnabled, isTrue);

      // Act
      await settingsProvider.toggleRealtimeDisplay();

      // Assert
      expect(settingsProvider.isRealtimeEnabled, isFalse);
    });

    test('should save and load settings', () async {
      // Arrange
      await settingsProvider.toggleDarkMode();
      await settingsProvider.toggleRealtimeDisplay();

      // Act - 新しいインスタンスを作成してロード
      final newProvider = SettingsProvider();
      await newProvider.loadSettings();

      // Assert
      expect(newProvider.isDarkMode, isTrue);
      expect(newProvider.isRealtimeEnabled, isFalse);
    });

    test('should notify listeners when settings change', () async {
      // Arrange
      var notifiedCount = 0;
      settingsProvider.addListener(() {
        notifiedCount++;
      });

      // Act
      await settingsProvider.toggleDarkMode();
      await settingsProvider.toggleRealtimeDisplay();

      // Assert
      expect(notifiedCount, 2);
    });

    test('should handle missing preferences gracefully', () async {
      // Arrange - 空のSharedPreferencesで初期化
      SharedPreferences.setMockInitialValues({});
      
      // Act - 新しいインスタンスを作成
      final newProvider = SettingsProvider();
      await newProvider.loadSettings();

      // Assert - デフォルト値が使用される
      expect(newProvider.isDarkMode, isFalse);
      expect(newProvider.isRealtimeEnabled, isTrue);
    });

    test('should update theme mode correctly', () async {
      // Act & Assert - ライトモードからダークモードへ
      expect(settingsProvider.themeMode, ThemeMode.light);
      await settingsProvider.toggleDarkMode();
      expect(settingsProvider.themeMode, ThemeMode.dark);
      
      // Act & Assert - ダークモードからライトモードへ
      await settingsProvider.toggleDarkMode();
      expect(settingsProvider.themeMode, ThemeMode.light);
    });
  });
}