import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FortuneBarrel extends StatefulWidget {
  final VoidCallback? onShake;
  final bool isShaking;

  const FortuneBarrel({
    Key? key,
    this.onShake,
    required this.isShaking,
  }) : super(key: key);

  @override
  State<FortuneBarrel> createState() => _FortuneBarrelState();
}

class _FortuneBarrelState extends State<FortuneBarrel> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shakeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -0.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.15, end: 0.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.15, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25.0,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        if (widget.isShaking) {
          _controller.forward();
        }
      }
    });
  }

  @override
  void didUpdateWidget(FortuneBarrel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      _controller.forward();
    } else if (!widget.isShaking && oldWidget.isShaking) {
      _controller.stop();
      _controller.reset();
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
              angle: _shakeAnimation.value * pi / 8,
              child: child,
            ),
          );
        },
        child: SizedBox(
          width: 180,
          height: 220,
          child: Stack(
            children: [
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
                  
                  <!-- 签子 -->
                  <g transform="translate(${widget.isShaking ? '7' : '0'}, ${widget.isShaking ? '-4' : '0'})">
                    <rect x="60" y="25" width="5" height="45" fill="#FF69B4" rx="2.5"/>
                    <rect x="75" y="20" width="5" height="50" fill="#FF69B4" rx="2.5"/>
                    <rect x="90" y="23" width="5" height="47" fill="#FF69B4" rx="2.5"/>
                    <rect x="105" y="27" width="5" height="43" fill="#FF69B4" rx="2.5"/>
                  </g>
                </svg>
                ''',
                width: 180,
                height: 220,
                fit: BoxFit.contain,
              ),
              
              // 点击涟漪效果
              if (_isPressed)
                Positioned.fill(
                  child: CustomPaint(
                    painter: RipplePainter(
                      color: Colors.pink.withOpacity(0.1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final Color color;

  RipplePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
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
