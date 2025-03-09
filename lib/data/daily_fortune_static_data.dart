// 喵签相关的静态数据文件
// 用于存储所有喵签运势相关的静态数据
// 后期可以直接替换为API返回的JSON数据

/* API JSON数据结构说明：
{
  // 喵签数据部分
  "fortune": {
    "poem": string,          // 签诗内容，使用\n分隔诗句
    "goodThings": string[],  // 宜做的事情列表
    "badThings": string[],   // 忌做的事情列表
    "tips": string,          // 解签小贴士，使用\n分隔多行内容
    "tags": string[],        // 运势标签列表，以#开头
    "fortuneLevel": string,  // 运势等级：上上签|上吉签|中吉签|小吉签|凶签
    "fortuneNumber": number  // 签号，范围1-100
  },
  
  // 每日喵签的运势报告部分
  "report": {
    "id": string,            // 报告唯一标识，格式：daily-YYYYMMDD-序号
    "createdAt": string,     // 创建时间，ISO8601格式
    "level": string,         // 运势等级：excellent|great|good|fair|bad
    "poem": string,          // 与fortune.poem相同
    "poemInterpretation": string,  // 诗句解释
    
    // 运势预测数组 - 固定包含以下5种类型的运势
    "predictions": [
      {
        // 固定的运势类型，模型将为每种类型生成对应的描述、分数和建议
        "type": string,     // 运势类型，固定为以下5种：
                           // - love: 感情运势
                           // - career: 事业运势
                           // - wealth: 财运运势
                           // - health: 健康运势
                           // - study: 学业运势
        "description": string,  // 该类型运势的具体描述，由模型生成
        "score": number,    // 运势分数，范围0-100，由模型根据描述内容评分
        "suggestions": string[]  // 针对该类型运势的具体建议列表，由模型生成
      }
    ],
    
    "luckySuggestions": string[],  // 开运建议列表
    "luckyItems": string[],        // 开运物品列表
    "luckyColors": string[],       // 开运颜色列表
    "luckyNumbers": number[]       // 开运数字列表
  }
}

// 占卜报告的数据结构与日常喵签类似，但额外需要以下字段：
// "birthDate": string,    // 用户生日，ISO8601格式
// "bloodType": string,    // 血型：A|B|O|AB

注意：predictions 数组中的五种运势类型是固定的，每个运势报告都会包含这五种类型的预测。
模型会根据整体运势和签诗内容，为每种类型生成：
1. 符合主题的运势描述
2. 基于描述内容的量化分数（0-100）
3. 针对性的行动建议列表
*/

import 'package:flutter/material.dart';
import '../models/fortune_report.dart';
import '../pages/daily_fortune/models/fortune_data.dart';

