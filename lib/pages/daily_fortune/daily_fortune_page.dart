import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../modules/style/app_theme.dart';
import 'dart:math' show Random, sin, pi;
import 'widgets/fortune_barrel.dart';

class DailyFortunePage extends StatefulWidget {
  const DailyFortunePage({Key? key}) : super(key: key);

  @override
  State<DailyFortunePage> createState() => _DailyFortunePageState();
}

class FortuneData {
  final String poem;
  final List<String> goodThings;
  final List<String> badThings;
  final String tips;
  final List<String> tags;
  final String fortuneLevel;
  final int fortuneNumber;

  FortuneData({
    required this.poem,
    required this.goodThings,
    required this.badThings,
    required this.tips,
    required this.tags,
    required this.fortuneLevel,
    required this.fortuneNumber,
  });

  static final List<FortuneData> _testFortunes = [
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

  static int _currentFortuneIndex = 0;

  static FortuneData generate() {
    // 循环遍历测试运势数据
    final fortune = _testFortunes[_currentFortuneIndex];
    _currentFortuneIndex = (_currentFortuneIndex + 1) % _testFortunes.length;
    return fortune;
  }
}

class FortuneBarrelPainter extends CustomPainter {
  final Color color;

  FortuneBarrelPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    // 绘制竖线纹理
    for (double x = 10; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 绘制横线纹理
    for (double y = 10; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 绘制圆形装饰
    final circlePaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, 15), 5, circlePaint);
  }

  @override
  bool shouldRepaint(FortuneBarrelPainter oldDelegate) => false;
}

class _SakuraParticle {
  double x;
  double y;
  final double size;
  final double velocity;

  _SakuraParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.velocity,
  });
}

