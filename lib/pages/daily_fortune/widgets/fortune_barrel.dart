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

class _FortuneBarrelState extends State<FortuneBarrel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -0.2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.2, end: 0.2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.2, end: 0.0)
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
      onTap: widget.onShake,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _shakeAnimation.value * pi / 8,
            child: child,
          );
        },
        child: Container(
          width: 120,
          height: 160,
          child: SvgPicture.string(
            '''
            <svg width="120" height="160" viewBox="0 0 120 160" fill="none" xmlns="http://www.w3.org/2000/svg">
              <!-- 桶身底部 -->
              <path d="M20 140 L100 140 L110 150 L10 150 Z" fill="#FFB6C1" stroke="#FF69B4" stroke-width="2"/>
              
              <!-- 桶身主体 -->
              <path d="M30 40 L90 40 L100 140 L20 140 Z" fill="#FFF0F5" stroke="#FFB6C1" stroke-width="2"/>
              
              <!-- 桶身装饰纹路 -->
              <path d="M35 60 L85 60" stroke="#FFB6C1" stroke-width="2" stroke-linecap="round"/>
              <path d="M33 80 L87 80" stroke="#FFB6C1" stroke-width="2" stroke-linecap="round"/>
              <path d="M31 100 L89 100" stroke="#FFB6C1" stroke-width="2" stroke-linecap="round"/>
              <path d="M29 120 L91 120" stroke="#FFB6C1" stroke-width="2" stroke-linecap="round"/>
              
              <!-- 桶口 -->
              <path d="M30 40 C30 30 90 30 90 40" stroke="#FFB6C1" stroke-width="2" fill="#FFF0F5"/>
              
              <!-- 签筒装饰 -->
              <circle cx="60" cy="70" r="10" fill="#FFB6C1" opacity="0.3"/>
              <path d="M55 65 L65 75 M65 65 L55 75" stroke="#FF69B4" stroke-width="2"/>
              
              <!-- 签子 -->
              <g transform="translate(${widget.isShaking ? '3' : '0'}, ${widget.isShaking ? '-2' : '0'})">
                <rect x="45" y="20" width="4" height="30" fill="#FF69B4" rx="2"/>
                <rect x="55" y="15" width="4" height="35" fill="#FF69B4" rx="2"/>
                <rect x="65" y="18" width="4" height="32" fill="#FF69B4" rx="2"/>
              </g>
            </svg>
            ''',
            width: 120,
            height: 160,
          ),
        ),
      ),
    );
  }
}