class DailyFortuneStaticData {
  // 测试用的喵签数据
  // 这些数据仅用于测试和开发阶段
  // 后续会通过统一的 JSON API 返回
  static final List<Map<String, dynamic>> testFortuneData = [
    // 上吉签
    {
      'fortune': {
        'poem': '猫影摇曳迎吉日\n五行相助定安康',
        'goodThings': ['拜祭天德神祇', '整理居家环境', '参加文艺活动'],
        'badThings': ['避免激烈争执', '慎防财务浪费', '远离不利交际'],
        'tips': '金生水润启事业，火克金情需调和\n木生火旺固健康，水润土稳促财运',
        'tags': ['#天德', '#月恩', '#猫运'],
        'fortuneLevel': '上吉签',
        'fortuneNumber': 85,
      },
      'report': {
        'id': 'daily-20250221-1',
        'createdAt': '2025-02-21T00:00:00Z',
        'level': 'great',
        'poem': '猫影摇曳迎吉日\n五行相助定安康',
        'poemInterpretation': '此诗以"猫影摇曳迎吉日"启示你在天德月恩双照下，感受如猫般灵动的吉祥气息；"五行相助定安康"揭示金、木、水、火、土间相生相克的奥妙，暗示在工作、感情与生活中需调和各方，趋吉避凶，化解潜在凶煞，从而保障整日平稳顺遂。',
        'predictions': [
          {
            'type': 'love',
            'description': '今日火行运势旺盛，恋情如炽热烈火般燃烧，易激发热情却也可能引发冲动争执，宜保持冷静，通过真诚沟通化解矛盾，维持情感温馨稳定。',
            'score': 78,
            'suggestions': [
              '多沟通表达情感',
              '适时冷静思考',
              '共同规划未来'
            ]
          },
          {
            'type': 'career',
            'description': '今日金行运势显赫，职场中机遇频现，能量充沛助你展示才华，但需警惕小人暗算，稳中求进，注重团队协作以确保事业稳步提升。',
            'score': 82,
            'suggestions': [
              '积极展示能力',
              '谨慎处理人际',
              '稳扎稳打前行'
            ]
          },
          {
            'type': 'wealth',
            'description': '今日土行运势平稳，财务状况较为稳固，资金流转顺畅，但市场波动仍不可忽视，宜理性规划收支，防范冲动投资带来的风险。',
            'score': 80,
            'suggestions': [
              '精打细算理财',
              '审慎评估投资',
              '储备紧急资金'
            ]
          },
          {
            'type': 'health',
            'description': '今日木行气息充盈，身心状态良好，适合适度运动调节疲劳，但注意劳逸结合，避免过度消耗导致小病频发，保持健康平衡至关重要。',
            'score': 85,
            'suggestions': [
              '适度运动锻炼',
              '保持心情愉悦',
              '合理安排作息'
            ]
          },
          {
            'type': 'study',
            'description': '今日水行流动启智慧，学业上思路清晰有助于吸收新知，但情绪波动可能影响专注，建议制定明确学习计划，坚持稳步进步。',
            'score': 75,
            'suggestions': [
              '制定详细计划',
              '专注核心知识',
              '合理分配时间'
            ]
          }
        ],
        'luckySuggestions': [
          '佩戴红色饰品',
          '点燃香薰助情绪',
          '参与温馨聚会'
        ],
        'luckyItems': [
          '红玛瑙',
          '朱砂挂件',
          '火凤凰摆件'
        ],
        'luckyColors': [
          '红色',
          '橙色',
          '粉色'
        ],
        'luckyNumbers': [3, 7, 9]
      }
    },
    // 中吉签
    {
      'fortune': {
        'poem': '乌云散尽见月明\n守得云开见月明',
        'goodThings': ['学习进修', '投资理财'],
        'badThings': ['冲动消费', '情绪失控'],
        'tips': '保持耐心终会有回报\n深蓝色能带来好运',
        'tags': ['#事业运', '#财运亨通'],
        'fortuneLevel': '中吉签',
        'fortuneNumber': 65,
      },
      'report': {
        'id': 'daily-20250221-2',
        'createdAt': '2025-02-21T00:00:00Z',
        'level': 'good',
        'poem': '乌云散尽见月明\n守得云开见月明',
        'poemInterpretation': '当前的困难只是暂时的，保持耐心和积极的心态，终会迎来转机。',
        'predictions': [
          {
            'type': 'love',
            'description': '感情稳定发展，注意倾听对方的想法。',
            'score': 75,
            'suggestions': [
              '保持良好的沟通',
              '给对方一些惊喜',
              '共同规划未来'
            ]
          },
          {
            'type': 'career',
            'description': '事业发展平稳，需要积累经验。',
            'score': 80,
            'suggestions': [
              '提升专业技能',
              '建立良好的人际关系',
              '保持积极的工作态度'
            ]
          },
          {
            'type': 'wealth',
            'description': '财运平稳，适合稳健理财。',
            'score': 78,
            'suggestions': [
              '控制不必要的支出',
              '合理规划收支',
              '关注理财知识'
            ]
          },
          {
            'type': 'health',
            'description': '注意作息规律，保持运动习惯。',
            'score': 82,
            'suggestions': [
              '坚持运动计划',
              '保证充足睡眠',
              '注意饮食均衡'
            ]
          },
          {
            'type': 'study',
            'description': '学习需要循序渐进，不要操之过急。',
            'score': 77,
            'suggestions': [
              '制定合理的学习计划',
              '保持专注力',
              '及时复习巩固'
            ]
          }
        ],
        'luckySuggestions': [
          '制定详细的学习计划',
          '关注理财知识',
          '保持规律的作息'
        ],
        'luckyItems': ['蓝色笔记本', '理财书籍', '运动装备'],
        'luckyColors': ['深蓝色', '灰色', '白色'],
        'luckyNumbers': [3, 6, 8]
      }
    },
    // 上上签
    {
      'fortune': {
        'poem': '一帆风顺好运来\n事事如意喜洋洋',
        'goodThings': ['投资创业', '约会求爱', '参加考试'],
        'badThings': ['逞强争执', '贪杯过度', '过于冒险'],
        'tips': '好机会来临要把握\n红色配饰旺运道',
        'tags': ['#大吉', '#桃花旺', '#财运亨通'],
        'fortuneLevel': '上上签',
        'fortuneNumber': 12,
      },
      'report': {
        'id': 'daily-20250221-3',
        'createdAt': '2025-02-21T00:00:00Z',
        'level': 'excellent',
        'poem': '一帆风顺好运来\n事事如意喜洋洋',
        'poemInterpretation': '今日诸事顺遂，各方面运势都很旺盛，是把握机会的好时机。',
        'predictions': [
          {
            'type': 'love',
            'description': '桃花运旺盛，单身者有望遇到心仪对象，已有伴侣关系更加甜蜜。',
            'score': 90,
            'suggestions': [
              '勇敢表达爱意',
              '保持真诚态度',
              '适度浪漫表示'
            ]
          },
          {
            'type': 'career',
            'description': '工作事业大有可为，上司欣赏你的才能，有升职加薪机会。',
            'score': 92,
            'suggestions': [
              '积极承担责任',
              '展示领导能力',
              '把握晋升机会'
            ]
          },
          {
            'type': 'wealth',
            'description': '财运极佳，投资有望获得丰厚回报，可考虑开拓财源。',
            'score': 94,
            'suggestions': [
              '适度扩大投资',
              '关注理财产品',
              '避免盲目冒险'
            ]
          },
          {
            'type': 'health',
            'description': '精力充沛，身体状况良好，但切忌过度透支。',
            'score': 88,
            'suggestions': [
              '保持规律作息',
              '适度锻炼身体',
              '注意饮食均衡'
            ]
          },
          {
            'type': 'study',
            'description': '学习效率高，思维活跃，是取得突破的好时机。',
            'score': 91,
            'suggestions': [
              '挑战高难度知识',
              '参与学术讨论',
              '总结学习方法'
            ]
          }
        ],
        'luckySuggestions': [
          '穿着红色衣物',
          '参加社交活动',
          '尝试新的挑战'
        ],
        'luckyItems': ['红色钱包', '金色饰品', '幸运手链'],
        'luckyColors': ['红色', '金色', '明黄色'],
        'luckyNumbers': [1, 6, 8]
      }
    },
    // 小吉签
    {
      'fortune': {
        'poem': '微风细雨润春苗\n静待花开结硕果',
        'goodThings': ['细致工作', '修身养性', '稳健投资'],
        'badThings': ['盲目冒进', '急躁冲动', '高风险决策'],
        'tips': '循序渐进方为上策\n绿色能带来好运',
        'tags': ['#小吉', '#稳健', '#渐进'],
        'fortuneLevel': '小吉签',
        'fortuneNumber': 45,
      },
      'report': {
        'id': 'daily-20250221-4',
        'createdAt': '2025-02-21T00:00:00Z',
        'level': 'fair',
        'poem': '微风细雨润春苗\n静待花开结硕果',
        'poemInterpretation': '今日运势平稳，虽无突出亮点，但稳步前进能积累未来的成功。',
        'predictions': [
          {
            'type': 'love',
            'description': '感情需要耐心培养，不宜操之过急，细水长流更为长久。',
            'score': 68,
            'suggestions': [
              '用心倾听对方',
              '保持耐心等待',
              '细致关怀表达'
            ]
          },
          {
            'type': 'career',
            'description': '工作中注重细节，踏实做事，虽无大突破但稳步提升。',
            'score': 72,
            'suggestions': [
              '注重工作细节',
              '完善专业技能',
              '与同事和谐相处'
            ]
          },
          {
            'type': 'wealth',
            'description': '财运平平，宜保守理财，避免高风险投资。',
            'score': 65,
            'suggestions': [
              '合理控制支出',
              '稳健保守投资',
              '避免冲动消费'
            ]
          },
          {
            'type': 'health',
            'description': '身体状况一般，注意保持良好习惯，预防胜于治疗。',
            'score': 70,
            'suggestions': [
              '保持规律作息',
              '适量饮水补水',
              '温和运动健身'
            ]
          },
          {
            'type': 'study',
            'description': '学习需要细水长流，踏实复习基础知识更有助于进步。',
            'score': 69,
            'suggestions': [
              '巩固基础知识',
              '制定合理计划',
              '坚持日常学习'
            ]
          }
        ],
        'luckySuggestions': [
          '保持生活规律',
          '细致整理环境',
          '阅读充电提升'
        ],
        'luckyItems': ['绿色植物', '学习笔记', '精致书签'],
        'luckyColors': ['绿色', '浅蓝色', '米白色'],
        'luckyNumbers': [2, 5, 7]
      }
    },
    // 凶签
    {
      'fortune': {
        'poem': '乌云密布雨将至\n暂且避开风雨时',
        'goodThings': ['避险保守', '整理内务', '反思总结'],
        'badThings': ['冒险决策', '大额消费', '激烈争论'],
        'tips': '遇事三思而后行\n紫色饰品能化解不利',
        'tags': ['#谨慎', '#避险', '#养精蓄锐'],
        'fortuneLevel': '凶签',
        'fortuneNumber': 98,
      },
      'report': {
        'id': 'daily-20250221-5',
        'createdAt': '2025-02-21T00:00:00Z',
        'level': 'bad',
        'poem': '乌云密布雨将至\n暂且避开风雨时',
        'poemInterpretation': '今日运势欠佳，宜低调行事，避开风头，静待时机。',
        'predictions': [
          {
            'type': 'love',
            'description': '感情易起波澜，言行需谨慎，避免冲动引发争执。',
            'score': 45,
            'suggestions': [
              '避免敏感话题',
              '控制情绪波动',
              '给彼此空间冷静'
            ]
          },
          {
            'type': 'career',
            'description': '工作中可能遇到阻力，暂时低调行事，避免锋芒太露。',
            'score': 48,
            'suggestions': [
              '谨慎处理事务',
              '避免决策冲动',
              '做好自我保护'
            ]
          },
          {
            'type': 'wealth',
            'description': '财运不佳，易有破财风险，宜节制支出，避免投资。',
            'score': 40,
            'suggestions': [
              '严格控制开支',
              '避免任何投资',
              '检查财务漏洞'
            ]
          },
          {
            'type': 'health',
            'description': '健康状况需要关注，注意休息，避免过度劳累。',
            'score': 52,
            'suggestions': [
              '增加休息时间',
              '注意饮食安全',
              '避免剧烈运动'
            ]
          },
          {
            'type': 'study',
            'description': '学习效率不高，容易分心，适合复习而非学习新内容。',
            'score': 50,
            'suggestions': [
              '减少学习压力',
              '复习熟悉内容',
              '调整学习心态'
            ]
          }
        ],
        'luckySuggestions': [
          '减少外出活动',
          '整理居家环境',
          '冥想放松心情'
        ],
        'luckyItems': ['紫水晶', '保暖物品', '平安符'],
        'luckyColors': ['紫色', '深蓝色', '黑色'],
        'luckyNumbers': [4, 9, 13]
      }
    }
  ];

