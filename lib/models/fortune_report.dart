/// 喵签等级
enum FortuneLevel {
  /// 上上签
  excellent('上上签'),

  /// 上吉签
  great('上吉签'),

  /// 中吉签
  good('中吉签'),

  /// 小吉签
  fair('小吉签'),

  /// 凶签
  bad('凶签');

  final String label;
  const FortuneLevel(this.label);
}

/// 运势类型
enum FortuneType {
  love('感情'),
  career('事业'),
  wealth('财运'),
  health('健康'),
  study('学业');

  final String label;
  const FortuneType(this.label);
}

/// 单个运势预测
class FortunePrediction {
  /// 运势类型
  final FortuneType type;

  /// 运势描述
  final String description;

  /// 运势评分（0-100）
  final int score;

  /// 喵咪建议
  final List<String> suggestions;

  const FortunePrediction({
    required this.type,
    required this.description,
    required this.score,
    required this.suggestions,
  });

  factory FortunePrediction.fromJson(Map<String, dynamic> json) {
    return FortunePrediction(
      type: FortuneType.values.firstWhere(
        (e) => e.label == json['type'],
        orElse: () => FortuneType.love,
      ),
      description: json['description'] as String,
      score: json['score'] as int,
      suggestions: List<String>.from(json['suggestions'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.label,
    'description': description,
    'score': score,
    'suggestions': suggestions,
  };
}

/// 喵签报告
class FortuneReport {
  /// 报告ID
  final String id;

  /// 生成时间
  final DateTime createdAt;

  /// 用户生日
  final DateTime birthDate;

  /// 用户血型
  final String bloodType;

  /// 整体运势等级
  final FortuneLevel level;

  /// 喵签诗句
  final String poem;

  /// 诗句解读
  final String poemInterpretation;

  /// 各项运势预测
  final List<FortunePrediction> predictions;

  /// 开运建议
  final List<String> luckySuggestions;

  /// 吉利物品
  final List<String> luckyItems;

  /// 吉利颜色
  final List<String> luckyColors;

  /// 吉利数字
  final List<int> luckyNumbers;

  const FortuneReport({
    required this.id,
    required this.createdAt,
    required this.birthDate,
    required this.bloodType,
    required this.level,
    required this.poem,
    required this.poemInterpretation,
    required this.predictions,
    required this.luckySuggestions,
    required this.luckyItems,
    required this.luckyColors,
    required this.luckyNumbers,
  });

  factory FortuneReport.fromJson(Map<String, dynamic> json) {
    return FortuneReport(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      birthDate: DateTime.parse(json['birth_date'] as String),
      bloodType: json['blood_type'] as String,
      level: FortuneLevel.values.firstWhere(
        (e) => e.label == json['level'],
        orElse: () => FortuneLevel.fair,
      ),
      poem: json['poem'] as String,
      poemInterpretation: json['poem_interpretation'] as String,
      predictions:
          (json['predictions'] as List)
              .map((e) => FortunePrediction.fromJson(e as Map<String, dynamic>))
              .toList(),
      luckySuggestions: List<String>.from(json['lucky_suggestions'] as List),
      luckyItems: List<String>.from(json['lucky_items'] as List),
      luckyColors: List<String>.from(json['lucky_colors'] as List),
      luckyNumbers: List<int>.from(json['lucky_numbers'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'birth_date': birthDate.toIso8601String(),
    'blood_type': bloodType,
    'level': level.label,
    'poem': poem,
    'poem_interpretation': poemInterpretation,
    'predictions': predictions.map((e) => e.toJson()).toList(),
    'lucky_suggestions': luckySuggestions,
    'lucky_items': luckyItems,
    'lucky_colors': luckyColors,
    'lucky_numbers': luckyNumbers,
  };

  @override
  String toString() => 'FortuneReport(level: ${level.label})';
}
