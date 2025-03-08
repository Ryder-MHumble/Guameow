import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/fortune_report.dart';
import '../../modules/style/app_theme.dart';
import '../../data/fortune_static_data.dart';

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
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeOutCubic),
    );

    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Color _getLevelColor(FortuneLevel level) {
    return FortuneStaticData.getLevelColor(level);
  }

  Color _getTypeColor(FortuneType type) {
    return FortuneStaticData.getTypeColor(type);
  }

  String _getFortuneTypeIcon(FortuneType type) {
    return FortuneStaticData.getFortuneTypeIcon(type);
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF97C1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFFF97C1), size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTheme.titleStyle.copyWith(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyItemsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF97C1).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: const Color(0xFFFF97C1),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('开运指南', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          // 吉利物品
          if (widget.report.luckyItems.isNotEmpty) ...[
            _buildLuckySubSection(
              '吉利物品',
              Icons.card_giftcard,
              widget.report.luckyItems.join('、'),
            ),
            const SizedBox(height: 12),
          ],
          // 吉利颜色
          if (widget.report.luckyColors.isNotEmpty) ...[
            _buildLuckySubSection(
              '吉利颜色',
              Icons.palette,
              widget.report.luckyColors.join('、'),
            ),
            const SizedBox(height: 12),
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
    );
  }

  Widget _buildLuckySubSection(String title, IconData icon, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF97C1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFFF97C1), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(content, style: AppTheme.bodyStyle),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    final levelColor = _getLevelColor(widget.report.level);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: levelColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: levelColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.report.level.label,
                  style: TextStyle(
                    color: levelColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.star, color: levelColor, size: 20),
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
              ),
            ),
          ),
          if (widget.report.poemInterpretation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 20,
                top: 8,
              ),
              child: Text(
                widget.report.poemInterpretation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black54,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(FortunePrediction prediction) {
    final typeColor = _getTypeColor(prediction.type);
    final levelColor = _getLevelColor(widget.report.level);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: typeColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      _getFortuneTypeIcon(prediction.type),
                      width: 24,
                      height: 24,
                      color: typeColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      prediction.type.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: levelColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: levelColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${prediction.score}分',
                        style: TextStyle(
                          color: levelColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction.description,
                  style: AppTheme.bodyStyle.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                if (prediction.suggestions.isNotEmpty) ...[
                  Text(
                    '卦喵建议：',
                    style: AppTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...prediction.suggestions.map(
                    (suggestion) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: typeColor)),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: AppTheme.bodyStyle.copyWith(
                                color: Colors.black54,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_fadeAnimation == null || _slideAnimation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '今日喵签详解',
          style: AppTheme.titleStyle.copyWith(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
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
                // _buildSectionTitle('运势预测', Icons.visibility),
                ...widget.report.predictions.map(_buildPredictionCard),

                // 开运指南
                // _buildSectionTitle('开运指南', Icons.auto_awesome),
                _buildLuckyItemsSection(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