  // 将 JSON 数据转换为 FortuneData
  static FortuneData jsonToFortuneData(Map<String, dynamic> json) {
    final fortuneData = json['fortune'];
    return FortuneData(
      poem: fortuneData['poem'],
      goodThings: List<String>.from(fortuneData['goodThings']),
      badThings: List<String>.from(fortuneData['badThings']),
      tips: fortuneData['tips'],
      tags: List<String>.from(fortuneData['tags']),
      fortuneLevel: fortuneData['fortuneLevel'],
      fortuneNumber: fortuneData['fortuneNumber'],
    );
  }

  // 将 JSON 数据转换为 FortuneReport
  static FortuneReport jsonToFortuneReport(Map<String, dynamic> json) {
    final reportData = json['report'];
    
    // 使用 FortuneReport.daily 工厂方法创建每日喵签报告（无需生日和血型）
    return FortuneReport.daily(
      id: reportData['id'],
      createdAt: DateTime.parse(reportData['createdAt']),
      level: FortuneLevel.values.firstWhere(
        (e) => e.name == reportData['level'],
        orElse: () => FortuneLevel.good,
      ),
      poem: reportData['poem'],
      poemInterpretation: reportData['poemInterpretation'],
      predictions: List<Map<String, dynamic>>.from(reportData['predictions'])
          .map((predictionData) => FortunePrediction(
                type: FortuneType.values.firstWhere(
                  (e) => e.name == predictionData['type'],
                  orElse: () => FortuneType.love,
                ),
                description: predictionData['description'],
                score: predictionData['score'],
                suggestions: List<String>.from(predictionData['suggestions']),
              ))
          .toList(),
      luckySuggestions: List<String>.from(reportData['luckySuggestions']),
      luckyItems: List<String>.from(reportData['luckyItems']),
      luckyColors: List<String>.from(reportData['luckyColors']),
      luckyNumbers: List<int>.from(reportData['luckyNumbers']),
    );
  }

  // 获取测试用的喵签数据
  static List<FortuneData> get testFortunes {
    return testFortuneData.map((data) => jsonToFortuneData(data)).toList();
  }

  // 获取测试用的运势报告数据
  static FortuneReport get mockFortuneReport {
    return jsonToFortuneReport(testFortuneData.first);
  }

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
    // 查找匹配的完整数据
    final fullData = testFortuneData.firstWhere(
      (item) => jsonToFortuneData(item)
          .poem
          .split('\n')
          .first
          .startsWith(data.poem.split('\n').first),
      orElse: () => testFortuneData.first,
    );
    
    return jsonToFortuneReport(fullData);
  }

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