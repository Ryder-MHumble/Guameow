import 'package:flutter/material.dart';
import '../../../modules/style/app_theme.dart';
import '../../../models/fortune_report.dart';

class HexagramCard extends StatelessWidget {
  final String hexagramName;
  final String hexagramSymbol;
  final String hexagramDescription;
  final FortuneLevel fortuneLevel;
  final VoidCallback onTap;

  const HexagramCard({
    super.key,
    required this.hexagramName,
    required this.hexagramSymbol,
    required this.hexagramDescription,
    required this.fortuneLevel,
    required this.onTap,
  });

  Color _getLevelColor() {
    switch (fortuneLevel) {
      case FortuneLevel.excellent:
        return const Color(0xFFFF69B4); // 粉红色
      case FortuneLevel.great:
        return const Color(0xFFFF8C00); // 橙色
      case FortuneLevel.good:
        return const Color(0xFF4169E1); // 蓝色
      case FortuneLevel.fair:
        return const Color(0xFF32CD32); // 绿色
      case FortuneLevel.bad:
        return const Color(0xFF800080); // 紫色
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          boxShadow: [
            BoxShadow(
              color: levelColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题部分
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [levelColor, levelColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.mediumRadius),
                  topRight: Radius.circular(AppTheme.mediumRadius),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    hexagramSymbol,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    hexagramName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    hexagramSymbol,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // 卦象图形
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHexagramSymbol(hexagramSymbol, levelColor),
                ],
              ),
            ),
            
            // 卦象解释
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: levelColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  hexagramDescription,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black.withOpacity(0.85),
                  ),
                ),
              ),
            ),
            
            // 运势等级
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: levelColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 18,
                          color: levelColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          fortuneLevel.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: levelColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 点击查看详情提示
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '点击查看详细解卦',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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
  
  Widget _buildHexagramSymbol(String symbol, Color color) {
    // 这里简化处理，实际应用中可以根据卦象符号绘制更精确的图形
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: 60,
            color: color,
          ),
        ),
      ),
    );
  }
} 