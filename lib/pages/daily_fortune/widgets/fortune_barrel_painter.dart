import 'package:flutter/material.dart';

class FortuneBarrelPainter extends CustomPainter {
  final Color color;

  FortuneBarrelPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
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
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, 15), 5, circlePaint);
  }

  @override
  bool shouldRepaint(FortuneBarrelPainter oldDelegate) => false;
}
