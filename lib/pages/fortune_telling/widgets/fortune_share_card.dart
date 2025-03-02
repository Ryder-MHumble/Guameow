import 'package:flutter/material.dart';
import '../../../models/fortune_report.dart';
import '../../../modules/style/app_theme.dart';

class FortuneShareCard extends StatelessWidget {
  final FortuneReport report;
  
  const FortuneShareCard({
    super.key,
    required this.report,
  });

  String _calculateChineseZodiac(DateTime birthDate) {
    const List<String> zodiacSigns = [
      '鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'
    ];
    return zodiacSigns[(birthDate.year - 4) % 12];
  }

  String _getZodiacSign(DateTime birthDate) {
    const List<List<int>> zodiacDates = [
      [1, 20],  // 水瓶座
      [2, 19],  // 双鱼座
      [3, 21],  // 白羊座
      [4, 20],  // 金牛座
      [5, 21],  // 双子座
      [6, 22],  // 巨蟹座
      [7, 23],  // 狮子座
      [8, 23],  // 处女座
      [9, 23],  // 天秤座
      [10, 24], // 天蝎座
      [11, 23], // 射手座
      [12, 22], // 摩羯座
    ];

    const List<String> zodiacSigns = [
      '水瓶座', '双鱼座', '白羊座', '金牛座',
      '双子座', '巨蟹座', '狮子座', '处女座',
      '天秤座', '天蝎座', '射手座', '摩羯座',
    ];

    int month = birthDate.month;
    int day = birthDate.day;
    
    // 查找对应星座
    for (int i = 0; i < 12; i++) {
      if (month == i + 1 && day < zodiacDates[i][1]) {
        return zodiacSigns[i];
      } else if (month == i + 1 && day >= zodiacDates[i][1]) {
        return zodiacSigns[(i + 1) % 12];
      }
    }
    
    return zodiacSigns[0]; // 默认返回水瓶座
  }

  String _getFortuneLevelText(FortuneLevel level) {
    switch (level) {
      case FortuneLevel.excellent:
        return '大吉';
      case FortuneLevel.great:
        return '上吉';
      case FortuneLevel.good:
        return '中吉';
      case FortuneLevel.fair:
        return '小吉';
      case FortuneLevel.bad:
        return '凶';
    }
  }

  Color _getFortuneLevelColor(FortuneLevel level) {
    switch (level) {
      case FortuneLevel.excellent:
        return const Color(0xFFFF4D4F);
      case FortuneLevel.great:
        return const Color(0xFFFFA940);
      case FortuneLevel.good:
        return const Color(0xFF52C41A);
      case FortuneLevel.fair:
        return const Color(0xFF1890FF);
      case FortuneLevel.bad:
        return const Color(0xFF722ED1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final birthDateStr = '${report.birthDate.year}年${report.birthDate.month}月${report.birthDate.day}日';
    final chineseZodiac = _calculateChineseZodiac(report.birthDate);
    final zodiacSign = _getZodiacSign(report.birthDate);
    final levelText = _getFortuneLevelText(report.level);
    final levelColor = _getFortuneLevelColor(report.level);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/paper_texture.png'),
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题和LOGO
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/app_logo.png', 
                    width: 35, 
                    height: 35,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primary,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '个人命理详解',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '卦喵独家解析',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  levelText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: levelColor,
                  ),
                ),
              ),
            ],
          ),
          
          // 分隔线
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            height: 1,
            color: Colors.grey[200],
          ),

          // 基本信息
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow('生辰', birthDateStr),
                const SizedBox(height: 10),
                _buildInfoRow('血型', '${report.bloodType}型'),
                const SizedBox(height: 10),
                _buildInfoRow('生肖', chineseZodiac),
                const SizedBox(height: 10),
                _buildInfoRow('星座', zodiacSign),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // 运势总述
          Text(
            '运势总述',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.poem,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  report.poemInterpretation,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // 五大运势
          Text(
            '五大运势预测',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          
          ...report.predictions.map((prediction) => _buildPredictionCard(prediction)),
          
          const SizedBox(height: 20),

          // 开运建议
          Text(
            '开运建议',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...report.luckySuggestions.asMap().entries.map((entry) => _buildSuggestionItem(entry.key + 1, entry.value)),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // 幸运物品
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLuckyItem('幸运物品', report.luckyItems.join('、')),
              _buildLuckyItem('幸运颜色', report.luckyColors.join('、')),
            ],
          ),
          const SizedBox(height: 10),
          _buildLuckyItem('幸运数字', report.luckyNumbers.map((e) => e.toString()).join('、')),
          
          // 底部水印
          Container(
            margin: const EdgeInsets.only(top: 30),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  '卦喵',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '扫描二维码，解锁你的命理密码',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.qr_code_2,
                    size: 60,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionCard(FortunePrediction prediction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getPredictionTypeText(prediction.type),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              _buildScoreIndicator(prediction.score),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            prediction.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _getPredictionTypeText(FortuneType type) {
    switch (type) {
      case FortuneType.love:
        return '💖 情感运势';
      case FortuneType.career:
        return '💼 事业运势';
      case FortuneType.wealth:
        return '💰 财富运势';
      case FortuneType.health:
        return '🏥 健康运势';
      case FortuneType.study:
        return '📚 学业运势';
    }
  }

  Widget _buildScoreIndicator(int score) {
    Color color;
    if (score >= 90) {
      color = const Color(0xFFFF4D4F);
    } else if (score >= 80) {
      color = const Color(0xFFFFA940);
    } else if (score >= 70) {
      color = const Color(0xFF52C41A);
    } else if (score >= 60) {
      color = const Color(0xFF1890FF);
    } else {
      color = const Color(0xFF722ED1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$score',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '/100',
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(int index, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
} 