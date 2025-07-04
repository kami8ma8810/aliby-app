import 'package:flutter_test/flutter_test.dart';
import 'package:aliby/models/trophy.dart';

void main() {
  group('Trophy', () {
    test('should create Trophy with required fields', () {
      final trophy = Trophy(
        id: 'first_100_days',
        name: '100日記念',
        description: '生まれてから100日が経ちました！',
        icon: '🎉',
        acquiredAt: DateTime(2024, 1, 1),
      );
      
      expect(trophy.id, equals('first_100_days'));
      expect(trophy.name, equals('100日記念'));
      expect(trophy.description, equals('生まれてから100日が経ちました！'));
      expect(trophy.icon, equals('🎉'));
      expect(trophy.acquiredAt, equals(DateTime(2024, 1, 1)));
    });

    test('should convert to JSON', () {
      final acquiredAt = DateTime(2024, 1, 1);
      final trophy = Trophy(
        id: 'first_100_days',
        name: '100日記念',
        description: '生まれてから100日が経ちました！',
        icon: '🎉',
        acquiredAt: acquiredAt,
      );
      
      final json = trophy.toJson();
      
      expect(json['id'], equals('first_100_days'));
      expect(json['name'], equals('100日記念'));
      expect(json['description'], equals('生まれてから100日が経ちました！'));
      expect(json['icon'], equals('🎉'));
      expect(json['acquiredAt'], equals(acquiredAt.toIso8601String()));
    });

    test('should create from JSON', () {
      final acquiredAt = DateTime(2024, 1, 1);
      final json = {
        'id': 'first_100_days',
        'name': '100日記念',
        'description': '生まれてから100日が経ちました！',
        'icon': '🎉',
        'acquiredAt': acquiredAt.toIso8601String(),
      };
      
      final trophy = Trophy.fromJson(json);
      
      expect(trophy.id, equals('first_100_days'));
      expect(trophy.name, equals('100日記念'));
      expect(trophy.description, equals('生まれてから100日が経ちました！'));
      expect(trophy.icon, equals('🎉'));
      expect(trophy.acquiredAt, equals(acquiredAt));
    });
  });

  group('TrophyCondition', () {
    test('should create days condition', () {
      final condition = TrophyCondition(
        type: TrophyConditionType.days,
        value: 100,
      );
      
      expect(condition.type, equals(TrophyConditionType.days));
      expect(condition.value, equals(100));
    });

    test('should create years condition', () {
      final condition = TrophyCondition(
        type: TrophyConditionType.years,
        value: 1,
      );
      
      expect(condition.type, equals(TrophyConditionType.years));
      expect(condition.value, equals(1));
    });

    test('should create specific days condition', () {
      final condition = TrophyCondition(
        type: TrophyConditionType.specificDays,
        value: 1111,
      );
      
      expect(condition.type, equals(TrophyConditionType.specificDays));
      expect(condition.value, equals(1111));
    });

    test('should convert to JSON', () {
      final condition = TrophyCondition(
        type: TrophyConditionType.days,
        value: 100,
      );
      
      final json = condition.toJson();
      
      expect(json['type'], equals('days'));
      expect(json['value'], equals(100));
    });

    test('should create from JSON', () {
      final json = {
        'type': 'years',
        'value': 5,
      };
      
      final condition = TrophyCondition.fromJson(json);
      
      expect(condition.type, equals(TrophyConditionType.years));
      expect(condition.value, equals(5));
    });
  });

  group('TrophyConfig', () {
    test('should create TrophyConfig', () {
      final config = TrophyConfig(
        id: 'first_100_days',
        name: '100日記念',
        description: '生まれてから100日が経ちました！',
        condition: TrophyCondition(
          type: TrophyConditionType.days,
          value: 100,
        ),
        icon: '🎉',
      );
      
      expect(config.id, equals('first_100_days'));
      expect(config.name, equals('100日記念'));
      expect(config.description, equals('生まれてから100日が経ちました！'));
      expect(config.icon, equals('🎉'));
      expect(config.condition.type, equals(TrophyConditionType.days));
      expect(config.condition.value, equals(100));
    });

    test('should convert to JSON', () {
      final config = TrophyConfig(
        id: 'first_year',
        name: '1歳の誕生日',
        description: '記念すべき1歳の誕生日です！',
        condition: TrophyCondition(
          type: TrophyConditionType.years,
          value: 1,
        ),
        icon: '🎂',
      );
      
      final json = config.toJson();
      
      expect(json['id'], equals('first_year'));
      expect(json['name'], equals('1歳の誕生日'));
      expect(json['description'], equals('記念すべき1歳の誕生日です！'));
      expect(json['icon'], equals('🎂'));
      expect(json['condition']['type'], equals('years'));
      expect(json['condition']['value'], equals(1));
    });

    test('should create from JSON', () {
      final json = {
        'id': 'repdigit_1111',
        'name': 'ゾロ目記念日',
        'description': '1111日目です！',
        'condition': {
          'type': 'specific_days',
          'value': 1111,
        },
        'icon': '1️⃣',
      };
      
      final config = TrophyConfig.fromJson(json);
      
      expect(config.id, equals('repdigit_1111'));
      expect(config.name, equals('ゾロ目記念日'));
      expect(config.description, equals('1111日目です！'));
      expect(config.icon, equals('1️⃣'));
      expect(config.condition.type, equals(TrophyConditionType.specificDays));
      expect(config.condition.value, equals(1111));
    });
  });
}