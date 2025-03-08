// 静态数据文件，用于存储所有运势相关的静态数据
// 后期可以直接替换为API返回的JSON数据

import 'package:flutter/material.dart';
import '../models/fortune_report.dart';
import '../pages/daily_fortune/models/fortune_data.dart';

class FortuneStaticData {
  // 运势样式映射
  static final Map<String, Map<String, dynamic>> fortuneStyles = {
    '上上签': {
      'color': const Color(0xFFFF69B4),
      'borderColor': const Color(0xFFFF69B4),
      'tagColor': const Color(0xFFFFF0F5),
      'gradient': const LinearGradient(
        colors: [Color(0xFFFF69B4), Color(0xFFFFB6C1)],
      ),
      'icon': '🌸',
    },
    '上吉签': {
      'color': const Color(0xFFFF8C00),
      'borderColor': const Color(0xFFFF8C00),
      'tagColor': const Color(0xFFFFEFD5),
      'gradient': const LinearGradient(
        colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
      ),
      'icon': '✨',
    },
    '中吉签': {
      'color': const Color(0xFF4169E1),
      'borderColor': const Color(0xFF4169E1),
      'tagColor': const Color(0xFFF0F8FF),
      'gradient': const LinearGradient(
        colors: [Color(0xFF4169E1), Color(0xFF87CEEB)],
      ),
      'icon': '🌟',
    },
    '小吉签': {
      'color': const Color(0xFF2E7D32),
      'borderColor': const Color(0xFF2E7D32),
      'tagColor': const Color(0xFFF0FFF0),
      'gradient': const LinearGradient(
        colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
      ),
      'icon': '🍀',
    },
    '凶签': {
      'color': const Color(0xFF800080),
      'borderColor': const Color(0xFF800080),
      'tagColor': const Color(0xFFF5F0F5),
      'gradient': const LinearGradient(
        colors: [Color(0xFF800080), Color(0xFFBA55D3)],
      ),
      'icon': '🌙',
    },
  };

  // 根据运势等级获取概率分布
  static Map<String, String> getRatiosByFortuneLevel(String level) {
    switch (level) {
      case '上上签':
        return {
          '大吉': '60%',
          '中吉': '25%',
          '小吉': '10%',
          '凶': '5%',
        };
      case '上吉签':
        return {
          '大吉': '45%',
          '中吉': '40%',
          '小吉': '10%',
          '凶': '5%',
        };
      case '中吉签':
        return {
          '大吉': '30%',
          '中吉': '45%',
          '小吉': '20%',
          '凶': '5%',
        };
      case '小吉签':
        return {
          '大吉': '20%',
          '中吉': '35%',
          '小吉': '35%',
          '凶': '10%',
        };
      case '凶签':
        return {
          '大吉': '15%',
          '中吉': '25%',
          '小吉': '35%',
          '凶': '25%',
        };
      default:
        return {
          '大吉': '30%',
          '中吉': '45%',
          '小吉': '20%',
          '凶': '5%',
        };
    }
  }

