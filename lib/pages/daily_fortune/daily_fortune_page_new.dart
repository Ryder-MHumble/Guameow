import 'package:flutter/material.dart';
import '../../modules/style/app_theme.dart';
import '../../models/fortune_report.dart';
import '../../data/mock_fortune_data.dart';
import '../fortune_telling/fortune_report_page.dart';

class DailyFortunePageNew extends StatelessWidget {
  const DailyFortunePageNew({super.key});

  Widget _buildFortuneCard(BuildContext context, FortuneReport report) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FortuneReportPage(report: report),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          boxShadow: [AppTheme.softShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.mediumRadius),
                  topRight: Radius.circular(AppTheme.mediumRadius),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '今日喵签',
                    style: AppTheme.titleStyle.copyWith(
                      fontSize: 24,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.level.label,
                    style: AppTheme.titleStyle.copyWith(
                      fontSize: 32,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.poem,
                    style: AppTheme.titleStyle.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(report.poemInterpretation, style: AppTheme.bodyStyle),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    '今日喵签',
                    style: AppTheme.titleStyle.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ...report.predictions.map(
                    (prediction) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              prediction.type.label,
                              style: AppTheme.bodyStyle,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${prediction.score}分',
                              style: AppTheme.bodyStyle.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      '点击查看详细报告 →',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildFortuneCard(context, mockFortuneReport),
            ],
          ),
        ),
      ),
    );
  }
}
