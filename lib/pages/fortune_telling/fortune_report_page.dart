import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math show Random, pi, cos, sin;
import '../../models/fortune_report.dart';
import '../../modules/style/app_theme.dart';
import '../../data/daily_fortune_static_data.dart';
import '../../services/share_service.dart';
import 'widgets/fortune_share_card.dart';

class FortuneReportPage extends StatefulWidget {
  final FortuneReport report;

  const FortuneReportPage({super.key, required this.report});

  @override
  State<FortuneReportPage> createState() => _FortuneReportPageState();
}

class _FortuneReportPageState extends State<FortuneReportPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  
  // 添加用于截图的Global Key
  final GlobalKey _shareCardKey = GlobalKey();
  bool _isShareCardVisible = false;
  
  // 新增：元素级联动画控制
  bool _showHeaderCard = false;
  bool _showPredictions = false;
  bool _showLuckyAdvice = false;
  
  // 新增：粒子效果控制
  final List<FortuneParticle> _particles = [];
  
  // 新增：触摸反馈控制
  bool _isHeaderPressed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    
    // 使用WidgetsBinding.instance.addPostFrameCallback来确保context是有效的
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scheduleElementsAnimation();
        _generateParticles();
      }
    });
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeOutCubic),
    );

    _controller!.forward();
  }
  
  // 优化：调度元素的级联动画更丝滑
  void _scheduleElementsAnimation() {
    // 头部卡片动画
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _showHeaderCard = true);
      }
    });
    
    // 预测卡片动画
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showPredictions = true);
      }
    });
    
    // 开运建议动画
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showLuckyAdvice = true);
      }
    });
  }
  
  // 优化：生成更美观的粒子效果
  void _generateParticles() {
    final levelColor = _getLevelColor(widget.report.level);
    final random = math.Random();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // 优化粒子分布
    for (int i = 0; i < 15; i++) {
      _particles.add(
        FortuneParticle(
          position: Offset(
            random.nextDouble() * screenWidth,
            random.nextDouble() * screenHeight,
          ),
          color: levelColor.withOpacity(0.05 + random.nextDouble() * 0.1),
          size: 2.0 + (random.nextDouble() * 8.0),
          velocity: Offset(
            (random.nextDouble() - 0.5) * 0.8,
            -0.3 - random.nextDouble() * 0.5,
          ),
          shape: random.nextInt(3), // 随机形状: 0=圆形, 1=方形, 2=星形
        ),
      );
    }
    
    _animateParticles();
  }
  
  // 优化：粒子动画更流畅
  void _animateParticles() {
    if (!mounted) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final random = math.Random();
    
    // 使用临时列表存储更新后的粒子状态
    final updatedParticles = <FortuneParticle>[];
    
    for (var particle in _particles) {
      final newPosition = particle.position + particle.velocity;
      var newVelocity = particle.velocity;
      
      // 边界检查与更自然的重置
      if (newPosition.dy < -10) {
        // 从底部重新进入
        updatedParticles.add(
          FortuneParticle(
            position: Offset(
              random.nextDouble() * screenWidth,
              screenHeight + random.nextDouble() * 10,
            ),
            color: particle.color,
            size: 2.0 + (random.nextDouble() * 8.0),
            velocity: Offset(
              (random.nextDouble() - 0.5) * 0.8,
              -0.3 - random.nextDouble() * 0.5,
            ),
            shape: random.nextInt(3),
          ),
        );
      } else if (newPosition.dx < -10 || newPosition.dx > screenWidth + 10) {
        // 水平边界反弹
        updatedParticles.add(
          FortuneParticle(
            position: Offset(
              newPosition.dx < 0 ? 0 : screenWidth,
              newPosition.dy
            ),
            color: particle.color,
            size: particle.size,
            velocity: Offset(
              newVelocity.dx * -0.8,
              newVelocity.dy,
            ),
            shape: particle.shape,
          ),
        );
      } else {
        // 正常移动
        updatedParticles.add(
          FortuneParticle(
            position: newPosition,
            color: particle.color,
            size: particle.size,
            velocity: Offset(
              newVelocity.dx,
              newVelocity.dy + 0.002, // 轻微重力效果
            ),
            shape: particle.shape,
          ),
        );
      }
    }
    
    if (mounted) {
      setState(() {
        _particles.clear();
        _particles.addAll(updatedParticles);
      });
    }
    
    Future.delayed(const Duration(milliseconds: 50), _animateParticles);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Color _getLevelColor(FortuneLevel level) {
    return DailyFortuneStaticData.getLevelColor(level);
  }

  Color _getTypeColor(FortuneType type) {
    return DailyFortuneStaticData.getTypeColor(type);
  }

  String _getFortuneTypeIcon(FortuneType type) {
    return DailyFortuneStaticData.getFortuneTypeIcon(type);
  }

  // 优化：更现代化的部分标题设计
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF97C1).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF97C1).withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFFFF97C1), size: 22),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: AppTheme.titleStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // 优化：开运指南部分设计
  Widget _buildLuckyItemsSection() {
    return AnimatedOpacity(
      opacity: _showLuckyAdvice ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
      child: AnimatedSlide(
        offset: _showLuckyAdvice ? Offset.zero : const Offset(0.0, 0.15),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF97C1).withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                const Color(0xFFFFF5F7),
              ],
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
                      color: const Color(0xFFFF97C1).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: const Color(0xFFFF97C1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '开运指南', 
                    style: AppTheme.titleStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // 吉利物品
              if (widget.report.luckyItems.isNotEmpty) ...[
                _buildLuckySubSection(
                  '吉利物品',
                  Icons.card_giftcard,
                  widget.report.luckyItems.join('、'),
                ),
                const SizedBox(height: 14),
              ],
              // 吉利颜色
              if (widget.report.luckyColors.isNotEmpty) ...[
                _buildLuckySubSection(
                  '吉利颜色',
                  Icons.palette,
                  widget.report.luckyColors.join('、'),
                ),
                const SizedBox(height: 14),
              ],
              // 吉利数字
              if (widget.report.luckyNumbers.isNotEmpty) ...[
                _buildLuckySubSection(
                  '吉利数字',
                  Icons.format_list_numbered,
                  widget.report.luckyNumbers.map((n) => n.toString()).join('、'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 优化：开运子部分的设计
  Widget _buildLuckySubSection(String title, IconData icon, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF97C1).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF97C1).withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFFFF97C1), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                content, 
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 优化：头部卡片设计和交互
  Widget _buildHeaderCard() {
    final levelColor = _getLevelColor(widget.report.level);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isHeaderPressed = true),
      onTapUp: (_) => setState(() => _isHeaderPressed = false),
      onTapCancel: () => setState(() => _isHeaderPressed = false),
      child: AnimatedOpacity(
        opacity: _showHeaderCard ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutQuart,
        child: AnimatedScale(
          scale: _showHeaderCard 
              ? (_isHeaderPressed ? 0.98 : 1.0) 
              : 0.95,
          duration: Duration(
            milliseconds: _isHeaderPressed ? 100 : 800
          ),
          curve: _isHeaderPressed 
              ? Curves.easeOut 
              : Curves.easeOutBack,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: levelColor.withOpacity(0.15),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 7),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  levelColor.withOpacity(0.15),
                ],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStarIcon(levelColor),
                      const SizedBox(width: 10),
                      Text(
                        widget.report.level.label,
                        style: TextStyle(
                          color: levelColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildStarIcon(levelColor),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    widget.report.poem,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.8,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (widget.report.poemInterpretation.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 24,
                      top: 8,
                    ),
                    child: Text(
                      widget.report.poemInterpretation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black54,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 新增：创建星星图标组件
  Widget _buildStarIcon(Color color) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          color.withOpacity(0.7),
        ],
      ).createShader(bounds),
      child: const Icon(
        Icons.star_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  // 优化：预测卡片设计和交互
  Widget _buildPredictionCard(FortunePrediction prediction, int index) {
    final typeColor = _getTypeColor(prediction.type);
    final levelColor = _getLevelColor(widget.report.level);
    
    // 计算预测卡片的延迟动画
    final bool showCard = _showPredictions;
    final animationDelay = 0.2 * index; // 每个卡片之间的延迟
    
    return AnimatedOpacity(
      opacity: showCard ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500 + (50 * index)),
      curve: Curves.easeOutQuart,
      child: AnimatedSlide(
        offset: showCard ? Offset.zero : const Offset(0.2, 0.0),
        duration: Duration(milliseconds: 600 + (100 * index)),
        curve: Curves.easeOutQuart,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: typeColor.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 5),
                spreadRadius: 1,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.9),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      typeColor.withOpacity(0.12),
                      typeColor.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: typeColor.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            _getFortuneTypeIcon(prediction.type),
                            width: 22,
                            height: 22,
                            color: typeColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          prediction.type.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: levelColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: levelColor.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            levelColor.withOpacity(0.2),
                            levelColor.withOpacity(0.08),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded, color: levelColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${prediction.score}分',
                            style: TextStyle(
                              color: levelColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.description,
                      style: AppTheme.bodyStyle.copyWith(
                        color: Colors.black54,
                        fontSize: 15,
                        height: 1.5,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (prediction.suggestions.isNotEmpty) ...[
                      Text(
                        '卦喵建议：',
                        style: AppTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...prediction.suggestions.map(
                        (suggestion) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4, right: 6),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: typeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: AppTheme.bodyStyle.copyWith(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示分享选项
  void _showShareOptions() {
    setState(() {
      _isShareCardVisible = true;
    });
    
    // 使用延迟确保ShareCard已经渲染完成
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        ShareService.showShareOptions(
          context, 
          _shareCardKey,
          shareText: '我在『卦喵』获得了今日喵签，推荐你也来试试！',
        ).then((_) {
          // 分享完成后隐藏分享卡片
          if (mounted) {
            setState(() {
              _isShareCardVisible = false;
            });
          }
        }).catchError((error) {
          // 处理分享过程中的错误
          debugPrint('分享过程出错: $error');
          if (mounted) {
            setState(() {
              _isShareCardVisible = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('分享过程中出现错误，请重试'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      } catch (e) {
        // 处理初始化分享过程中的错误
        debugPrint('初始化分享过程出错: $e');
        if (mounted) {
          setState(() {
            _isShareCardVisible = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('无法初始化分享功能，请重试'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }
  
  // 优化：构建背景粒子
  Widget _buildBackgroundParticles() {
    return Positioned.fill(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: ParticlesPainter(particles: _particles),
          isComplex: true,
          willChange: true,
        ),
      ),
    );
  }

  // 优化：构建AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back_ios_new, 
                color: Colors.black54,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        '今日喵签详解',
        style: AppTheme.titleStyle.copyWith(
          fontSize: 18,
          color: Colors.black54,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: _showShareOptions,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.share_rounded, 
                  color: Colors.black54,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_fadeAnimation == null || _slideAnimation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // 使用RepaintBoundary包装整个内容以避免重绘影响其他组件
          RepaintBoundary(
            child: Stack(
              children: [
                // 背景粒子效果
                _buildBackgroundParticles(),
                
                // 主内容
                FadeTransition(
                  opacity: _fadeAnimation!,
                  child: SlideTransition(
                    position: _slideAnimation!,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderCard(),
                          // 运势预测
                          ...widget.report.predictions.asMap().entries.map(
                            (entry) => _buildPredictionCard(entry.value, entry.key)),

                          // 开运指南
                          _buildLuckyItemsSection(),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 分享卡片 - 隐藏状态，仅用于截图
          if (_isShareCardVisible)
            Positioned(
              left: -2000, // 放在屏幕外
              child: RepaintBoundary(
                key: _shareCardKey,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: FortuneShareCard(report: widget.report),
                ),
              ),
            ),
        ],
      ),
      // 添加浮动分享按钮
      floatingActionButton: ScaleTransition(
        scale: _fadeAnimation!,
        child: FloatingActionButton(
          onPressed: _showShareOptions,
          backgroundColor: const Color(0xFFFF97C1),
          child: const Icon(Icons.share, color: Colors.white),
          elevation: 4,
        ),
      ),
    );
  }
}

// 优化：粒子类，支持不同形状
class FortuneParticle {
  final Offset position;
  final Color color;
  final double size;
  final Offset velocity;
  final int shape; // 0=圆形, 1=方形, 2=星形
  
  const FortuneParticle({
    required this.position,
    required this.color,
    required this.size,
    required this.velocity,
    this.shape = 0,
  });
}

// 优化：粒子绘制器，支持多种形状
class ParticlesPainter extends CustomPainter {
  final List<FortuneParticle> particles;
  
  const ParticlesPainter({required this.particles});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    for (var particle in particles) {
      paint.color = particle.color;
      
      switch (particle.shape) {
        case 1: // 方形
          final rect = Rect.fromCenter(
            center: particle.position,
            width: particle.size,
            height: particle.size,
          );
          canvas.drawRect(rect, paint);
          break;
        case 2: // 星形
          _drawStar(canvas, particle.position, particle.size / 2, paint);
          break;
        case 0: // 圆形
        default:
          canvas.drawCircle(particle.position, particle.size / 2, paint);
          break;
      }
    }
  }
  
  // 绘制五角星
  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const int points = 5;
    final path = Path();
    final double halfRadius = radius / 2;
    
    // 计算五角星的顶点
    for (int i = 0; i < points * 2; i++) {
      final double r = (i % 2 == 0) ? radius : halfRadius;
      final double angle = (i * math.pi / points) - (math.pi / 2);
      
      final double x = center.dx + r * math.cos(angle);
      final double y = center.dy + r * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) {
    return true; // 每帧都需要重绘动态粒子
  }
}

