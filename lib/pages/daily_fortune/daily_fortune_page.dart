import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../modules/style/app_theme.dart';
import 'dart:math' show Random, sin, pi;
import 'widgets/fortune_barrel.dart';
import 'models/fortune_data.dart';
import 'data/test_fortune_data.dart';
import '../fortune_telling/fortune_report_page.dart';
import '../../models/fortune_report.dart';
import '../../data/fortune_static_data.dart';

class DailyFortunePage extends StatefulWidget {
  const DailyFortunePage({super.key});

  @override
  State<DailyFortunePage> createState() => _DailyFortunePageState();
}

class _DailyFortunePageState extends State<DailyFortunePage>
    with SingleTickerProviderStateMixin {
  FortuneData? _currentFortune;
  late AnimationController _shakeController;
  bool _isShaking = false;
  final List<_SakuraParticle> _sakuraParticles = [];

  // 使用静态数据文件中的运势样式映射
  final Map<String, Map<String, dynamic>> _fortuneStyles = FortuneStaticData.fortuneStyles;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 初始状态不显示运势
    _currentFortune = null;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleShake() {
    if (_isShaking) return;

    setState(() {
      _isShaking = true;
      _sakuraParticles.clear();
    });

    _shakeController.forward(from: 0).then((_) {
      setState(() {
        _isShaking = false;
        // 随机选择一个新的运势
        _currentFortune =
            TestFortuneData.testFortunes[Random().nextInt(
              TestFortuneData.testFortunes.length,
            )];
        _addSakuraParticles();
      });
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

  Widget _buildFortuneCard() {
    if (_currentFortune == null) return const SizedBox();

    // 获取样式并提供默认值
    final fortuneLevel = _currentFortune!.fortuneLevel;
    final style = _fortuneStyles[fortuneLevel] ?? _fortuneStyles['上上签']!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => FortuneReportPage(
                  report: FortuneStaticData.convertToFortuneReport(_currentFortune!),
                ),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
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
            child: child,
          );
        },
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
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
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
                      Icon(Icons.compass_calibration, color: style['color']),
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
                              )),
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
                              )),
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
                      Icon(Icons.lightbulb_outline, color: style['color']),
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
                children:
                    _currentFortune!.tags
                        .map(
                          (tag) => Container(
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
                          ),
                        )
                        .toList(),
              ),
            ),

            const SizedBox(height: 16),

            // 添加点击提示
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 16,
                    color: style['color'].withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '点击查看详细解签',
                    style: TextStyle(
                      fontSize: 12,
                      color: style['color'].withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFortuneRatioCard() {
    // 获取当前运势的样式
    final currentStyle = _currentFortune != null 
        ? _fortuneStyles[_currentFortune!.fortuneLevel]!
        : _fortuneStyles['上上签']!;

    // 根据当前运势设置不同的概率分布
    Map<String, String> ratios = FortuneStaticData.getRatiosByFortuneLevel(_currentFortune?.fortuneLevel ?? '上上签');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: currentStyle['gradient'] as LinearGradient,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日喵签',
            style: AppTheme.titleStyle.copyWith(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRatioItem('大吉', ratios['大吉']!, currentStyle),
              _buildRatioItem('中吉', ratios['中吉']!, currentStyle),
              _buildRatioItem('小吉', ratios['小吉']!, currentStyle),
              _buildRatioItem('凶', ratios['凶']!, currentStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatioItem(String label, String percentage, Map<String, dynamic> style) {
    return Column(
      children: [
        Text(
          percentage,
          style: AppTheme.titleStyle.copyWith(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodyStyle.copyWith(
            color: Colors.white.withOpacity(0.9),
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
                      ),
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
              '今日喵签',
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
              if (!_isShaking) _handleShake();
            },
          ),
        ),
        const SizedBox(height: 30),
        AnimatedOpacity(
          opacity: _isShaking ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            '轻触签筒开启今日喵签',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  // 将 FortuneData 转换为 FortuneReport - 使用静态数据文件中的方法
  FortuneReport _convertToFortuneReport(FortuneData data) {
    return FortuneStaticData.convertToFortuneReport(data);
  }
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
