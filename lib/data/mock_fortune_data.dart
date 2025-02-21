import '../models/fortune_report.dart';

final mockFortuneReport = FortuneReport(
  id: 'daily-20250221',
  createdAt: DateTime.now(),
  birthDate: DateTime.now(),
  bloodType: 'A',
  level: FortuneLevel.excellent,
  poem: '东风夜放花千树，更吹落、星如雨。',
  poemInterpretation: '这首诗描绘了一个繁花似锦、星光璀璨的美好景象，预示着你今天将会遇到许多美好的事物和机遇。',
  predictions: [
    FortunePrediction(
      type: FortuneType.love,
      description: '今日桃花运旺盛，单身的你可能会遇到意想不到的缘分，已有伴侣的人感情会更加甜蜜。',
      score: 95,
      suggestions: [
        '穿着明亮的衣服出门，提升好感度',
        '多参加社交活动，增加偶遇的机会',
        '对喜欢的人要主动表达感情'
      ],
    ),
    FortunePrediction(
      type: FortuneType.career,
      description: '工作上会遇到贵人相助，有机会展现自己的才能，得到上级的赏识。',
      score: 88,
      suggestions: [
        '把握机会展示自己的能力',
        '与同事保持良好的沟通',
        '合理规划工作时间'
      ],
    ),
    FortunePrediction(
      type: FortuneType.wealth,
      description: '财运亨通，可能会有意外收获，投资方面也会有好的回报。',
      score: 90,
      suggestions: [
        '可以考虑进行稳健的投资',
        '注意开源节流，合理消费',
        '留意新的理财机会'
      ],
    ),
    FortunePrediction(
      type: FortuneType.health,
      description: '身体状况良好，精力充沛，适合进行运动健身。',
      score: 85,
      suggestions: [
        '保持规律的作息时间',
        '适量运动，增强体质',
        '注意饮食均衡'
      ],
    ),
  ],
  luckySuggestions: [
    '早起喝一杯温水，开启美好一天',
    '整理房间，提升居住环境的舒适度',
    '与好友分享快乐，传递正能量'
  ],
  luckyItems: ['幸运猫咪挂饰', '红色钱包', '水晶手链'],
  luckyColors: ['粉色', '白色', '金色'],
  luckyNumbers: [2, 7, 9],
);
