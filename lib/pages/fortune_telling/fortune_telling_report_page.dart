import 'package:flutter/material.dart';
import '../../models/fortune_report.dart';
import '../../modules/style/app_theme.dart';
import '../../services/share_service.dart';
import 'widgets/fortune_share_card.dart';

class FortuneTellingReportPage extends StatefulWidget {
  final FortuneReport report;

  const FortuneTellingReportPage({super.key, required this.report});

  @override
  State<FortuneTellingReportPage> createState() => _FortuneTellingReportPageState();
}

class _FortuneTellingReportPageState extends State<FortuneTellingReportPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();
  
  // 添加用于截图的Global Key
  final GlobalKey _shareCardKey = GlobalKey();
  bool _isShareCardVisible = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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
          shareText: '我在『卦喵』获得了个人命理详解，推荐你也来试试！',
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

  String _calculateChineseZodiac(DateTime birthDate) {
    const List<String> zodiacSigns = [
      '鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'
    ];
    return zodiacSigns[(birthDate.year - 4) % 12];
  }

  String _calculateHeavenlyStem(DateTime birthDate) {
    const List<String> stems = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    return stems[(birthDate.year - 4) % 10];
  }

  String _calculateEarthlyBranch(DateTime birthDate) {
    const List<String> branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    return branches[(birthDate.year - 4) % 12];
  }

  String _getStemElement(String stem) {
    const Map<String, String> stemElements = {
      '甲': '木', '乙': '木',
      '丙': '火', '丁': '火',
      '戊': '土', '己': '土',
      '庚': '金', '辛': '金',
      '壬': '水', '癸': '水',
    };
    return stemElements[stem] ?? '木';
  }

  String _getBranchElement(String branch) {
    const Map<String, String> branchElements = {
      '子': '水', '丑': '土',
      '寅': '木', '卯': '木',
      '辰': '土', '巳': '火',
      '午': '火', '未': '土',
      '申': '金', '酉': '金',
      '戌': '土', '亥': '水',
    };
    return branchElements[branch] ?? '木';
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

  String _getChineseMonth(DateTime birthDate) {
    const List<String> months = [
      '正月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '冬月', '腊月',
    ];
    // 简单近似，实际需农历转换算法
    int lunarMonth = (birthDate.month + 10) % 12;
    return months[lunarMonth];
  }

  String _getChineseDay(DateTime birthDate) {
    // 简单示例，实际应该使用农历转换
    final day = birthDate.day;
    if (day <= 10) return '初${_numberToChinese(day)}';
    if (day <= 19) return '十${_numberToChinese(day - 10)}';
    if (day <= 29) return '廿${_numberToChinese(day - 20)}';
    return '三十';
  }

  String _numberToChinese(int number) {
    const List<String> chineseNumbers = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
    if (number >= 1 && number <= 10) {
      return chineseNumbers[number - 1];
    }
    return '';
  }

  String _getChineseHour(DateTime birthDate) {
    const List<String> hours = [
      '子时', '丑时', '寅时', '卯时', '辰时', '巳时',
      '午时', '未时', '申时', '酉时', '戌时', '亥时',
    ];
    final hourIndex = (birthDate.hour + 1) ~/ 2 % 12;
    return hours[hourIndex];
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    final birthDateStr = '${widget.report.birthDate.year}年${widget.report.birthDate.month}月${widget.report.birthDate.day}日';
    final chineseZodiac = _calculateChineseZodiac(widget.report.birthDate);
    final heavenlyStem = _calculateHeavenlyStem(widget.report.birthDate);
    final earthlyBranch = _calculateEarthlyBranch(widget.report.birthDate);
    final stemElement = _getStemElement(heavenlyStem);
    final branchElement = _getBranchElement(earthlyBranch);
    final zodiacSign = _getZodiacSign(widget.report.birthDate);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
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
                '生辰：$birthDateStr',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                '血型：${widget.report.bloodType}型',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '生肖：$chineseZodiac',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                '星座：$zodiacSign',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '天干：$heavenlyStem（$stemElement）',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                '地支：$earthlyBranch（$branchElement）',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEightCharacters() {
    final stem = _calculateHeavenlyStem(widget.report.birthDate);
    final branch = _calculateEarthlyBranch(widget.report.birthDate);
    final chineseMonth = _getChineseMonth(widget.report.birthDate);
    final chineseDay = _getChineseDay(widget.report.birthDate);
    final chineseHour = _getChineseHour(widget.report.birthDate);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '八字排盘',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '你的出生时间为公历${widget.report.birthDate.year}年${widget.report.birthDate.month}月${widget.report.birthDate.day}日'
            '（农历${stem}${branch}年$chineseMonth$chineseDay，$chineseHour），八字为：',
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.2),
              ),
            ),
            child: const Text(
              '年柱：辛巳（金火）｜月柱：庚寅（金木）｜日柱：乙卯（木木）｜时柱：丁丑（火土）',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '日主乙木生于寅月（立春后），得令而旺；地支寅卯半会木局，时支丑土藏癸水滋养，木气强盛。整体命局偏向"木火通明"，但金土稍弱，需调和。',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsedGod() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '用神与五行喜忌',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildGodItem('喜用神', 
            '木旺需金制、火泄，同时需土培根。金（官杀）可制木，火（食伤）可泄秀生财，土（财星）为养命之源。'
          ),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          _buildGodItem('忌神', 
            '水（印星）会助木过旺，反成负担。'
          ),
        ],
      ),
    );
  }

  Widget _buildGodItem(String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.star,
            color: AppTheme.primary,
            size: 14,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDestinyAnalysis() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '正缘分析',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '妻星为戊土（正财），藏于时支丑土中，暗示正缘出现较晚（25岁后），对方可能属牛、蛇或鸡，性格务实、家庭观念强。',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '2024甲辰年，辰土为财库，且流年与日支卯辰相害，感情易有波动，但也是婚恋机会年；2026丙午年，火旺生土，婚缘信号强烈。',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearFortune() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '流年运势（2023-2024）',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildYearItem(
            '2023癸卯年',
            '• 癸水偏印透干，思想压力大，但卯木为日主禄神，学业/事业有贵人暗中相助。\n'
            '• 注意：水木过旺易导致情绪敏感，需多运动疏解。',
          ),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          _buildYearItem(
            '2024甲辰年',
            '• 甲木劫财透干，竞争加剧，需防破财；辰土为财库，若把握实习转正机会，收入可提升。\n'
            '• 关键月份：农历三月（辰月）、八月（酉月），易有贵人提携。',
          ),
        ],
      ),
    );
  }

  Widget _buildYearItem(String year, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            year,
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancePosition() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '财位与贵人',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildFinanceItem(
            '财位方向',
            '• 西北（乾卦）：金位助财，可放置金属貔貅或白色水晶。\n'
            '• 西南（坤卦）：土位养财，适合摆放黄玉或陶瓷聚宝盆。',
          ),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          _buildFinanceItem(
            '贵人特征',
            '• 生肖：猴（申）、鼠（子），能引动天乙贵人（申子）。\n'
            '• 星座：双子座、天秤座（风象星座助你开拓人脉）。',
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthFortune() {
    // 寻找健康运势相关的预测
    final healthPrediction = widget.report.predictions.firstWhere(
      (p) => p.type == FortuneType.health,
      orElse: () => const FortunePrediction(
        type: FortuneType.health,
        description: '健康状况良好，但需注意饮食和运动。',
        score: 70,
        suggestions: ['保持规律作息', '注意饮食均衡', '坚持适度运动'],
      ),
    );
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
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
                '健康运势',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getScoreColor(healthPrediction.score).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${healthPrediction.score}分',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(healthPrediction.score),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            healthPrediction.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '健康建议：',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...healthPrediction.suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStudyFortune() {
    // 寻找学业运势相关的预测
    final studyPrediction = widget.report.predictions.firstWhere(
      (p) => p.type == FortuneType.study,
      orElse: () => const FortunePrediction(
        type: FortuneType.study,
        description: '学业进展顺利，但需注意时间管理和学习方法。',
        score: 75,
        suggestions: ['制定合理学习计划', '尝试新的学习方法', '保持学习热情'],
      ),
    );
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
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
                '学业运势',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getScoreColor(studyPrediction.score).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${studyPrediction.score}分',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(studyPrediction.score),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            studyPrediction.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '学业建议：',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...studyPrediction.suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFFFF4D4F);
    if (score >= 80) return const Color(0xFFFFA940);
    if (score >= 70) return const Color(0xFF52C41A);
    if (score >= 60) return const Color(0xFF1890FF);
    return const Color(0xFF722ED1);
  }

  Widget _buildCrossSys() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '跨体系综合解读',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildCrossItem(
            '星座（双鱼座）',
            '2023年海王星顺行，灵感充沛，适合研究或创作；但需避免过度理想化人际关系。',
          ),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          _buildCrossItem(
            '塔罗牌象征',
            '现状：抽到"隐者（逆位）"，提示需走出自我封闭，主动社交拓展机会。\n'
            '建议："权杖八（正位）"，快速行动可突破瓶颈。',
          ),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          _buildCrossItem(
            '推背图卦象',
            '第37象"火运开时祸蔓延"，对应你命局火旺，需注意2026年前后火土流年，避免冲动决策。',
          ),
        ],
      ),
    );
  }

  Widget _buildCrossItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildLuckyAdvice() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '开运建议',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '1. 佩戴金属饰品（银链、金曜石），补金制木。',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '2. 办公桌布局：西北方放铜制文昌塔，提升学业事业运。',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '3. 感情主动期：2024年秋季多参与学术交流，易遇正缘。',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.3),
              ),
            ),
            child: const Text(
              '总结：你命局潜力深厚，近两年需稳扎稳打，2024年后逐步迎来事业感情双丰收。贵人助力多在西北方向，谨记"守正待时"。',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLuckyItems(),
        ],
      ),
    );
  }

  Widget _buildLuckyItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '开运物品',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...widget.report.luckyItems.map((item) => _buildLuckyTag(item)),
            ...widget.report.luckyColors.map((color) => _buildLuckyTag(color, isColor: true)),
            ...widget.report.luckyNumbers.map((number) => _buildLuckyTag(number.toString(), isNumber: true)),
          ],
        ),
      ],
    );
  }

  Widget _buildLuckyTag(String text, {bool isColor = false, bool isNumber = false}) {
    IconData? icon;
    if (isColor) {
      icon = Icons.palette;
    } else if (isNumber) {
      icon = Icons.tag;
    } else {
      icon = Icons.card_giftcard;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.primary,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          '命理详解',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          // 添加分享按钮
          IconButton(
            icon: Icon(Icons.share_rounded, color: AppTheme.primary),
            onPressed: _showShareOptions,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 主内容
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('基本信息'),
                    _buildBasicInfo(),
                    _buildSectionTitle('八字命理分析'),
                    _buildEightCharacters(),
                    _buildUsedGod(),
                    _buildDestinyAnalysis(),
                    _buildSectionTitle('流年运势'),
                    _buildYearFortune(),
                    _buildFinancePosition(),
                    
                    // 添加健康运势
                    _buildHealthFortune(),
                    
                    // 添加学业运势
                    _buildStudyFortune(),
                    
                    _buildSectionTitle('综合解读'),
                    _buildCrossSys(),
                    _buildSectionTitle('开运指南'),
                    _buildLuckyAdvice(),
                    // 添加分享按钮
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: const Text(
                            '分享到社交媒体',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _showShareOptions,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 隐藏的分享卡片，用于生成截图
          Offstage(
            offstage: !_isShareCardVisible,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RepaintBoundary(
                  key: _shareCardKey,
                  child: FortuneShareCard(report: widget.report),
                ),
              ),
            ),
          ),
          
          // 显示加载中指示器
          if (_isShareCardVisible)
            const Offstage(
              offstage: false,
              child: Center(
                child: SizedBox(
                  width: 0, // 宽度为0使其不可见，但仍在布局中
                  height: 0,
                ),
              ),
            ),
        ],
      ),
      // 添加底部浮动分享按钮
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: _showShareOptions,
        child: const Icon(Icons.share_outlined, color: Colors.white),
      ),
    );
  }
} 