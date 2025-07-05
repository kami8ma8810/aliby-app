import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aliby/screens/trophy_history_screen.dart';
import 'package:aliby/providers/trophy_provider.dart';
import 'package:aliby/models/trophy.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TrophyHistoryScreen', () {
    late TrophyProvider trophyProvider;

    setUp(() {
      // SharedPreferencesのモックを初期化
      SharedPreferences.setMockInitialValues({});
      trophyProvider = TrophyProvider();
    });

    /// テスト用のウィジェットを作成
    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<TrophyProvider>.value(
          value: trophyProvider,
          child: const TrophyHistoryScreen(),
        ),
      );
    }

    testWidgets('should display empty state when no trophies', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('トロフィー履歴'), findsOneWidget);
      expect(find.text('まだトロフィーを獲得していません'), findsOneWidget);
      expect(find.text('生まれてからの節目の日にトロフィーが獲得できます'), findsOneWidget);
    });

    testWidgets('should display trophy list when trophies exist', (WidgetTester tester) async {
      // Arrange
      final now = DateTime.now();
      final trophy1 = Trophy(
        id: 'milestone_100',
        name: '100日記念',
        description: '生まれてから100日が経過しました！',
        acquiredAt: now.subtract(const Duration(days: 1)),
        icon: '🎉',
      );
      final trophy2 = Trophy(
        id: 'birthday_1',
        name: '1歳の誕生日',
        description: '1歳のお誕生日おめでとうございます！',
        acquiredAt: now.subtract(const Duration(days: 265)),
        icon: '🎂',
      );

      await trophyProvider.addTrophy(trophy1);
      await trophyProvider.addTrophy(trophy2);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('100日記念'), findsOneWidget);
      expect(find.text('1歳の誕生日'), findsOneWidget);
      expect(find.text('生まれてから100日が経過しました！'), findsOneWidget);
      expect(find.text('1歳のお誕生日おめでとうございます！'), findsOneWidget);
    });

    testWidgets('should display trophies in reverse chronological order', (WidgetTester tester) async {
      // Arrange
      final now = DateTime.now();
      final oldTrophy = Trophy(
        id: 'old_trophy',
        name: '古いトロフィー',
        description: '古い説明',
        acquiredAt: now.subtract(const Duration(days: 10)),
        icon: '🏆',
      );
      final newTrophy = Trophy(
        id: 'new_trophy',
        name: '新しいトロフィー',
        description: '新しい説明',
        acquiredAt: now.subtract(const Duration(days: 1)),
        icon: '🎯',
      );

      await trophyProvider.addTrophy(oldTrophy);
      await trophyProvider.addTrophy(newTrophy);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - 新しいトロフィーが先に表示される
      final trophyCards = find.byType(Card);
      expect(trophyCards, findsNWidgets(2));
      
      // 最初のカードに新しいトロフィーが表示されているか確認
      final firstCard = tester.widget<Card>(trophyCards.at(0));
      final firstListTile = tester.widget<ListTile>(
        find.descendant(
          of: find.byWidget(firstCard),
          matching: find.byType(ListTile),
        ),
      );
      expect((firstListTile.title as Text).data, '新しいトロフィー');
    });

    testWidgets('should display trophy icons', (WidgetTester tester) async {
      // Arrange
      final trophy = Trophy(
        id: 'test_trophy',
        name: 'テストトロフィー',
        description: 'テスト説明',
        acquiredAt: DateTime.now(),
        icon: '🏆',
      );

      await trophyProvider.addTrophy(trophy);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('🏆'), findsOneWidget);
    });

    testWidgets('should display acquired date for each trophy', (WidgetTester tester) async {
      // Arrange
      final acquiredDate = DateTime(2024, 3, 15, 14, 30);
      final trophy = Trophy(
        id: 'test_trophy',
        name: 'テストトロフィー',
        description: 'テスト説明',
        acquiredAt: acquiredDate,
        icon: '🏆',
      );

      await trophyProvider.addTrophy(trophy);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - 獲得日時が表示されている
      expect(find.textContaining('2024年3月15日'), findsOneWidget);
    });

    testWidgets('should have app bar with title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('トロフィー履歴'), findsOneWidget);
    });

    testWidgets('should be scrollable when many trophies exist', (WidgetTester tester) async {
      // Arrange - 多数のトロフィーを追加
      for (int i = 0; i < 20; i++) {
        final trophy = Trophy(
          id: 'trophy_$i',
          name: 'トロフィー$i',
          description: '説明$i',
          acquiredAt: DateTime.now().subtract(Duration(days: i)),
          icon: '🏆',
        );
        await trophyProvider.addTrophy(trophy);
      }

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - スクロール可能なウィジェットが存在する
      expect(find.byType(ListView), findsOneWidget);
      
      // スクロールできることを確認
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
    });
  });
}