/// ユーザーの生年月日と年齢計算を管理するモデルクラス
/// 
/// Dartのクラスについて：https://dart.dev/language/classes
class UserData {
  /// 生年月日を保持するフィールド
  /// finalは初期化後に変更できない変数を定義する
  /// https://dart.dev/language/variables#final-and-const
  final DateTime birthdate;

  /// コンストラクタ（クラスのインスタンスを作成する特殊なメソッド）
  /// required: このパラメータは必須であることを示す
  /// https://dart.dev/language/constructors
  UserData({required this.birthdate});

  /// オブジェクトをJSON形式に変換するメソッド
  /// SharedPreferencesに保存する際などに使用
  /// Map<String, dynamic>はDartの辞書型（他言語のHashMapやDictionaryに相当）
  /// https://dart.dev/guides/libraries/library-tour#maps
  Map<String, dynamic> toJson() {
    return {
      // DateTimeをISO8601形式の文字列に変換
      // 例: "2000-01-01T00:00:00.000"
      'birthdate': birthdate.toIso8601String(),
    };
  }

  /// JSONからUserDataオブジェクトを作成するファクトリコンストラクタ
  /// factoryキーワードは新しいインスタンスを必ずしも作成しない特殊なコンストラクタ
  /// https://dart.dev/language/constructors#factory-constructors
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      // 文字列をDateTimeオブジェクトに変換
      // as String は型キャスト（型の明示的な変換）
      birthdate: DateTime.parse(json['birthdate'] as String),
    );
  }

  /// 生まれてからの日数を計算するゲッター
  /// getキーワードを使うと、メソッドをプロパティのように呼び出せる
  /// 例: userData.ageInDays （userData.ageInDays()ではない）
  /// https://dart.dev/language/methods#getters-and-setters
  int get ageInDays {
    final now = DateTime.now();
    // difference()メソッドで2つの日時の差分を取得
    // inDaysで日数に変換
    return now.difference(birthdate).inDays;
  }

  /// 年齢（歳）を計算するゲッター
  /// 誕生日を迎えているかを考慮した正確な年齢計算
  int get ageInYears {
    final now = DateTime.now();
    int years = now.year - birthdate.year;
    
    // まだ今年の誕生日を迎えていない場合は1年引く
    if (now.month < birthdate.month ||
        (now.month == birthdate.month && now.day < birthdate.day)) {
      years--;
    }
    return years;
  }

  /// 詳細な経過時間（日・時・分・秒）を取得するメソッド
  /// リアルタイム表示用に使用
  /// 
  /// @param currentTime 現在時刻（テスト時にモック可能にするため引数で受け取る）
  /// @return 各時間単位の値を含むMap
  Map<String, int> getAgeComponents(DateTime currentTime) {
    final difference = currentTime.difference(birthdate);
    
    // Duration型の各プロパティについて：
    // https://api.flutter.dev/flutter/dart-core/Duration-class.html
    final days = difference.inDays;
    final hours = difference.inHours % 24;      // 24で割った余りで時間部分を取得
    final minutes = difference.inMinutes % 60;  // 60で割った余りで分部分を取得
    final seconds = difference.inSeconds % 60;  // 60で割った余りで秒部分を取得

    return {
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }
}