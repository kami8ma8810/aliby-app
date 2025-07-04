import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aliby/services/storage_service.dart';
import 'package:aliby/models/user_data.dart';

void main() {
  group('StorageService', () {
    late StorageService storageService;
    
    /// setUpはテストグループ内の各テストの前に実行される
    /// https://api.flutter.dev/flutter/flutter_test/setUp.html
    setUp(() {
      // SharedPreferencesのモックを設定
      // テスト環境では実際のストレージを使わずメモリ上でシミュレート
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
    });

    test('should save user data', () async {
      // Arrange（準備）
      final birthdate = DateTime(2000, 1, 1);
      final userData = UserData(birthdate: birthdate);
      
      // Act（実行）
      final result = await storageService.saveUserData(userData);
      
      // Assert（検証）
      expect(result, isTrue);
    });

    test('should load user data when exists', () async {
      // Arrange
      final birthdate = DateTime(2000, 1, 1);
      final userData = UserData(birthdate: birthdate);
      
      // まず保存
      await storageService.saveUserData(userData);
      
      // Act
      final loadedData = await storageService.loadUserData();
      
      // Assert
      expect(loadedData, isNotNull);
      expect(loadedData!.birthdate, equals(birthdate));
    });

    test('should return null when no user data exists', () async {
      // Act
      final loadedData = await storageService.loadUserData();
      
      // Assert
      expect(loadedData, isNull);
    });

    test('should check if user data exists', () async {
      // Arrange
      final birthdate = DateTime(2000, 1, 1);
      final userData = UserData(birthdate: birthdate);
      
      // Act & Assert（データがない場合）
      expect(await storageService.hasUserData(), isFalse);
      
      // データを保存
      await storageService.saveUserData(userData);
      
      // Act & Assert（データがある場合）
      expect(await storageService.hasUserData(), isTrue);
    });

    test('should clear user data', () async {
      // Arrange
      final birthdate = DateTime(2000, 1, 1);
      final userData = UserData(birthdate: birthdate);
      await storageService.saveUserData(userData);
      
      // Act
      final result = await storageService.clearUserData();
      
      // Assert
      expect(result, isTrue);
      expect(await storageService.hasUserData(), isFalse);
    });
  });
}