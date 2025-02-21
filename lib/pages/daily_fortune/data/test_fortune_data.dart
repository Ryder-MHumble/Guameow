import '../models/fortune_data.dart';

/// 测试用的喵签数据
/// 这些数据仅用于测试和开发阶段
/// 后续会通过 LLM 能力动态生成内容
class TestFortuneData {
  /// 测试用的喵签列表
  static final List<FortuneData> testFortunes = [
    FortuneData(
      poem: '春风拂面遇良缘\n心有灵犀一点通',
      goodThings: ['约会表白', '尝试新发型'],
      badThings: ['过度纠结', '深夜emo'],
      tips: '主动出击会有惊喜\n浅粉色穿搭提升气场',
      tags: ['#好运锦鲤', '#少女心打卡'],
      fortuneLevel: '上上签',
      fortuneNumber: 88,
    ),
    FortuneData(
      poem: '乌云散尽见月明\n守得云开见月明',
      goodThings: ['学习进修', '投资理财'],
      badThings: ['冲动消费', '情绪失控'],
      tips: '保持耐心终会有回报\n深蓝色能带来好运',
      tags: ['#事业运', '#财运亨通'],
      fortuneLevel: '中吉签',
      fortuneNumber: 65,
    ),
    FortuneData(
      poem: '明月几时有\n把酒问青天',
      goodThings: ['独处思考', '创作灵感'],
      badThings: ['社交应酬', '强求缘分'],
      tips: '独处时光最适合沉淀\n紫色能激发创造力',
      tags: ['#艺术灵感', '#心灵成长'],
      fortuneLevel: '凶签',
      fortuneNumber: 33,
    ),
    FortuneData(
      poem: '福星高照喜事临\n万事如意步步升',
      goodThings: ['团队合作', '公开演讲'],
      badThings: ['独断专行', '操之过急'],
      tips: '集体智慧能带来惊喜\n金色能增添自信',
      tags: ['#贵人运', '#团队之星'],
      fortuneLevel: '上吉签',
      fortuneNumber: 77,
    ),
    FortuneData(
      poem: '春暖花开好时节\n一切顺遂皆如意',
      goodThings: ['户外运动', '结识新友'],
      badThings: ['贪图安逸', '缺乏锻炼'],
      tips: '适当运动增添活力\n绿色带来好运气',
      tags: ['#健康运', '#活力四射'],
      fortuneLevel: '小吉签',
      fortuneNumber: 55,
    ),
  ];
}