class _DailyFortunePageState extends State<DailyFortunePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  FortuneData? _currentFortune;
  bool _isShaking = false;
  final List<_SakuraParticle> _sakuraParticles = [];

  // 定义不同签的样式
  final Map<String, Map<String, dynamic>> _fortuneStyles = {
    '上上签': {
      'icon': '✨',
      'color': const Color(0xFFFF69B4),
      'gradient': const LinearGradient(
        colors: [Color(0xFFFF69B4), Color(0xFFFFB6C1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'borderColor': const Color(0xFFFFB6C1),
      'tagColor': const Color(0xFFFFF0F5),
    },
    '上吉签': {
      'icon': '🌟',
      'color': const Color(0xFF9370DB),
      'gradient': const LinearGradient(
        colors: [Color(0xFF9370DB), Color(0xFFE6E6FA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'borderColor': const Color(0xFFE6E6FA),
      'tagColor': const Color(0xFFF5F0FF),
    },
    '中吉签': {
      'icon': '⭐',
      'color': const Color(0xFF4169E1),
      'gradient': const LinearGradient(
        colors: [Color(0xFF4169E1), Color(0xFF87CEEB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'borderColor': const Color(0xFF87CEEB),
      'tagColor': const Color(0xFFF0F8FF),
    },
    '小吉签': {
      'icon': '🍀',
      'color': const Color(0xFF3CB371),
      'gradient': const LinearGradient(
        colors: [Color(0xFF3CB371), Color(0xFF98FB98)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'borderColor': const Color(0xFF98FB98),
      'tagColor': const Color(0xFFF0FFF0),
    },
    '凶签': {
      'icon': '🌧',
      'color': const Color(0xFF808080),
      'gradient': const LinearGradient(
        colors: [Color(0xFF808080), Color(0xFFC0C0C0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'borderColor': const Color(0xFFC0C0C0),
      'tagColor': const Color(0xFFF5F5F5),
    },
  };

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _sakuraParticles.clear();
    super.dispose();
  }

  Future<void> _handleShake() async {
    if (_isShaking) return;

    setState(() => _isShaking = true);
    _shakeController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isShaking = false;
      _currentFortune = FortuneData.generate();
      _addSakuraParticles();
    });
  }

  void _addSakuraParticles() {
    for (int i = 0; i < 10; i++) {
      _sakuraParticles.add(
        _SakuraParticle(
          x: Random().nextDouble() * MediaQuery.of(context).size.width,
          y: -50,
          size: 20 + Random().nextDouble() * 20,
          velocity: 2 + Random().nextDouble() * 2,
        ),
      );
    }
    _animateSakura();
  }

  void _animateSakura() {
    if (!mounted) return;

    setState(() {
      for (var particle in _sakuraParticles) {
        particle.y += particle.velocity;
        particle.x += sin(particle.y / 50) * 2;
      }

      _sakuraParticles.removeWhere((particle) {
        return particle.y > MediaQuery.of(context).size.height;
      });
    });

    if (_sakuraParticles.isNotEmpty && mounted) {
      Future.delayed(const Duration(milliseconds: 16), _animateSakura);
    }
  }

  void _startShaking() {
    setState(() => _isShaking = true);
    _shakeController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 800)).then((_) {
      setState(() {
        _isShaking = false;
        _currentFortune = FortuneData.generate();
        _addSakuraParticles();
      });
    });
  }

  Widget _buildFortuneCard() {
    if (_currentFortune == null) return const SizedBox();

    // 获取样式并提供默认值
    final fortuneLevel = _currentFortune!.fortuneLevel;
    final style = _fortuneStyles[fortuneLevel] ?? _fortuneStyles['上上签']!;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (style['color'] as Color).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题部分
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0.8, end: 1.0),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: style['gradient'],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(style['icon'], style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        '今日${_currentFortune!.fortuneLevel}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(style['icon'], style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              );
            },
          ),

          // 签文内容
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧签筒图标
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        color: style['tagColor'],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: style['borderColor'].withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            size: 32,
                            color: style['color'],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '第${_currentFortune!.fortuneNumber}签',
                            style: TextStyle(
                              fontSize: 12,
                              color: style['color'],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: style['tagColor'],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: style['borderColor'].withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _currentFortune!.fortuneLevel,
                        style: TextStyle(
                          fontSize: 14,
                          color: style['color'],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),

                // 右侧签文
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: style['tagColor'],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: style['borderColor'].withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _currentFortune!.poem,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.8,
                        color: Colors.black.withOpacity(0.85),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 运势指南
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.compass_calibration,
                      color: style['color'],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '运势指南',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: style['tagColor'],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: style['borderColor'].withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 宜
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green[400],
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '宜',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...(_currentFortune!.goodThings.map(
                              (thing) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  thing,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withOpacity(0.85),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )).toList(),
                          ],
                        ),
                      ),
                      Container(
                        height: 80,
                        width: 1,
                        color: style['borderColor'].withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      // 忌
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_outlined,
                                  color: Colors.orange[400],
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '忌',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...(_currentFortune!.badThings.map(
                              (thing) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  thing,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withOpacity(0.85),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 解签小贴士
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: style['tagColor'],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: style['borderColor'].withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: style['color'],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '解签小贴士',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _currentFortune!.tips,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 标签
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentFortune!.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: style['tagColor'],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: style['borderColor'].withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    color: style['color'],
                  ),
                ),
              )).toList(),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFortuneRatioCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.8),
            AppTheme.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日运势',
            style: AppTheme.titleStyle.copyWith(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRatioItem('大吉', '30%'),
              _buildRatioItem('中吉', '45%'),
              _buildRatioItem('小吉', '20%'),
              _buildRatioItem('凶', '5%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatioItem(String label, String percentage) {
    return Column(
      children: [
        Text(
          percentage,
          style: AppTheme.titleStyle.copyWith(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodyStyle.copyWith(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0,
              child: child,
            ),
          );
        },
        child:
            _currentFortune == null
                ? _buildShakeInterface()
                : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildFortuneRatioCard(),
                          _buildFortuneCard(),
                        ],
                      )
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildShakeInterface() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              '今日运势',
              textAlign: TextAlign.center,
              textStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF69B4),
              ),
            ),
          ],
          totalRepeatCount: 1,
        ),
        const SizedBox(height: 50),
        Center(
          child: FortuneBarrel(
            isShaking: _isShaking,
            onShake: () {
              if (!_isShaking) _startShaking();
            },
          ),
        ),
        const SizedBox(height: 30),
        AnimatedOpacity(
          opacity: _isShaking ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            '轻触签筒开启今日运势',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
