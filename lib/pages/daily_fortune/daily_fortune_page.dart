import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../modules/style/app_theme.dart';
import 'dart:math' as math show Random, sin, pi;
import 'widgets/fortune_barrel.dart';
import 'models/fortune_data.dart';
import '../fortune_telling/fortune_report_page.dart';
import '../../models/fortune_report.dart';
import '../../data/daily_fortune_static_data.dart';
import 'dart:async';

// 导入平台检测
import 'package:flutter/foundation.dart' show kIsWeb;

// 可能会失败的导入，使用try-catch处理
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // New: Background animation controller and particles
  final List<_BackgroundParticle> _bgParticles = [];
  Timer? _bgAnimationTimer;

  // 新增: 摇签阶段控制
  int _shakeStage = 0;
  bool _isLoading = false;
  String _feedbackText = '';
  List<String> _shakeFeedbackTexts = [
    '喵咪咒语生效中...',
    '喵咪正在占卜未来...',
    '运势即将揭晓...',
    '快有结果啦！'
  ];
  
  // 新增: 延长摇签动画时间控制
  Timer? _stageTimer;
  final int _stagesCount = 4;
  final int _stageDuration = 700; // 毫秒

  // 使用静态数据文件中的运势样式映射
  final Map<String, Map<String, dynamic>> _fortuneStyles = DailyFortuneStaticData.fortuneStyles;
  
  // 摇晃检测相关变量
  StreamSubscription<dynamic>? _accelerometerSubscription;
  DateTime? _lastShakeTime;
  final double _shakeThreshold = 15.0; // 摇晃阈值，可根据需要调整
  final int _shakeCooldown = 1000; // 摇晃冷却时间（毫秒）
  
  // 摇晃反馈相关变量
  bool _isDeviceShaking = false;
  Timer? _shakeResetTimer;
  
  // 震动反馈相关变量
  bool _canVibrate = false;
  
  // 教程相关变量
  bool _showTutorial = false;
  static const String _tutorialShownKey = 'shake_tutorial_shown';
  
  // 功能可用性标志
  bool _isShakeDetectionAvailable = false;
  bool _isVibrationAvailable = false;
  bool _isPrefsAvailable = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 初始状态不显示运势
    _currentFortune = null;
    
    // 检查功能可用性并初始化
    _checkFeaturesAvailability();
    
    // Initialize background particles
    _initBackgroundParticles();
  }
  
  // 检查功能可用性并初始化
  Future<void> _checkFeaturesAvailability() async {
    // 在Web平台上禁用这些功能
    if (kIsWeb) {
      _isShakeDetectionAvailable = false;
      _isVibrationAvailable = false;
      _isPrefsAvailable = false;
      return;
    }
    
    // 尝试初始化摇晃检测
    try {
      await _initShakeDetection();
      _isShakeDetectionAvailable = true;
    } catch (e) {
      debugPrint('摇晃检测不可用: $e');
      _isShakeDetectionAvailable = false;
    }
    
    // 尝试检查震动支持
    try {
      await _checkVibrationSupport();
      _isVibrationAvailable = true;
    } catch (e) {
      debugPrint('震动功能不可用: $e');
      _isVibrationAvailable = false;
    }
    
    // 尝试检查SharedPreferences
    try {
      await _checkShowTutorial();
      _isPrefsAvailable = true;
    } catch (e) {
      debugPrint('SharedPreferences不可用: $e');
      _isPrefsAvailable = false;
      // 如果SharedPreferences不可用，不显示教程
      _showTutorial = false;
    }
  }
  
  // 检查是否需要显示教程
  Future<void> _checkShowTutorial() async {
    if (!_isShakeDetectionAvailable) {
      // 如果摇晃检测不可用，不显示教程
      _showTutorial = false;
      return;
    }
    
    try {
      // 获取SharedPreferences实例
      final prefs = await SharedPreferences.getInstance();
      
      // 检查是否已经显示过教程
      bool tutorialShown = prefs.getBool(_tutorialShownKey) ?? false;
      
      if (!tutorialShown) {
        // 延迟显示教程，确保界面已经构建完成
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _showTutorial = true;
            });
            
            // 3秒后自动关闭教程
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _showTutorial = false;
                });
                
                // 保存教程已显示的状态
                _saveTutorialShown();
              }
            });
          }
        });
      }
    } catch (e) {
      debugPrint('检查教程状态失败: $e');
      // 出错时不显示教程
      _showTutorial = false;
    }
  }
  
  // 保存教程已显示的状态
  Future<void> _saveTutorialShown() async {
    if (!_isPrefsAvailable) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_tutorialShownKey, true);
    } catch (e) {
      debugPrint('保存教程状态失败: $e');
    }
  }
  
  // 关闭教程
  void _closeTutorial() {
    setState(() {
      _showTutorial = false;
    });
    
    // 保存教程已显示的状态
    _saveTutorialShown();
  }
  
  // 检查设备是否支持震动
  Future<void> _checkVibrationSupport() async {
    try {
      bool canVibrate = await Vibrate.canVibrate;
      setState(() {
        _canVibrate = canVibrate;
      });
    } catch (e) {
      debugPrint('检查震动支持失败: $e');
      setState(() {
        _canVibrate = false;
      });
      // 重新抛出异常以便上层捕获
      rethrow;
    }
  }
  
  // 提供震动反馈
  void _vibrateDevice() {
    if (!_isVibrationAvailable || !_canVibrate) return;
    
    try {
      Vibrate.feedback(FeedbackType.medium);
    } catch (e) {
      debugPrint('震动反馈失败: $e');
    }
  }
  
  // 初始化摇晃检测
  Future<void> _initShakeDetection() async {
    try {
      // 监听加速度传感器事件
      _accelerometerSubscription = accelerometerEvents.listen(
        (AccelerometerEvent event) {
          // 计算加速度向量的大小
          double acceleration = _calculateAcceleration(event);
          
          // 检测是否为摇晃动作
          if (_isShakeGesture(acceleration)) {
            // 设置设备正在摇晃的状态
            setState(() {
              _isDeviceShaking = true;
            });
            
            // 提供震动反馈
            _vibrateDevice();
            
            // 触发抽签动作
            _handleShake();
            
            // 重置摇晃状态的定时器
            _shakeResetTimer?.cancel();
            _shakeResetTimer = Timer(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _isDeviceShaking = false;
                });
              }
            });
          }
        },
        onError: (error) {
          // 处理传感器错误
          debugPrint('加速度传感器错误: $error');
          _isShakeDetectionAvailable = false;
        },
        cancelOnError: false,
      );
    } catch (e) {
      // 处理初始化错误
      debugPrint('初始化加速度传感器失败: $e');
      // 重新抛出异常以便上层捕获
      rethrow;
    }
  }
  
  // 计算加速度向量的大小
  double _calculateAcceleration(dynamic event) {
    // 使用三维加速度的平方和的平方根
    return (event.x * event.x + event.y * event.y + event.z * event.z);
  }
  
  // 判断是否为摇晃手势
  bool _isShakeGesture(double acceleration) {
    // 当前时间
    final now = DateTime.now();
    
    // 检查是否超过阈值且不在冷却期内
    if (acceleration > _shakeThreshold * _shakeThreshold) {
      if (_lastShakeTime == null || now.difference(_lastShakeTime!).inMilliseconds > _shakeCooldown) {
        _lastShakeTime = now;
        return true;
      }
    }
    
    return false;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    // 取消加速度传感器订阅
    _accelerometerSubscription?.cancel();
    // 取消定时器
    _shakeResetTimer?.cancel();
    // 新增: 取消阶段定时器
    _stageTimer?.cancel();
    // Cancel background animation timer
    _bgAnimationTimer?.cancel();
    super.dispose();
  }

  void _handleShake() {
    if (_isShaking) return;

    setState(() {
      _isShaking = true;
      _isLoading = true;
      _shakeStage = 0;
      _feedbackText = _shakeFeedbackTexts[0];
      _sakuraParticles.clear();
    });

    // 启动摇晃动画
    _shakeController.repeat(reverse: true);
    
    // 开始阶段性动画
    _progressShakeStages();
  }
  
  // 新增: 处理摇签的阶段性进展
  void _progressShakeStages() {
    _stageTimer?.cancel();
    
    // 创建定时器处理各阶段
    _stageTimer = Timer.periodic(Duration(milliseconds: _stageDuration), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_shakeStage < _stagesCount - 1) {
        setState(() {
          _shakeStage++;
          _feedbackText = _shakeFeedbackTexts[_shakeStage < _shakeFeedbackTexts.length 
              ? _shakeStage 
              : _shakeFeedbackTexts.length - 1];
        });
      } else {
        // 最后阶段完成后，停止摇晃动画并显示结果
        timer.cancel();
        _finishShakeAnimation();
      }
    });
  }
  
  // 新增: 结束摇晃动画并显示结果
  void _finishShakeAnimation() {
    // 停止摇晃动画
    _shakeController.stop();
    _shakeController.reset();
    
    // 随机选择一个新的运势
    // 创建一个独立的Random实例，避免在快速连续调用时返回相同的值
    final random = math.Random(DateTime.now().millisecondsSinceEpoch);
    final randomFortune = DailyFortuneStaticData.testFortunes[
      random.nextInt(DailyFortuneStaticData.testFortunes.length)
    ];
    
    // 添加结果特效和过渡动画
    setState(() {
      _isShaking = false;
      _isLoading = false;
      _currentFortune = randomFortune;
      _addSakuraParticles();
    });
  }

  void _addSakuraParticles() {
    for (int i = 0; i < 10; i++) {
      _sakuraParticles.add(
        _SakuraParticle(
          x: math.Random().nextDouble() * MediaQuery.of(context).size.width,
          y: -50,
          size: 20 + math.Random().nextDouble() * 20,
          velocity: 2 + math.Random().nextDouble() * 2,
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
        particle.x += math.sin(particle.y / 50) * 2;
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

    // 新增：动画控制变量
    final bool animationsComplete = true;
    final bool showHeader = animationsComplete;
    final bool showPoem = animationsComplete;
    final bool showGuide = animationsComplete;
    final bool showTips = animationsComplete;
    final bool showTags = animationsComplete;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => FortuneReportPage(
                  report: DailyFortuneStaticData.convertToFortuneReport(_currentFortune!),
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
            _AnimatedCardSection(
              delayMs: 200,
              child: Padding(
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
                            boxShadow: [
                              BoxShadow(
                                color: style['borderColor'].withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
                            boxShadow: [
                              BoxShadow(
                                color: style['borderColor'].withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
                          boxShadow: [
                            BoxShadow(
                              color: style['borderColor'].withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
            ),

            // 运势指南
            _AnimatedCardSection(
              delayMs: 500,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: style['tagColor'],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: style['borderColor'].withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.green[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.green[600],
                                        size: 18,
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
                                ),
                                const SizedBox(height: 12),
                                ...(_currentFortune!.goodThings.map(
                                  (thing) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 6, right: 8),
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.green[400],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            thing,
                                            style: TextStyle(
                                              fontSize: 14,
                                              height: 1.4,
                                              color: Colors.black.withOpacity(0.85),
                                            ),
                                          ),
                                        ),
                                      ],
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.orange[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_outlined,
                                        color: Colors.orange[600],
                                        size: 18,
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
                                ),
                                const SizedBox(height: 12),
                                ...(_currentFortune!.badThings.map(
                                  (thing) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 6, right: 8),
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.orange[400],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            thing,
                                            style: TextStyle(
                                              fontSize: 14,
                                              height: 1.4,
                                              color: Colors.black.withOpacity(0.85),
                                            ),
                                          ),
                                        ),
                                      ],
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
            ),

            // 解签小贴士
            _AnimatedCardSection(
              delayMs: 800,
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: style['tagColor'],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: style['borderColor'].withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: style['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.lightbulb_outline, color: style['color']),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '解签小贴士',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.85),
                            letterSpacing: 0.5,
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
            ),

            const SizedBox(height: 16),

            // 标签
            _AnimatedCardSection(
              delayMs: 1000,
              child: Padding(
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
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: style['tagColor'],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: style['borderColor'].withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 添加点击提示
            _AnimatedCardSection(
              delayMs: 1200,
              offsetDirection: const Offset(0, 0.3),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 16,
                      color: style['color'].withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '点击查看详细解签',
                      style: TextStyle(
                        fontSize: 14,
                        color: style['color'].withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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
    Map<String, String> ratios = DailyFortuneStaticData.getRatiosByFortuneLevel(_currentFortune?.fortuneLevel ?? '上上签');

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFF6FA),
              const Color(0xFFFEF0F7),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background particles - reduce count and opacity for subtlety
            ..._bgParticles.take(8).map((particle) => Positioned(
              left: particle.x,
              top: particle.y,
              child: _buildBackgroundParticle(particle),
            )),
            
            // Decorative elements - made more subtle
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -70,
              left: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.04),
                ),
              ),
            ),
            
            // Main content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
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
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                _buildFortuneRatioCard(),
                                _buildFortuneCard(),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
            ),
            
            // 摇晃教程覆盖层 - 只在摇晃检测可用时显示
            if (_showTutorial && _currentFortune == null && _isShakeDetectionAvailable)
              _buildTutorialOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildShakeInterface() {
    // Reduce bottom padding for a better layout
    final bottomPadding = MediaQuery.of(context).padding.bottom + 20;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return SafeArea(
      bottom: false, // Don't use SafeArea for bottom since we'll handle padding manually
      child: Stack(
        children: [
          // Main content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Increased top spacing to move content down
                  SizedBox(height: screenHeight * 0.08),
                  
                  // Title section - centered properly
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "今日喵签",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            letterSpacing: 2,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        Text(
                          "探索未知，聆听喵语",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Increased spacing between title and barrel
                  SizedBox(height: screenHeight * 0.08),
                  
                  // Fortune barrel with cleaner design - properly centered, removed the 喵签筒 text
                  // Enlarged barrel for better vertical space utilization
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: _isDeviceShaking ? 5.0 : 0),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutQuint,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(
                            math.sin(value * 2) * 3,
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          if (!_isShaking) _handleShake();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18), // Increased padding
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.15),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: FortuneBarrel(
                            isShaking: _isShaking,
                            onShake: () {
                              if (!_isShaking) _handleShake();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Dynamic spacing based on screen height
                  SizedBox(height: screenHeight * 0.06),
                  
                  // Improved interaction instructions - highlighting the shake feature
                  Center(
                    child: AnimatedOpacity(
                      opacity: _isShaking ? 1.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: _isShaking 
                          ? _buildShakingFeedback()
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isShakeDetectionAvailable) ...[
                                  // Shake feature now highlighted first
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primary.withOpacity(0.2),
                                          AppTheme.primary.withOpacity(0.1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primary.withOpacity(0.1),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.7),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.vibration,
                                            size: 20,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '✨ 摇晃手机抽取喵签',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '感受心灵的摇动',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.primary.withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.touch_app,
                                        size: 16,
                                        color: AppTheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '轻触签筒开启今日喵签',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  // Flexible spacing that adjusts based on screen size
                  SizedBox(height: screenHeight * 0.12),
                ],
              ),
            ),
          ),
          
          // White transition area at the bottom to blend with the navigation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60 + bottomPadding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.8),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 新增: 构建摇晃反馈UI
  Widget _buildShakingFeedback() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 阶段性进度指示器
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_stagesCount, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index <= _shakeStage 
                    ? const Color(0xFFFF69B4) 
                    : const Color(0xFFFF69B4).withOpacity(0.3),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        
        // 动态反馈文本
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            _feedbackText,
            key: ValueKey<String>(_feedbackText),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFF69B4),
            ),
          ),
        ),
        
        // 猫咪动画指示符
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF69B4),
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: math.sin((value * math.pi) + (i * 0.5)).abs(),
                      child: child,
                    );
                  },
                  child: Container(),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // 构建教程覆盖层
  Widget _buildTutorialOverlay() {
    return GestureDetector(
      onTap: _closeTutorial,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.vibration,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              '新功能: 摇晃手机抽签',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '现在您可以通过摇晃手机来抽取今日喵签，无需点击签筒！',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF69B4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '点击任意位置关闭',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 将 FortuneData 转换为 FortuneReport - 使用静态数据文件中的方法
  FortuneReport _convertToFortuneReport(FortuneData data) {
    return DailyFortuneStaticData.convertToFortuneReport(data);
  }

  // Build background particle widget
  Widget _buildBackgroundParticle(_BackgroundParticle particle) {
    Widget particleWidget;
    
    switch (particle.shape) {
      case 0: // Circle
        particleWidget = Container(
          width: particle.size,
          height: particle.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary.withOpacity(particle.opacity),
          ),
        );
        break;
      case 1: // Square
        particleWidget = Container(
          width: particle.size,
          height: particle.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppTheme.primary.withOpacity(particle.opacity),
          ),
        );
        break;
      case 2: // Star-like shape
      default:
        particleWidget = Transform.rotate(
          angle: particle.x / 100,
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primary.withOpacity(particle.opacity * 1.5),
                  AppTheme.primary.withOpacity(0),
                ],
              ),
            ),
          ),
        );
        break;
    }
    
    return particleWidget;
  }
  
  void _initBackgroundParticles() {
    final random = math.Random();
    _bgParticles.clear();
    // Reduce number of particles for subtlety
    for (int i = 0; i < 8; i++) {
      _bgParticles.add(
        _BackgroundParticle(
          x: random.nextDouble() * 400,
          y: random.nextDouble() * 800,
          size: 6 + random.nextDouble() * 12, // Smaller particles
          opacity: 0.05 + random.nextDouble() * 0.12, // More subtle opacity
          velocity: 0.1 + random.nextDouble() * 0.3, // Slower movement
          shape: random.nextInt(3),
        ),
      );
    }
    _animateBackground();
  }
  
  void _animateBackground() {
    if (!mounted) return;
    
    _bgAnimationTimer?.cancel();
    _bgAnimationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        for (var particle in _bgParticles) {
          particle.y += particle.velocity;
          particle.x += math.sin(particle.y / 100) * 0.5;
          
          // Reset if out of screen
          if (particle.y > MediaQuery.of(context).size.height) {
            particle.y = -particle.size;
            particle.x = math.Random().nextDouble() * MediaQuery.of(context).size.width;
          }
        }
      });
    });
  }

  // Override the "重新抽签" functionality to reset the state
  void _resetFortune() {
    setState(() {
      _currentFortune = null;
    });
  }

  // Add this method to handle tapping on the fortune card
  void _navigateToFortuneDetail() {
    if (_currentFortune == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FortuneReportPage(
          report: _convertToFortuneReport(_currentFortune!),
        ),
      ),
    ).then((_) {
      // Add option to reset after coming back from the detail page
      if (mounted) {
        // You can decide if you want to reset automatically or not
        // _resetFortune();
      }
    });
  }
}

class _AnimatedCardSection extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final Offset offsetDirection;
  
  const _AnimatedCardSection({
    required this.child, 
    required this.delayMs,
    this.offsetDirection = const Offset(0, 0.2),
  });
  
  @override
  State<_AnimatedCardSection> createState() => _AnimatedCardSectionState();
}

class _AnimatedCardSectionState extends State<_AnimatedCardSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: widget.offsetDirection,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    // 延迟显示
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        setState(() => _isVisible = true);
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: FractionalTranslation(
            translation: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
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

class _BackgroundParticle {
  double x;
  double y;
  final double size;
  final double opacity;
  final double velocity;
  final int shape; // 0: circle, 1: square, 2: star-like

  _BackgroundParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.velocity,
    required this.shape,
  });
}
