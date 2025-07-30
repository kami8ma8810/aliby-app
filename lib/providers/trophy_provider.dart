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
    
    // 特別な記念日チェック
    if (daysSinceBirth > 0) {
      bool isMilestone = false;
      String trophyName = '';
      String trophyIcon = '🎉';
      
      if (daysSinceBirth == 100) {
        isMilestone = true;
        trophyName = '100日記念';
        trophyIcon = '🌱';
      } else if (daysSinceBirth == 500) {
        isMilestone = true;
        trophyName = '500日記念';
        trophyIcon = '🌿';
      } else if (daysSinceBirth == 1000) {
        isMilestone = true;
        trophyName = '1000日記念';
        trophyIcon = '🌳';
      } else if (daysSinceBirth >= 2000 && daysSinceBirth < 10000 && daysSinceBirth % 1000 == 0) {
        // 2000日〜9000日は1000日ごと
        isMilestone = true;
        trophyName = '$daysSinceBirth日記念';
        trophyIcon = '🎊';
      } else if (daysSinceBirth >= 10000 && daysSinceBirth % 10000 == 0) {
        // 10000日以降は10000日ごと
        isMilestone = true;
        trophyName = '$daysSinceBirth日記念';
        trophyIcon = '🏆';
      }
      
      if (isMilestone) {
        final trophy = Trophy(
          id: 'milestone_$daysSinceBirth',
          name: trophyName,
          description: '生まれてから$daysSinceBirth日が経過しました！',
          acquiredAt: currentDate,
          icon: trophyIcon,
        );
        await addTrophy(trophy);
      }
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
  
  /// 全てのトロフィーをクリア
  Future<void> clearTrophies() async {
    try {
      _trophies.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_trophiesKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to clear trophies: $e');
    }
  }
  
  
  /// 初回登録時に過去のトロフィーをチェック
  /// birthdate: 生年月日
  /// currentDate: 現在の日時
  Future<void> checkPastTrophies(DateTime birthdate, DateTime currentDate) async {
    final daysSinceBirth = currentDate.difference(birthdate).inDays;
    
    // 特別な記念日を遡ってチェック
    List<int> milestones = [100, 500, 1000];
    
    // 2000日〜9000日は1000日ごと
    for (int days = 2000; days < 10000 && days <= daysSinceBirth; days += 1000) {
      milestones.add(days);
    }
    
    // 10000日以降は10000日ごと
    for (int days = 10000; days <= daysSinceBirth; days += 10000) {
      milestones.add(days);
    }
    
    for (int days in milestones) {
      if (days <= daysSinceBirth) {
        final trophyDate = birthdate.add(Duration(days: days));
        String trophyName = '';
        String trophyIcon = '🎉';
        
        if (days == 100) {
          trophyName = '100日記念';
          trophyIcon = '🌱';
        } else if (days == 500) {
          trophyName = '500日記念';
          trophyIcon = '🌿';
        } else if (days == 1000) {
          trophyName = '1000日記念';
          trophyIcon = '🌳';
        } else if (days < 10000) {
          trophyName = '$days日記念';
          trophyIcon = '🎊';
        } else {
          trophyName = '$days日記念';
          trophyIcon = '🏆';
        }
        
        final trophy = Trophy(
          id: 'milestone_$days',
          name: trophyName,
          description: '生まれてから$days日が経過しました！',
          acquiredAt: trophyDate,
          icon: trophyIcon,
        );
        await addTrophy(trophy);
      }
    }
    
    // 保存後に通知
    await _saveTrophies();
    notifyListeners();
  }
}