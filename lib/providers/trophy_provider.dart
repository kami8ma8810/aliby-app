import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trophy.dart';

/// トロフィーの状態を管理するProvider
/// 獲得したトロフィーの履歴を保持し、新しいトロフィーの判定も行う
/// 
/// ChangeNotifierについて：
/// https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html
class TrophyProvider extends ChangeNotifier {
  static const String _trophiesKey = 'trophies';
  
  List<Trophy> _trophies = [];
  
  /// 獲得済みトロフィーのリスト（新しい順）
  List<Trophy> get trophies => List.unmodifiable(
    _trophies..sort((a, b) => b.acquiredAt.compareTo(a.acquiredAt))
  );
  
  /// トロフィーを持っているかどうか
  bool get hasTrophies => _trophies.isNotEmpty;
  
  TrophyProvider() {
    loadTrophies();
  }
  
  /// トロフィーをチェックして追加
  /// birthdate: 生年月日
  /// currentDate: 現在の日時（テスト用にパラメータ化）
  Future<void> checkAndAddTrophy(DateTime birthdate, DateTime currentDate) async {
    final daysSinceBirth = currentDate.difference(birthdate).inDays;
    final age = _calculateAge(birthdate, currentDate);
    
    // 100日ごとの記念日チェック
    if (daysSinceBirth > 0 && daysSinceBirth % 100 == 0) {
      final trophy = Trophy(
        id: 'milestone_$daysSinceBirth',
        name: '$daysSinceBirth日記念',
        description: '生まれてから$daysSinceBirth日が経過しました！',
        acquiredAt: currentDate,
        icon: '🎉',
      );
      await addTrophy(trophy);
    }
    
    // 誕生日チェック
    if (birthdate.month == currentDate.month && 
        birthdate.day == currentDate.day && 
        age > 0) {
      final trophy = Trophy(
        id: 'birthday_$age',
        name: '$age歳の誕生日',
        description: '$age歳のお誕生日おめでとうございます！',
        acquiredAt: currentDate,
        icon: '🎂',
      );
      await addTrophy(trophy);
    }
    
    // ゾロ目の日数チェック
    if (_isRepdigit(daysSinceBirth) && daysSinceBirth > 0) {
      final trophy = Trophy(
        id: 'repdigit_$daysSinceBirth',
        name: '$daysSinceBirth日達成',
        description: 'ゾロ目の$daysSinceBirth日を達成しました！',
        acquiredAt: currentDate,
        icon: '🎯',
      );
      await addTrophy(trophy);
    }
  }
  
  /// トロフィーを追加（重複チェック付き）
  Future<void> addTrophy(Trophy trophy) async {
    // 既に同じIDのトロフィーがある場合は追加しない
    if (_trophies.any((t) => t.id == trophy.id)) {
      return;
    }
    
    _trophies.add(trophy);
    await _saveTrophies();
    notifyListeners();
  }
  
  /// トロフィーをローカルストレージから読み込み
  Future<void> loadTrophies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trophiesJson = prefs.getString(_trophiesKey);
      
      if (trophiesJson != null) {
        final List<dynamic> decoded = json.decode(trophiesJson);
        _trophies = decoded.map((json) => Trophy.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      // TODO: エラーハンドリング（本番環境ではログ出力など）
      debugPrint('Failed to load trophies: $e');
    }
  }
  
  /// トロフィーをローカルストレージに保存
  Future<void> _saveTrophies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trophiesJson = json.encode(
        _trophies.map((trophy) => trophy.toJson()).toList()
      );
      await prefs.setString(_trophiesKey, trophiesJson);
    } catch (e) {
      // TODO: エラーハンドリング（本番環境ではログ出力など）
      debugPrint('Failed to save trophies: $e');
    }
  }
  
  /// 年齢を計算
  int _calculateAge(DateTime birthdate, DateTime currentDate) {
    int age = currentDate.year - birthdate.year;
    if (currentDate.month < birthdate.month ||
        (currentDate.month == birthdate.month && currentDate.day < birthdate.day)) {
      age--;
    }
    return age;
  }
  
  /// ゾロ目かどうかチェック
  bool _isRepdigit(int number) {
    if (number <= 0) return false;
    final str = number.toString();
    return str.length > 1 && str.split('').every((digit) => digit == str[0]);
  }
}