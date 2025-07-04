/// トロフィーに関連するモデルクラス群
/// 
/// このファイルには以下が含まれる：
/// - Trophy: 獲得済みトロフィー
/// - TrophyCondition: トロフィー獲得条件
/// - TrophyConfig: トロフィー定義

/// トロフィー獲得条件のタイプを定義する列挙型（enum）
/// 
/// Dartのenumについて：
/// https://dart.dev/language/enums
enum TrophyConditionType {
  days,         // 経過日数での条件（例：100日、1000日）
  years,        // 経過年数での条件（例：1歳、5歳）
  specificDays, // 特定の日数（例：1111日、2222日）
}

/// 獲得済みのトロフィー情報を表すクラス
class Trophy {
  /// トロフィーの一意識別子
  final String id;
  
  /// トロフィーの表示名
  final String name;
  
  /// トロフィーの説明文
  final String description;
  
  /// トロフィーのアイコン（絵文字）
  final String icon;
  
  /// トロフィーを獲得した日時
  final DateTime acquiredAt;

  /// コンストラクタ
  Trophy({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.acquiredAt,
  });

  /// JSONへの変換メソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'acquiredAt': acquiredAt.toIso8601String(),
    };
  }

  /// JSONからのファクトリコンストラクタ
  factory Trophy.fromJson(Map<String, dynamic> json) {
    return Trophy(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      acquiredAt: DateTime.parse(json['acquiredAt'] as String),
    );
  }
}

/// トロフィー獲得条件を表すクラス
/// 
/// trophy_config.jsonで定義される条件をDartオブジェクトとして扱う
class TrophyCondition {
  /// 条件のタイプ
  final TrophyConditionType type;
  
  /// 条件の値（日数や年数）
  final int value;

  /// コンストラクタ
  TrophyCondition({
    required this.type,
    required this.value,
  });

  /// JSONへの変換メソッド
  /// 
  /// enumを文字列に変換する際の注意点：
  /// enumのname拡張メソッドを使用してenumの名前を取得
  /// https://dart.dev/language/enums#using-enums
  Map<String, dynamic> toJson() {
    return {
      'type': _typeToString(type),
      'value': value,
    };
  }

  /// JSONからのファクトリコンストラクタ
  factory TrophyCondition.fromJson(Map<String, dynamic> json) {
    return TrophyCondition(
      type: _stringToType(json['type'] as String),
      value: json['value'] as int,
    );
  }

  /// enumを文字列に変換するヘルパーメソッド
  static String _typeToString(TrophyConditionType type) {
    switch (type) {
      case TrophyConditionType.days:
        return 'days';
      case TrophyConditionType.years:
        return 'years';
      case TrophyConditionType.specificDays:
        return 'specific_days';
    }
  }

  /// 文字列をenumに変換するヘルパーメソッド
  static TrophyConditionType _stringToType(String typeString) {
    switch (typeString) {
      case 'days':
        return TrophyConditionType.days;
      case 'years':
        return TrophyConditionType.years;
      case 'specific_days':
        return TrophyConditionType.specificDays;
      default:
        throw ArgumentError('Unknown trophy condition type: $typeString');
    }
  }
}

/// トロフィーの定義情報を表すクラス
/// 
/// trophy_config.jsonで定義される各トロフィーの設定
class TrophyConfig {
  /// トロフィーの一意識別子
  final String id;
  
  /// トロフィーの表示名
  final String name;
  
  /// トロフィーの説明文
  final String description;
  
  /// トロフィー獲得条件
  final TrophyCondition condition;
  
  /// トロフィーのアイコン（絵文字）
  final String icon;

  /// コンストラクタ
  TrophyConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
    required this.icon,
  });

  /// JSONへの変換メソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'condition': condition.toJson(),
      'icon': icon,
    };
  }

  /// JSONからのファクトリコンストラクタ
  factory TrophyConfig.fromJson(Map<String, dynamic> json) {
    return TrophyConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      condition: TrophyCondition.fromJson(
        json['condition'] as Map<String, dynamic>,
      ),
      icon: json['icon'] as String,
    );
  }
}