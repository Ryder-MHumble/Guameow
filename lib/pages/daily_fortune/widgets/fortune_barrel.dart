import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FortuneBarrel extends StatefulWidget {
  final VoidCallback? onShake;
  final bool isShaking;

  const FortuneBarrel({super.key, this.onShake, required this.isShaking});

  @override
  State<FortuneBarrel> createState() => _FortuneBarrelState();
}

class _FortuneBarrelState extends State<FortuneBarrel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shakeAnimation;
  bool _isPressed = false;
  
  // 新增: 签子摇晃效果
  List<SignAnimation> _signsAnimations = [];
  final math.Random _random = math.Random();
  
  // 新增: 光效控制
  double _glowOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // 更快的摇晃节奏
      vsync: this,
    );

    // 增强摇晃动画
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -0.2,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25.0,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -0.2,
          end: 0.2,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.2,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25.0,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        if (widget.isShaking) {
          _controller.forward();
          // 新增: 更新签子动画和光效
          _updateSignsAnimations();
          _updateGlowEffect();
        }
      }
    });
    
    // 初始化签子动画
    _initSignsAnimations();
  }
  
  // 新增: 初始化签子动画
  void _initSignsAnimations() {
    _signsAnimations = List.generate(4, (index) => SignAnimation(
      initialOffset: Offset(0, 0),
      currentOffset: Offset(0, 0),
      speed: 0,
    ));
  }
  
  // 新增: 更新签子动画
  void _updateSignsAnimations() {
    if (!widget.isShaking) return;
    
    setState(() {
      for (var i = 0; i < _signsAnimations.length; i++) {
        // 随机生成水平和垂直方向的偏移量
        final dx = (_random.nextDouble() * 6) - 3;
        final dy = -(_random.nextDouble() * 6) - 2; // 主要向上运动
        
        _signsAnimations[i] = SignAnimation(
          initialOffset: Offset(dx, dy),
          currentOffset: Offset(dx, dy),
          speed: 0.5 + _random.nextDouble() * 0.5,
        );
      }
    });
  }
  
  // 新增: 更新光效
  void _updateGlowEffect() {
    if (!widget.isShaking) return;
    
    setState(() {
      _glowOpacity = 0.2 + _random.nextDouble() * 0.3;
    });
  }

  @override
  void didUpdateWidget(FortuneBarrel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      _controller.forward();
      // 新增: 重置签子动画和光效
      _initSignsAnimations();
      _glowOpacity = 0.1;
    } else if (!widget.isShaking && oldWidget.isShaking) {
      _controller.stop();
      _controller.reset();
      // 新增: 重置光效
      _glowOpacity = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onShake,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.95 : 1.0,
            child: Transform.rotate(
              angle: _shakeAnimation.value * math.pi / 6, // 增加摇晃幅度
              child: child,
            ),
          );
        },
        child: SizedBox(
          width: 180,
          height: 220,
          child: Stack(
            children: [
              // 新增: 光晕效果
              if (widget.isShaking)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: _glowOpacity,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF69B4).withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // 签筒主体
              SvgPicture.string(
                '''
                <svg width="180" height="220" viewBox="0 0 180 220" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <!-- 桶身底部 -->
                  <path d="M35 195 L145 195 L155 205 L25 205 Z" fill="#FFB6C1" stroke="#FF69B4" stroke-width="2"/>
                  
                  <!-- 桶身主体 -->
                  <path d="M45 50 L135 50 L145 195 L35 195 Z" fill="#FFF0F5" stroke="#FFB6C1" stroke-width="2"/>
                  
                  <!-- 桶身装饰纹路 -->
                  <path d="M50 70 L130 70" stroke="#FFB6C1" stroke-width="2" stroke-linecap="round"/>
                  <path d="M48 90 L132 90" stroke="#FFB6C1" stroke-width="2" stroke-linecap="round"/>
                  <path d="M46 110 L134 110" stroke="#FFB6C1" stroke-width="2" stroke-linecap="round"/>
                  <path d="M44 130 L136 130" stroke="#FFB6C1" stroke-width="2" stroke-linecap="round"/>
                  <path d="M42 150 L138 150" stroke="#FFB6C1" stroke-width="2" stroke-linecap="round"/>
                  <path d="M40 170 L140 170" stroke="#FFB6C1" stroke-width="2" stroke-linecap="round"/>
                  
                  <!-- 桶口 -->
                  <path d="M45 50 C45 40 135 40 135 50" stroke="#FFB6C1" stroke-width="2" fill="#FFF0F5"/>
                  
                  <!-- 樱花装饰 - 左侧 -->
                  <circle cx="55" cy="100" r="8" fill="#FFB6C1" opacity="0.6"/>
                  <circle cx="52" cy="97" r="8" fill="#FFB6C1" opacity="0.4"/>
                  <circle cx="58" cy="97" r="8" fill="#FFB6C1" opacity="0.4"/>
                  
                  <!-- 樱花装饰 - 右侧 -->
                  <circle cx="125" cy="140" r="8" fill="#FFB6C1" opacity="0.6"/>
                  <circle cx="122" cy="137" r="8" fill="#FFB6C1" opacity="0.4"/>
                  <circle cx="128" cy="137" r="8" fill="#FFB6C1" opacity="0.4"/>
                  
                  <!-- 猫咪装饰 -->
                  <circle cx="90" cy="120" r="20" fill="#FFB6C1" opacity="0.3"/>
                  <path d="M83 113 Q90 108 97 113" stroke="#FF69B4" stroke-width="2.5"/>
                  <circle cx="83" cy="111" r="2.5" fill="#FF69B4"/>
                  <circle cx="97" cy="111" r="2.5" fill="#FF69B4"/>
                  <path d="M87 118 Q90 120 93 118" stroke="#FF69B4" stroke-width="2.5"/>
                  <!-- 猫耳朵 -->
                  <path d="M75 105 L83 111" stroke="#FF69B4" stroke-width="2"/>
                  <path d="M105 105 L97 111" stroke="#FF69B4" stroke-width="2"/>
                </svg>
                ''',
                width: 180,
                height: 220,
                fit: BoxFit.contain,
              ),
              
              // 新增: 动态签子，使用代码渲染而不是SVG
              ...List.generate(4, (index) {
                // 签子基本位置
                double baseX = 60 + (index * 15);
                double baseY = 25 + (index % 2 == 0 ? 5 : 0);
                double height = 45 - (index == 1 ? -5 : (index == 3 ? 2 : 0));
                
                // 计算当前偏移
                double offsetX = widget.isShaking ? _signsAnimations[index].currentOffset.dx : 0;
                double offsetY = widget.isShaking ? _signsAnimations[index].currentOffset.dy : 0;
                
                return Positioned(
                  left: baseX + offsetX,
                  top: baseY + offsetY,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 5,
                    height: height,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF69B4),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                );
              }),

              // 点击涟漪效果
              if (_isPressed)
                Positioned.fill(
                  child: CustomPaint(
                    painter: RipplePainter(color: Colors.pink.withOpacity(0.1)),
                  ),
                ),
                
              // 新增: 摇晃中的粒子效果
              if (widget.isShaking)
                Positioned.fill(
                  child: CustomPaint(
                    painter: ShakeParticlesPainter(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 新增: 签子动画数据类
class SignAnimation {
  final Offset initialOffset;
  final Offset currentOffset;
  final double speed;
  
  SignAnimation({
    required this.initialOffset,
    required this.currentOffset,
    required this.speed,
  });
}

// 新增: 摇晃粒子绘制器
class ShakeParticlesPainter extends CustomPainter {
  final List<ShakeParticle> particles = List.generate(
    15,
    (index) => ShakeParticle(
      position: Offset(
        60.0 + (math.Random().nextDouble() * 60),
        50.0 + (math.Random().nextDouble() * 80),
      ),
      radius: 1.0 + math.Random().nextDouble() * 2,
      color: Color(0xFFFF69B4).withOpacity(0.1 + math.Random().nextDouble() * 0.3),
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        particle.position,
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 新增: 摇晃粒子数据类
class ShakeParticle {
  final Offset position;
  final double radius;
  final Color color;
  
  ShakeParticle({
    required this.position,
    required this.radius,
    required this.color,
  });
}

class RipplePainter extends CustomPainter {
  final Color color;

  RipplePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
