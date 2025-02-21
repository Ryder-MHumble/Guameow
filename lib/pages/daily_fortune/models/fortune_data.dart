/// 喵签数据模型
class FortuneData {
  /// 签诗
  final String poem;
  
  /// 宜做的事情列表
  final List<String> goodThings;
  
  /// 忌做的事情列表
  final List<String> badThings;
  
  /// 解签小贴士
  final String tips;
  
  /// 标签列表
  final List<String> tags;
  
  /// 运势等级（上上签、上吉签、中吉签、小吉签、凶签）
  final String fortuneLevel;
  
  /// 签号
  final int fortuneNumber;

  const FortuneData({
    required this.poem,
    required this.goodThings,
    required this.badThings,
    required this.tips,
    required this.tags,
    required this.fortuneLevel,
    required this.fortuneNumber,
  });
}
