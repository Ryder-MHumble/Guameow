import 'package:flutter/material.dart';
import '../../modules/style/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'widgets/custom_date_picker.dart';
import '../../models/fortune_report.dart';
import 'fortune_report_page.dart';

class FortuneTellingPage extends StatefulWidget {
  const FortuneTellingPage({super.key});

  @override
  State<FortuneTellingPage> createState() => _FortuneTellingPageState();
}

class _FortuneTellingPageState extends State<FortuneTellingPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  DateTime? _birthDate;
  String? _bloodType;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final PageController _bloodTypeController = PageController(
    viewportFraction: 0.3,
    initialPage: 0,
  );
  bool _isDatePickerVisible = false;

  final List<String> _bloodTypes = ['A', 'B', 'O', 'AB'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  void _toggleDatePicker() {
    setState(() {
      _isDatePickerVisible = !_isDatePickerVisible;
    });
  }

  void _onDateSelected(DateTime date) {
    if (_birthDate != date) {
      setState(() {
        _birthDate = date;
        _isDatePickerVisible = false;
      });
    } else {
      setState(() {
        _isDatePickerVisible = false;
      });
    }
    _animationController.reset();
    _animationController.forward();
  }

  void _selectBloodType(String type) {
    if (_bloodType != type) {
      setState(() {
        _bloodType = type;
      });
      final index = _bloodTypes.indexOf(type);
      _bloodTypeController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _birthDate != null &&
        _bloodType != null) {
      // TODO: 这里应该调用实际的API获取报告
      // 这里使用模拟数据演示
      final report = FortuneReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        birthDate: _birthDate!,
        bloodType: _bloodType!,
        level: FortuneLevel.excellent,
        poem: '春风得意马蹄疾，一日看尽长安花。',
        poemInterpretation: '这首诗暗示着你将迎来一个充满机遇和喜悦的时期，事业和生活都会有新的突破。',
        predictions: [
          FortunePrediction(
            type: FortuneType.career,
            description: '职场上将遇到贵人相助，有望获得晋升或加薪的机会。',
            score: 90,
            suggestions: ['主动承担重要项目，展现自己的能力', '与同事保持良好的沟通和合作关系', '注意职业发展方向的规划'],
          ),
          FortunePrediction(
            type: FortuneType.love,
            description: '感情运势稳定，单身者可能遇到心仪的对象。',
            score: 85,
            suggestions: ['多参加社交活动，扩大交友圈', '保持开放和真诚的态度', '适时表达自己的感受'],
          ),
        ],
        luckySuggestions: ['早起晨练，增强体质', '多与朋友聚会，增进感情', '学习新技能，提升自我'],
        luckyItems: ['红色钱包', '猫咪挂饰', '幸运手链'],
        luckyColors: ['红色', '粉色', '金色'],
        luckyNumbers: [3, 6, 8],
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FortuneReportPage(report: report),
        ),
      );
    }
  }

  Widget _buildSelectionCard({
    required String title,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.titleStyle.copyWith(fontSize: 18)),
        const SizedBox(height: 16),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.smallRadius),
              boxShadow: [AppTheme.softShadow],
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTypeSelector() {
    return SizedBox(
      height: 60,
      child: PageView.builder(
        controller: _bloodTypeController,
        itemCount: _bloodTypes.length,
        onPageChanged: (index) {
          final type = _bloodTypes[index];
          if (_bloodType != type) {
            setState(() {
              _bloodType = type;
            });
          }
        },
        itemBuilder: (context, index) {
          final type = _bloodTypes[index];
          final isSelected = type == _bloodType;
          return GestureDetector(
            onTap: () => _selectBloodType(type),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Text(
                  type,
                  style: AppTheme.bodyStyle.copyWith(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        // SvgPicture.asset(
                        //   'assets/svg/nav_icons/粉-星座占卜.svg',
                        //   height: 64,
                        //   width: 64,
                        // ),
                        const SizedBox(height: 16),
                        Text(
                          '喵咪占卜',
                          style: AppTheme.titleStyle.copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '让喵星人为你解读命运的密码',
                          style: AppTheme.bodyStyle.copyWith(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildSelectionCard(
                    title: '选择生辰',
                    onTap: _toggleDatePicker,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _birthDate == null
                              ? '请选择日期'
                              : '${_birthDate!.year}年${_birthDate!.month}月${_birthDate!.day}日',
                          style: AppTheme.bodyStyle.copyWith(
                            color:
                                _birthDate == null
                                    ? Colors.black38
                                    : Colors.black87,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color:
                              _birthDate == null
                                  ? Colors.black38
                                  : AppTheme.primary,
                        ),
                      ],
                    ),
                  ),
                  if (_isDatePickerVisible)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: CustomDatePicker(
                        initialDate: _birthDate,
                        onDateSelected: _onDateSelected,
                      ),
                    ),
                  const SizedBox(height: 32),
                  _buildSelectionCard(
                    title: '选择血型',
                    onTap: () {},
                    child: _buildBloodTypeSelector(),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_birthDate != null && _bloodType != null) {
                          _submitForm();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.smallRadius,
                          ),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            '开始占卜',
                            style: AppTheme.titleStyle.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_birthDate != null && _bloodType != null)
                    Center(
                      child: Text(
                        '喵星人正在聚集能量...',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
