import 'package:flutter/material.dart';
import '../../models/fortune_report.dart';
import '../../modules/style/app_theme.dart';

class FortuneReportPage extends StatefulWidget {
  final FortuneReport report;

  const FortuneReportPage({Key? key, required this.report}) : super(key: key);

  @override
  State<FortuneReportPage> createState() => _FortuneReportPageState();
}

class _FortuneReportPageState extends State<FortuneReportPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTheme.titleStyle.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(FortunePrediction prediction) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  prediction.type.label,
                  style: AppTheme.titleStyle.copyWith(fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppTheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${prediction.score}分',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.primary,
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
                  style: AppTheme.bodyStyle,
                ),
                const SizedBox(height: 12),
                if (prediction.suggestions.isNotEmpty) ...[
                  Text(
                    '喵咪建议：',
                    style: AppTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...prediction.suggestions.map((suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppTheme.primary)),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: AppTheme.bodyStyle,
                          ),
                        ),
                      ],
                    ),
                  )),
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '今日运势详解',
          style: AppTheme.titleStyle.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 运势等级和日期
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: AppTheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.report.level.label,
                            style: AppTheme.titleStyle.copyWith(
                              fontSize: 28,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.report.poem,
                        style: AppTheme.titleStyle.copyWith(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.report.poemInterpretation,
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // 运势预测
                _buildSectionTitle('运势预测', Icons.visibility),
                ...widget.report.predictions.map(_buildPredictionCard),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