  // 将 FortuneData 转换为 FortuneReport 的方法
  static FortuneReport convertToFortuneReport(FortuneData data) {
    return FortuneReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      level: FortuneLevel.values.firstWhere(
        (e) => e.label == data.fortuneLevel,
        orElse: () => FortuneLevel.good,
      ),
      poem: data.poem,
      poemInterpretation: data.tips,
      predictions: [
        FortunePrediction(
          type: FortuneType.love,
          score: 95,
          description: "今日桃花运旺盛",
          suggestions: data.goodThings,
        ),
        FortunePrediction(
          type: FortuneType.career,
          score: 88,
          description: "工作进展顺利",
          suggestions: data.goodThings,
        ),
        FortunePrediction(
          type: FortuneType.wealth,
          score: 90,
          description: "财运不错",
          suggestions: data.goodThings,
        ),
        FortunePrediction(
          type: FortuneType.health,
          score: 85,
          description: "身体状况良好，精力充沛",
          suggestions: data.goodThings,
        ),
        FortunePrediction(
          type: FortuneType.study,
          score: 88,
          description: "学习效率高，思维活跃",
          suggestions: data.goodThings,
        ),
      ],
      birthDate: DateTime.now(),
      bloodType: "A",
      luckySuggestions: data.goodThings,
      luckyColors: ["粉色", "白色"],
      luckyNumbers: [6, 8, 9],
      luckyItems: data.tags,
    );
  }

  // 命理详解页面的静态数据
  static final Map<String, dynamic> fortuneTellingData = {
    'basicInfo': {
      'birthDate': DateTime.now(),
      'bloodType': 'A',
      'chineseZodiac': '鼠',
      'heavenlyStem': '甲',
      'earthlyBranch': '子',
      'stemElement': '木',
      'branchElement': '水',
      'zodiacSign': '水瓶座',
    },
    'eightCharacters': {
      'stem': '辛',
      'branch': '巳',
      'chineseMonth': '正月',
      'chineseDay': '初五',
      'chineseHour': '子时',
      'eightCharText': '年柱：辛巳（金火）｜月柱：庚寅（金木）｜日柱：乙卯（木木）｜时柱：丁丑（火土）',
      'interpretation': '日主乙木生于寅月（立春后），得令而旺；地支寅卯半会木局，时支丑土藏癸水滋养，木气强盛。整体命局偏向"木火通明"，但金土稍弱，需调和。',
    },
    'usedGod': {
      'likeGod': '木旺需金制、火泄，同时需土培根。金（官杀）可制木，火（食伤）可泄秀生财，土（财星）为养命之源。',
      'avoidGod': '水（印星）会助木过旺，反成负担。',
    },
    'destinyAnalysis': '妻星为戊土（正财），藏于时支丑土中，暗示正缘出现较晚（25岁后），对方可能属牛、蛇或鸡，性格务实、家庭观念强。\n\n2024甲辰年，辰土为财库，且流年与日支卯辰相害，感情易有波动，但也是婚恋机会年；2026丙午年，火旺生土，婚缘信号强烈。',
    'yearFortune': [
      {
        'year': '2023癸卯年',
        'content': '• 癸水偏印透干，思想压力大，但卯木为日主禄神，学业/事业有贵人暗中相助。\n• 注意：水木过旺易导致情绪敏感，需多运动疏解。',
      },
      {
        'year': '2024甲辰年',
        'content': '• 甲木劫财透干，竞争加剧，需防破财；辰土为财库，若把握实习转正机会，收入可提升。\n• 关键月份：农历三月（辰月）、八月（酉月），易有贵人提携。',
      },
    ],
    'financePosition': {
      'directions': '• 西北（乾卦）：金位助财，可放置金属貔貅或白色水晶。\n• 西南（坤卦）：土位养财，适合摆放黄玉或陶瓷聚宝盆。',
      'nobleFeatures': '• 生肖：猴（申）、鼠（子），能引动天乙贵人（申子）。\n• 星座：双子座、天秤座（风象星座助你开拓人脉）。',
    },
    'crossSys': [
      {
        'title': '星座（双鱼座）',
        'content': '2023年海王星顺行，灵感充沛，适合研究或创作；但需避免过度理想化人际关系。',
      },
      {
        'title': '塔罗牌象征',
        'content': '现状：抽到"隐者（逆位）"，提示需走出自我封闭，主动社交拓展机会。\n建议："权杖八（正位）"，快速行动可突破瓶颈。',
      },
      {
        'title': '推背图卦象',
        'content': '第37象"火运开时祸蔓延"，对应你命局火旺，需注意2026年前后火土流年，避免冲动决策。',
      },
    ],
    'luckyAdvice': {
      'suggestions': [
        '1. 佩戴金属饰品（银链、金曜石），补金制木。',
        '2. 办公桌布局：西北方放铜制文昌塔，提升学业事业运。',
        '3. 感情主动期：2024年秋季多参与学术交流，易遇正缘。',
      ],
      'summary': '总结：你命局潜力深厚，近两年需稳扎稳打，2024年后逐步迎来事业感情双丰收。贵人助力多在西北方向，谨记"守正待时"。',
    },
  };

  // 获取运势等级对应的颜色
  static Color getLevelColor(FortuneLevel level) {
    switch (level) {
      case FortuneLevel.excellent:
        return const Color(0xFFFF69B4); // 上上签 - 粉色
      case FortuneLevel.great:
        return const Color(0xFFFF8C00); // 上吉签 - 橙色
      case FortuneLevel.good:
        return const Color(0xFF4169E1); // 中吉签 - 蓝色
      case FortuneLevel.fair:
        return const Color(0xFF2E7D32); // 小吉签 - 深绿色
      case FortuneLevel.bad:
        return const Color(0xFF808080); // 凶签 - 灰色
    }
  }

  // 获取运势类型对应的颜色
  static Color getTypeColor(FortuneType type) {
    switch (type) {
      case FortuneType.love:
        return const Color(0xFFFF97C1);
      case FortuneType.career:
        return const Color(0xFF7EC2FF);
      case FortuneType.wealth:
        return const Color(0xFFFFB366);
      case FortuneType.health:
        return const Color(0xFF90EE90);
      case FortuneType.study:
        return const Color(0xFFA78BFA); // 学业运势 - 紫色
    }
  }

  // 获取运势类型对应的图标
  static String getFortuneTypeIcon(FortuneType type) {
    switch (type) {
      case FortuneType.love:
        return 'assets/icons/love.svg';
      case FortuneType.career:
        return 'assets/icons/career.svg';
      case FortuneType.wealth:
        return 'assets/icons/wealth.svg';
      case FortuneType.health:
        return 'assets/icons/health.svg';
      case FortuneType.study:
        return 'assets/icons/study.svg'; // 如果没有可以使用备用图标
    }
  }

  // 根据分数获取对应的颜色
  static Color getScoreColor(int score) {
    if (score >= 90) return const Color(0xFFFF4D4F);
    if (score >= 80) return const Color(0xFFFFA940);
    if (score >= 70) return const Color(0xFF52C41A);
    if (score >= 60) return const Color(0xFF1890FF);
    return const Color(0xFF722ED1);
  }
} 