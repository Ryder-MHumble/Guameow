import 'dart:math';
import '../models/fortune_report.dart';

class FortuneService {
  static final Random _random = Random();
  
  static const List<String> _poems = [
    '一叶浮萍归大海，人生何处不相逢。',
    '云中谁寄锦书来，雁字回时月满楼。',
    '最是人间留不住，朱颜辞镜花辞树。',
    '春风得意马蹄疾，一日看尽长安花。',
    '莫愁前路无知己，天下谁人不识君。',
  ];

  static const List<String> _poemInterpretations = [
    '暗示着缘分的奇妙，提醒你保持开放和乐观的心态。',
    '象征着好消息即将到来，可能会有意外的惊喜。',
    '提醒珍惜当下，把握机会，不要让时光白白流逝。',
    '预示着事业上将有重大突破，成功指日可待。',
    '表明你将遇到贵人相助，人际关系将有显著改善。',
  ];

  static const Map<FortuneType, List<String>> _fortuneDescriptions = {
    FortuneType.love: [
      '桃花运旺盛，可能遇到心仪的对象。',
      '感情稳定发展，互相理解更加深入。',
      '单身者有望遇到理想伴侣，已有伴侣关系更进一步。',
    ],
    FortuneType.career: [
      '事业发展顺利，有望获得升职加薪。',
      '工作中遇到贵人相助，项目进展顺利。',
      '适合尝试新的职业方向，创业机会良多。',
    ],
    FortuneType.wealth: [
      '财运亨通，可能有意外收获。',
      '投资理财有望获得不错回报。',
      '偏财运旺，可以适当把握机会。',
    ],
    FortuneType.health: [
      '身体状况良好，保持规律作息即可。',
      '注意适度运动，调节作息时间。',
      '精神状态佳，建议保持运动习惯。',
    ],
    FortuneType.study: [
      '学习效率高，记忆力增强，是取得学业突破的好时机。',
      '思维活跃，创造力提升，适合进行研究和创新工作。',
      '专注力提升，对复杂概念的理解更为深入。',
    ],
  };

  static const Map<FortuneType, List<String>> _fortuneSuggestions = {
    FortuneType.love: [
      '多参加社交活动，扩大交友圈',
      '保持真诚开放的态度',
      '适时表达自己的感受',
    ],
    FortuneType.career: [
      '把握机会展现自己的能力',
      '与同事保持良好沟通',
      '注意职业发展规划',
    ],
    FortuneType.wealth: [
      '合理规划支出，避免冲动消费',
      '关注理财知识，稳健投资',
      '建立良好的理财习惯',
    ],
    FortuneType.health: [
      '保持规律作息，注意饮食均衡',
      '坚持适度运动，增强体质',
      '保持良好心态，适当放松',
    ],
    FortuneType.study: [
      '制定合理学习计划，避免临时抱佛脚',
      '尝试番茄工作法提高专注度',
      '多与优秀同学交流，取长补短',
    ],
  };

  /// 根据生日和血型生成运势报告
  static Future<FortuneReport> generateReport(DateTime birthDate, String bloodType) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 2));

    // 根据生日计算运势等级
    final level = _calculateFortuneLevel(birthDate);
    
    // 生成运势预测
    final predictions = _generatePredictions(birthDate, bloodType);

    // 生成开运建议和吉利物品
    final luckySuggestions = _generateLuckySuggestions(birthDate);
    final luckyItems = _generateLuckyItems(birthDate);
    final luckyColors = _generateLuckyColors(birthDate);
    final luckyNumbers = _generateLuckyNumbers(birthDate);

    // 随机选择诗句和解读
    final poemIndex = _random.nextInt(_poems.length);

    return FortuneReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      birthDate: birthDate,
      bloodType: bloodType,
      level: level,
      poem: _poems[poemIndex],
      poemInterpretation: _poemInterpretations[poemIndex],
      predictions: predictions,
      luckySuggestions: luckySuggestions,
      luckyItems: luckyItems,
      luckyColors: luckyColors,
      luckyNumbers: luckyNumbers,
    );
  }

  static FortuneLevel _calculateFortuneLevel(DateTime birthDate) {
    final now = DateTime.now();
    final dayDiff = now.difference(birthDate).inDays;
    final fortuneValue = (dayDiff + now.millisecondsSinceEpoch) % 100;
    
    if (fortuneValue >= 90) return FortuneLevel.excellent;
    if (fortuneValue >= 75) return FortuneLevel.great;
    if (fortuneValue >= 50) return FortuneLevel.good;
    if (fortuneValue >= 25) return FortuneLevel.fair;
    return FortuneLevel.bad;
  }

  static List<FortunePrediction> _generatePredictions(DateTime birthDate, String bloodType) {
    return FortuneType.values.map((type) {
      final descriptions = _fortuneDescriptions[type]!;
      final suggestions = List<String>.from(_fortuneSuggestions[type]!);
      
      // 根据生日和血型计算分数
      final baseScore = ((birthDate.millisecondsSinceEpoch + bloodType.hashCode) % 30) + 70;
      final score = (baseScore + _random.nextInt(20)).clamp(0, 100);

      suggestions.shuffle(_random);

      return FortunePrediction(
        type: type,
        description: descriptions[_random.nextInt(descriptions.length)],
        score: score,
        suggestions: suggestions,
      );
    }).toList();
  }

  static List<String> _generateLuckySuggestions(DateTime birthDate) {
    const suggestions = [
      '早起晨练，增强体质',
      '多与朋友聚会，增进感情',
      '学习新技能，提升自我',
      '保持乐观心态，积极向上',
      '关注健康，规律作息',
      '善待他人，广结善缘',
    ];
    
    final result = List<String>.from(suggestions);
    result.shuffle(_random);
    return result.take(3).toList();
  }

  static List<String> _generateLuckyItems(DateTime birthDate) {
    const items = [
      '红色钱包', '猫咪挂饰', '幸运手链',
      '水晶饰品', '绿色植物', '香薰蜡烛',
      '金色吊坠', '蓝色笔记本', '玉石摆件',
    ];
    
    final result = List<String>.from(items);
    result.shuffle(_random);
    return result.take(3).toList();
  }

  static List<String> _generateLuckyColors(DateTime birthDate) {
    const colors = [
      '红色', '粉色', '金色', '蓝色',
      '绿色', '紫色', '白色', '黄色',
    ];
    
    final result = List<String>.from(colors);
    result.shuffle(_random);
    return result.take(3).toList();
  }

  static List<int> _generateLuckyNumbers(DateTime birthDate) {
    final numbers = List<int>.generate(9, (i) => i + 1);
    numbers.shuffle(_random);
    return numbers.take(3).toList();
  }
} 