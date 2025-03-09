// 命理详解相关的静态数据文件
// 用于存储所有命理详解相关的静态数据
// 后期可以直接替换为API返回的JSON数据

import 'package:flutter/material.dart';

class FortuneTellingStaticData {
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
    'luckyAdvice': {
      'suggestions': [
        '1. 佩戴金属饰品（银链、金曜石），补金制木。',
        '2. 办公桌布局：西北方放铜制文昌塔，提升学业事业运。',
        '3. 感情主动期：2024年秋季多参与学术交流，易遇正缘。',
      ],
      'summary': '总结：你命局潜力深厚，近两年需稳扎稳打，2024年后逐步迎来事业感情双丰收。贵人助力多在西北方向，谨记"守正待时"。',
    },
  };

  // 八字五行颜色映射
  static final Map<String, Color> elementColors = {
    '金': const Color(0xFFFFD700), // 金 - 金色
    '木': const Color(0xFF2E8B57), // 木 - 绿色
    '水': const Color(0xFF1E90FF), // 水 - 蓝色
    '火': const Color(0xFFFF4500), // 火 - 红色
    '土': const Color(0xFFCD853F), // 土 - 棕色
  };

  // 生肖颜色映射
  static final Map<String, Color> zodiacColors = {
    '鼠': const Color(0xFF808080), // 灰色
    '牛': const Color(0xFF8B4513), // 棕色
    '虎': const Color(0xFFF5DEB3), // 浅棕色
    '兔': const Color(0xFFFFC0CB), // 粉色
    '龙': const Color(0xFFB8860B), // 金色
    '蛇': const Color(0xFF2F4F4F), // 深灰色
    '马': const Color(0xFFFF4500), // 红色
    '羊': const Color(0xFFF0E68C), // 浅黄色
    '猴': const Color(0xFFFFD700), // 金色
    '鸡': const Color(0xFFFF8C00), // 橙色
    '狗': const Color(0xFF8B4513), // 棕色
    '猪': const Color(0xFFFF69B4), // 粉色
  };

  // 星座颜色映射
  static final Map<String, Color> constellationColors = {
    '白羊座': const Color(0xFFFF4500), // 红色
    '金牛座': const Color(0xFF2E8B57), // 绿色
    '双子座': const Color(0xFFFFD700), // 金色
    '巨蟹座': const Color(0xFF1E90FF), // 蓝色
    '狮子座': const Color(0xFFFF8C00), // 橙色
    '处女座': const Color(0xFF8B4513), // 棕色
    '天秤座': const Color(0xFFFF69B4), // 粉色
    '天蝎座': const Color(0xFF800080), // 紫色
    '射手座': const Color(0xFF4169E1), // 蓝色
    '摩羯座': const Color(0xFF2F4F4F), // 深灰色
    '水瓶座': const Color(0xFF1E90FF), // 蓝色
    '双鱼座': const Color(0xFF6A5ACD), // 紫色
  };

  // 获取五行对应的颜色
  static Color getElementColor(String element) {
    return elementColors[element] ?? const Color(0xFF000000);
  }

  // 获取生肖对应的颜色
  static Color getZodiacColor(String zodiac) {
    return zodiacColors[zodiac] ?? const Color(0xFF000000);
  }

  // 获取星座对应的颜色
  static Color getConstellationColor(String constellation) {
    return constellationColors[constellation] ?? const Color(0xFF000000);
  }

  // 获取五行相生相克关系
  static Map<String, List<String>> getElementRelations(String element) {
    final Map<String, Map<String, List<String>>> relations = {
      '金': {
        '生': ['水'],
        '克': ['木'],
        '被生': ['土'],
        '被克': ['火'],
      },
      '木': {
        '生': ['火'],
        '克': ['土'],
        '被生': ['水'],
        '被克': ['金'],
      },
      '水': {
        '生': ['木'],
        '克': ['火'],
        '被生': ['金'],
        '被克': ['土'],
      },
      '火': {
        '生': ['土'],
        '克': ['金'],
        '被生': ['木'],
        '被克': ['水'],
      },
      '土': {
        '生': ['金'],
        '克': ['水'],
        '被生': ['火'],
        '被克': ['木'],
      },
    };

    return relations[element] ?? {'生': [], '克': [], '被生': [], '被克': []};
  }
} 