import 'package:flutter_test/flutter_test.dart';
import 'package:aliby/models/user_data.dart';

void main() {
  group('UserData', () {
    test('should create UserData with birthdate', () {
      final birthdate = DateTime(2000, 1, 1);
      final userData = UserData(birthdate: birthdate);
      
      expect(userData.birthdate, equals(birthdate));
    });

    test('should convert to JSON', () {
      final birthdate = DateTime(2000, 1, 1);
      final userData = UserData(birthdate: birthdate);
      final json = userData.toJson();
      
      expect(json['birthdate'], equals(birthdate.toIso8601String()));
    });

    test('should create from JSON', () {
      final birthdate = DateTime(2000, 1, 1);
      final json = {'birthdate': birthdate.toIso8601String()};
      final userData = UserData.fromJson(json);
      
      expect(userData.birthdate, equals(birthdate));
    });

    test('should calculate age in days', () {
      final birthdate = DateTime.now().subtract(const Duration(days: 100));
      final userData = UserData(birthdate: birthdate);
      
      expect(userData.ageInDays, equals(100));
    });

    test('should calculate age in years', () {
      final now = DateTime.now();
      final birthdate = DateTime(now.year - 25, now.month, now.day);
      final userData = UserData(birthdate: birthdate);
      
      expect(userData.ageInYears, equals(25));
    });

    test('should calculate detailed age components', () {
      final now = DateTime.now();
      final birthdate = now.subtract(const Duration(
        days: 100,
        hours: 10,
        minutes: 30,
        seconds: 45,
      ));
      final userData = UserData(birthdate: birthdate);
      final ageComponents = userData.getAgeComponents(now);
      
      expect(ageComponents['days'], equals(100));
      expect(ageComponents['hours'], equals(10));
      expect(ageComponents['minutes'], equals(30));
      expect(ageComponents['seconds'], equals(45));
    });
  });
}