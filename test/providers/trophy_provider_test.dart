import 'package:flutter_test/flutter_test.dart';
import 'package:aliby/providers/trophy_provider.dart';
import 'package:aliby/models/trophy.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TrophyProvider', () {
    late TrophyProvider trophyProvider;

    setUp(() {
      // SharedPreferencesのモックを初期化
      SharedPreferences.setMockInitialValues({});
      trophyProvider = TrophyProvider();
    });

    test('should initialize with no trophies', () {
      // Assert
      expect(trophyProvider.trophies, isEmpty);
      expect(trophyProvider.hasTrophies, isFalse);
    });

    test('should check and add milestone trophy', () async {
      // Arrange
      final testDate = DateTime(2000, 1, 1);
      final currentDate = testDate.add(const Duration(days: 100));

      // Act
      await trophyProvider.checkAndAddTrophy(testDate, currentDate);

      // Assert
      expect(trophyProvider.trophies, hasLength(1));
      expect(trophyProvider.trophies.first.id, 'milestone_100');
      expect(trophyProvider.trophies.first.name, '100日記念');
    });

    test('should check and add birthday trophy', () async {
      // Arrange
      final testDate = DateTime(2000, 1, 1);
      final currentDate = DateTime(2001, 1, 1); // 1歳の誕生日

      // Act
      await trophyProvider.checkAndAddTrophy(testDate, currentDate);

      // Assert
      expect(trophyProvider.trophies, hasLength(1));
      expect(trophyProvider.trophies.first.id, 'birthday_1');
      expect(trophyProvider.trophies.first.name, '1歳の誕生日');
    });

    test('should check and add repdigit trophy', () async {
      // Arrange
      final testDate = DateTime(2000, 1, 1);
      final currentDate = testDate.add(const Duration(days: 1111));

      // Act
      await trophyProvider.checkAndAddTrophy(testDate, currentDate);

      // Assert
      expect(trophyProvider.trophies, hasLength(1));
      expect(trophyProvider.trophies.first.id, 'repdigit_1111');
      expect(trophyProvider.trophies.first.name, '1111日達成');
    });

    test('should not add duplicate trophies', () async {
      // Arrange
      final testDate = DateTime(2000, 1, 1);
      final currentDate = testDate.add(const Duration(days: 100));

      // Act - 2回同じトロフィーをチェック
      await trophyProvider.checkAndAddTrophy(testDate, currentDate);
      await trophyProvider.checkAndAddTrophy(testDate, currentDate);

      // Assert
      expect(trophyProvider.trophies, hasLength(1));
    });

    test('should save and load trophies', () async {
      // Arrange
      final trophy = Trophy(
        id: 'test_trophy',
        name: 'テストトロフィー',
        description: 'テスト用のトロフィー',
        acquiredAt: DateTime.now(),
        icon: '🏆',
      );

      // Act
      await trophyProvider.addTrophy(trophy);
      
      // 新しいインスタンスを作成してロード
      final newProvider = TrophyProvider();
      await newProvider.loadTrophies();

      // Assert
      expect(newProvider.trophies, hasLength(1));
      expect(newProvider.trophies.first.id, 'test_trophy');
    });

    test('should get trophies sorted by date', () async {
      // Arrange
      final now = DateTime.now();
      final trophy1 = Trophy(
        id: 'trophy1',
        name: 'トロフィー1',
        description: '説明1',
        acquiredAt: now.subtract(const Duration(days: 2)),
        icon: '🏆',
      );
      final trophy2 = Trophy(
        id: 'trophy2',
        name: 'トロフィー2',
        description: '説明2',
        acquiredAt: now.subtract(const Duration(days: 1)),
        icon: '🎯',
      );
      final trophy3 = Trophy(
        id: 'trophy3',
        name: 'トロフィー3',
        description: '説明3',
        acquiredAt: now.subtract(const Duration(days: 3)),
        icon: '🎉',
      );

      // Act
      await trophyProvider.addTrophy(trophy1);
      await trophyProvider.addTrophy(trophy2);
      await trophyProvider.addTrophy(trophy3);

      // Assert - 新しい順にソートされているか確認
      expect(trophyProvider.trophies[0].id, 'trophy2');
      expect(trophyProvider.trophies[1].id, 'trophy1');
      expect(trophyProvider.trophies[2].id, 'trophy3');
    });

    test('should notify listeners when trophy is added', () async {
      // Arrange
      var notifiedCount = 0;
      trophyProvider.addListener(() {
        notifiedCount++;
      });

      final trophy = Trophy(
        id: 'test_trophy',
        name: 'テストトロフィー',
        description: 'テスト用のトロフィー',
        acquiredAt: DateTime.now(),
        icon: '🏆',
      );

      // Act
      await trophyProvider.addTrophy(trophy);

      // Assert
      expect(notifiedCount, 1);
    });
  });
}