import 'package:flutter_test/flutter_test.dart';
import 'package:aliby/providers/user_provider.dart';
import 'package:aliby/models/user_data.dart';
import 'package:aliby/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UserProvider', () {
    late UserProvider userProvider;
    
    setUp(() {
      // SharedPreferencesのモックを初期化
      SharedPreferences.setMockInitialValues({});
      userProvider = UserProvider();
    });

    test('should have null userData initially', () {
      expect(userProvider.userData, isNull);
      expect(userProvider.hasUserData, isFalse);
    });

    test('should set userData', () async {
      // Arrange
      final birthdate = DateTime(2000, 1, 1);
      final userData = UserData(birthdate: birthdate);
      
      // Act
      await userProvider.setUserData(userData);
      
      // Assert
      expect(userProvider.userData, isNotNull);
      expect(userProvider.userData!.birthdate, equals(birthdate));
      expect(userProvider.hasUserData, isTrue);
    });

    test('should save userData to storage when setting', () async {
      // Arrange
      final birthdate = DateTime(2000, 1, 1);
      final userData = UserData(birthdate: birthdate);
      
      // Act
      await userProvider.setUserData(userData);
      
      // Assert - データが保存されているか確認
      final storageService = StorageService();
      final savedData = await storageService.loadUserData();
      expect(savedData, isNotNull);
      expect(savedData!.birthdate, equals(birthdate));
    });

    test('should load userData from storage', () async {
      // Arrange - 先にストレージに保存
      final birthdate = DateTime(2000, 1, 1);
      final userData = UserData(birthdate: birthdate);
      final storageService = StorageService();
      await storageService.saveUserData(userData);
      
      // Act
      await userProvider.loadUserData();
      
      // Assert
      expect(userProvider.userData, isNotNull);
      expect(userProvider.userData!.birthdate, equals(birthdate));
      expect(userProvider.hasUserData, isTrue);
    });

    test('should clear userData', () async {
      // Arrange
      final birthdate = DateTime(2000, 1, 1);
      final userData = UserData(birthdate: birthdate);
      await userProvider.setUserData(userData);
      
      // Act
      await userProvider.clearUserData();
      
      // Assert
      expect(userProvider.userData, isNull);
      expect(userProvider.hasUserData, isFalse);
      
      // ストレージからも削除されているか確認
      final storageService = StorageService();
      final savedData = await storageService.loadUserData();
      expect(savedData, isNull);
    });

    test('should calculate age in days', () async {
      // Arrange
      final daysAgo = 100;
      final birthdate = DateTime.now().subtract(Duration(days: daysAgo));
      final userData = UserData(birthdate: birthdate);
      
      // Act
      await userProvider.setUserData(userData);
      
      // Assert
      expect(userProvider.ageInDays, equals(daysAgo));
    });

    test('should return 0 for ageInDays when no userData', () {
      expect(userProvider.ageInDays, equals(0));
    });

    test('should calculate age components', () async {
      // Arrange
      final now = DateTime.now();
      final birthdate = now.subtract(const Duration(
        days: 100,
        hours: 10,
        minutes: 30,
        seconds: 45,
      ));
      final userData = UserData(birthdate: birthdate);
      
      // Act
      await userProvider.setUserData(userData);
      final components = userProvider.getAgeComponents();
      
      // Assert
      expect(components['days'], equals(100));
      expect(components['hours'], greaterThanOrEqualTo(10));
      expect(components['minutes'], greaterThanOrEqualTo(0));
      expect(components['seconds'], greaterThanOrEqualTo(0));
    });

    test('should return empty map for age components when no userData', () {
      final components = userProvider.getAgeComponents();
      expect(components, isEmpty);
    });

    test('should notify listeners when userData changes', () async {
      // Arrange
      final birthdate = DateTime(2000, 1, 1);
      final userData = UserData(birthdate: birthdate);
      var notificationCount = 0;
      
      userProvider.addListener(() {
        notificationCount++;
      });
      
      // Act
      await userProvider.setUserData(userData);
      
      // Assert
      expect(notificationCount, equals(1));
    });
  });
}