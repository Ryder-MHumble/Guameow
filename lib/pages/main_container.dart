import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../modules/style/app_theme.dart';
import '../modules/physics/custom_page_physics.dart';
import 'daily_fortune/daily_fortune_page.dart';
import 'fortune_telling/fortune_telling_page.dart';
import 'cat_sage/cat_sage_page.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({Key? key}) : super(key: key);

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Color?> _colorAnimation;

  // 主页面列表
  final List<Widget> _pages = const [
    DailyFortunePage(), // 每日喵签
    FortuneTellingPage(), // 喵咪占卜
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 1.0);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 0.1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.1,
          end: -0.1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.1,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_controller);

    _colorAnimation = ColorTween(
      begin: AppTheme.primary.withOpacity(0.1),
      end: AppTheme.secondary.withOpacity(0.3),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openCatSagePage() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const CatSagePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const CustomPageViewScrollPhysics(),
        children: _pages,
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 12),
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            _openCatSagePage();
          },
          onTapCancel: () => _controller.reverse(),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _glowAnimation.value,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _colorAnimation.value,
                              ),
                            ),
                          );
                        },
                      ),
                      SvgPicture.asset(
                        'assets/svg/nav_icons/猫咪毛球.svg',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 80,
        elevation: 8,
        padding: EdgeInsets.zero,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        color: Colors.white,
        shadowColor: AppTheme.primary.withOpacity(0.2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, '每日喵签', 'assets/svg/nav_icons/粉-描边猫咪.svg'),
            const SizedBox(width: 88),
            _buildNavItem(1, '喵咪占卜', 'assets/svg/nav_icons/粉-星座占卜.svg'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String iconPath) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(isSelected ? 8 : 4),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppTheme.primary.withOpacity(0.1)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      isSelected ? AppTheme.primary : const Color(0xFFD8D8D8),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isSelected ? 13 : 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color:
                        isSelected ? AppTheme.primary : const Color(0xFFD8D8D8),
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
