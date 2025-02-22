import 'package:flutter/material.dart';
import '../style/app_theme.dart';

class CatNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CatNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CatNavigationBar> createState() => _CatNavigationBarState();
}

class _CatNavigationBarState extends State<CatNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const Color _activeColor = AppTheme.primary;
  static const Color _inactiveColor = Color(0xFFD8D8D8);

  final List<Map<String, dynamic>> _items = [
    {
      'label': '每日喵签',
      'icon': Icons.pets,
    },
    {
      'label': '喵咪占卜',
      'icon': Icons.auto_awesome,
    },
    {
      'label': '喵仙人',
      'icon': Icons.catching_pokemon, // 更可爱的猫头图标
    },
    {
      'label': '喵签报告',
      'icon': Icons.history,
    },
    {
      'label': '占卜报告',
      'icon': Icons.assessment,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildNavItem(Map<String, dynamic> item, int index, {bool isCenter = false}) {
    final isActive = widget.currentIndex == index;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: isCenter ? 0 : 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: isActive ? _activeColor : _inactiveColor,
                  size: isCenter ? 32 : 24,
                ),
                if (!isCenter) ...[
                  const SizedBox(height: 4),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive ? _activeColor : _inactiveColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final isActive = widget.currentIndex == 2;
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap(2);
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - _controller.value * 0.1,
            child: Container(
              width: 60,
              height: 60,
              child: CustomPaint(
                painter: CatPawPainter(
                  color: isActive ? Colors.white : _activeColor,
                  shadowColor: _activeColor.withOpacity(0.3),
                  backgroundColor: isActive ? _activeColor : Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BottomAppBar(
          height: 80,
          padding: EdgeInsets.zero,
          notchMargin: 8,
          elevation: 8,
          shadowColor: Colors.pink.withOpacity(0.2),
          shape: const CircularNotchedRectangle(),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(_items[0], 0),
              _buildNavItem(_items[1], 1),
              const SizedBox(width: 56), // 中间按钮的空间
              _buildNavItem(_items[3], 3),
              _buildNavItem(_items[4], 4),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFloatingActionButton(),
            ],
          ),
        ),
      ],
    );
  }
}

class CatPawPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final Color backgroundColor;

  CatPawPainter({
    required this.color,
    required this.shadowColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Add shadow
    canvas.drawShadow(
      Path()
        ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2,
        )),
      shadowColor,
      4,
      true,
    );

    // Draw main circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    paint.color = color;

    // Draw paw pads
    final centerPadRadius = size.width * 0.2;
    final smallPadRadius = size.width * 0.15;
    final distance = size.width * 0.25;

    // Center pad
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2 + distance * 0.3),
      centerPadRadius,
      paint,
    );

    // Top pad
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2 - distance),
      smallPadRadius,
      paint,
    );

    // Left pad
    canvas.drawCircle(
      Offset(size.width / 2 - distance, size.height / 2),
      smallPadRadius,
      paint,
    );

    // Right pad
    canvas.drawCircle(
      Offset(size.width / 2 + distance, size.height / 2),
      smallPadRadius,
      paint,
    );
  }

  @override
  bool shouldRepaint(CatPawPainter oldDelegate) {
    return color != oldDelegate.color ||
        shadowColor != oldDelegate.shadowColor ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
