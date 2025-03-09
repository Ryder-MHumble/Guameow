import 'package:flutter/material.dart';
import '../../modules/style/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'widgets/custom_date_picker.dart';
import '../../models/fortune_report.dart';
import '../../services/fortune_service.dart';
import 'fortune_telling_report_page.dart';

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

  void _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _birthDate != null &&
        _bloodType != null) {
      try {
        // 显示加载指示器
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/cat_divination.gif',
                    height: 120,
                    width: 120,
                    errorBuilder: (context, error, stackTrace) => const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '喵仙人正在为你解读命理...',
                    style: AppTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // 生成命理报告
        final report = await FortuneService.generateReport(
          _birthDate!,
          _bloodType!,
        );

        // 确保在弹出对话框前检查上下文是否有效
        if (!mounted) return;
        
        // 关闭加载指示器
        Navigator.of(context).pop();

        // 确保app没有被销毁后再导航
        if (mounted) {
          // 导航到报告页面
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FortuneTellingReportPage(report: report),
            ),
          );
        }
      } catch (e) {
        // 确保上下文有效
        if (!mounted) return;
        
        // 关闭加载指示器
        Navigator.of(context).pop();

        // 显示错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('生成报告时出错：${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    final bottomPadding = MediaQuery.of(context).padding.bottom + 20;
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Set to transparent to show the gradient
      body: Container(
        decoration: BoxDecoration(
          // Match the gradient from the daily fortune page
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFF6FA),
              const Color(0xFFFEF0F7),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
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
                                '让喵仙人为你解读未知的密码',
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
                              '喵仙人正在聚集能量...',
                              style: AppTheme.bodyStyle.copyWith(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        // Add extra space at the bottom to ensure content isn't covered by gradient
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // White gradient transition at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60 + bottomPadding,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.8),
                      Colors.white,
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
