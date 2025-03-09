import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../modules/style/app_theme.dart';

class CatSagePage extends StatefulWidget {
  const CatSagePage({super.key});

  @override
  State<CatSagePage> createState() => _CatSagePageState();
}

class _CatSagePageState extends State<CatSagePage> with TickerProviderStateMixin {
  // 创建控制器工厂函数以确保惰性初始化
  AnimationController? _pageLoadController;
  AnimationController? _refreshController;
  final ScrollController _scrollController = ScrollController();
  
  // Sample data for meow signs
  final List<MeowSignRecord> _meowSigns = List.generate(
    15,
    (index) => MeowSignRecord(
      id: 'sign_${index + 1}',
      date: DateTime.now().subtract(Duration(days: index)),
      content: '每天醒来都是崭新的开始，今天也要加油喵～',
      mood: MoodType.values[index % MoodType.values.length],
    ),
  );

  bool _isRefreshing = false;

  // 确保获取控制器方法
  AnimationController get pageLoadController {
    _pageLoadController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    return _pageLoadController!;
  }

  AnimationController get refreshController {
    _refreshController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    return _refreshController!;
  }

  @override
  void initState() {
    super.initState();
    
    // 启动加载动画
    pageLoadController.forward();
    
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _pageLoadController?.dispose();
    _refreshController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Pull to refresh logic
    if (_scrollController.position.pixels < -80 && !_isRefreshing) {
      _onRefresh();
    }
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    refreshController.reset();
    refreshController.forward();
    
    // Simulate network request with retry mechanism
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Add a new meow sign at the top of the list
    if (mounted) {
      setState(() {
        _meowSigns.insert(
          0,
          MeowSignRecord(
            id: 'sign_${_meowSigns.length + 1}',
            date: DateTime.now(),
            content: '新的一天，新的开始，喵～',
            mood: MoodType.values[math.Random().nextInt(MoodType.values.length)],
          ),
        );
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 12) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF6F7),
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom App Bar with animated title
              SliverPersistentHeader(
                pinned: true,
                delegate: _MeowSignAppBar(
                  minHeight: 60,
                  maxHeight: 120,
                  refreshing: _isRefreshing,
                  refreshAnimation: refreshController,
                ),
              ),
              
              // Pull to refresh indicator
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isRefreshing ? 80.0 : 0.0,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: refreshController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: refreshController.value * 2 * math.pi,
                          child: Icon(
                            Icons.auto_awesome,
                            color: AppTheme.primary,
                            size: 36,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // Empty state when no signs available
              if (_meowSigns.isEmpty)
                SliverFillRemaining(
                  child: _EmptyStateWidget(),
                )
              else
                // Staggered animation grid of meow signs
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverAnimatedGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 160,
                    ),
                    initialItemCount: _meowSigns.length,
                    itemBuilder: (context, index, animation) {
                      // Staggered entry animation
                      final staggeredAnimation = CurvedAnimation(
                        parent: animation,
                        curve: Interval(
                          index / _meowSigns.length * 0.5,
                          1.0,
                          curve: Curves.easeOutQuart,
                        ),
                      );
                      
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(staggeredAnimation),
                        child: FadeTransition(
                          opacity: staggeredAnimation,
                          child: MeowSignCard(
                            record: _meowSigns[index],
                            onTap: () => _showSignDetails(context, _meowSigns[index]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: AnimatedBuilder(
          animation: pageLoadController,
          builder: (context, child) {
            return Transform.scale(
              scale: Tween<double>(begin: 0.0, end: 1.0)
                  .animate(CurvedAnimation(
                      parent: pageLoadController,
                      curve: const Interval(0.7, 1.0, curve: Curves.elasticOut)))
                  .value,
              child: child,
            );
          },
          child: FloatingActionButton(
            onPressed: _onRefresh,
            backgroundColor: AppTheme.primary,
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _showSignDetails(BuildContext context, MeowSignRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SignDetailsBottomSheet(record: record),
    );
  }
}

class _MeowSignAppBar extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final bool refreshing;
  final AnimationController refreshAnimation;

  _MeowSignAppBar({
    required this.minHeight,
    required this.maxHeight,
    required this.refreshing,
    required this.refreshAnimation,
  });

  @override
  double get minExtent => minHeight;
  
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / (maxExtent - minExtent);
    final fontSize = lerpDouble(28, 20, progress.clamp(0, 1)) ?? 24;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F7),
        boxShadow: [
          if (shrinkOffset > 0)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Back button
          Positioned(
            left: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: '返回',
            ),
          ),
          
          // Title with animation
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '喵签历史',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                if (refreshing)
                  AnimatedBuilder(
                    animation: refreshAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: refreshAnimation.value * 2 * math.pi,
                        child: Icon(
                          Icons.pets,
                          color: AppTheme.primary,
                          size: fontSize - 4,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_MeowSignAppBar oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        refreshing != oldDelegate.refreshing;
  }
}

class MeowSignCard extends StatefulWidget {
  final MeowSignRecord record;
  final VoidCallback onTap;

  const MeowSignCard({
    Key? key,
    required this.record,
    required this.onTap,
  }) : super(key: key);

  @override
  State<MeowSignCard> createState() => _MeowSignCardState();
}

class _MeowSignCardState extends State<MeowSignCard> 
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool hover) {
    setState(() {
      _isHovering = hover;
      if (hover) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final moodColors = {
      MoodType.happy: Colors.amber,
      MoodType.calm: Colors.lightBlue,
      MoodType.energetic: Colors.orange,
      MoodType.reflective: Colors.purple.shade300,
    };

    final moodIcons = {
      MoodType.happy: Icons.sentiment_very_satisfied,
      MoodType.calm: Icons.nightlight_round,
      MoodType.energetic: Icons.bolt,
      MoodType.reflective: Icons.auto_awesome,
    };

    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_hoverController.value * 0.03),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: Hero(
            tag: 'meow_sign_${widget.record.id}',
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovering ? 0.12 : 0.06),
                      blurRadius: _isHovering ? 12 : 6,
                      offset: Offset(0, _isHovering ? 6 : 3),
                      spreadRadius: _isHovering ? 2 : 0,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Card content
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date and mood indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${widget.record.date.year}年${widget.record.date.month}月${widget.record.date.day}日',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: moodColors[widget.record.mood]!.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      moodIcons[widget.record.mood],
                                      size: 16,
                                      color: moodColors[widget.record.mood],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getMoodText(widget.record.mood),
                                      style: TextStyle(
                                        color: moodColors[widget.record.mood],
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Main content
                          Text(
                            widget.record.content,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const Spacer(),
                          
                          // Bottom indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '点击查看详情',
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Colors.black38,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Decorative elements
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Opacity(
                        opacity: 0.06,
                        child: Icon(
                          Icons.pets,
                          size: 100,
                          color: moodColors[widget.record.mood],
                        ),
                      ),
                    ),
                    
                    // Indicator bar on the left
                    Positioned(
                      left: 0,
                      top: 10,
                      bottom: 10,
                      width: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: moodColors[widget.record.mood],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _getMoodText(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return '愉悦';
      case MoodType.calm: return '平静';
      case MoodType.energetic: return '活力';
      case MoodType.reflective: return '思考';
    }
  }
}

class SignDetailsBottomSheet extends StatelessWidget {
  final MeowSignRecord record;

  const SignDetailsBottomSheet({
    Key? key,
    required this.record,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final moodColors = {
      MoodType.happy: Colors.amber,
      MoodType.calm: Colors.lightBlue,
      MoodType.energetic: Colors.orange,
      MoodType.reflective: Colors.purple.shade300,
    };

    final moodIcons = {
      MoodType.happy: Icons.sentiment_very_satisfied,
      MoodType.calm: Icons.nightlight_round,
      MoodType.energetic: Icons.bolt,
      MoodType.reflective: Icons.auto_awesome,
    };

    return Hero(
      tag: 'meow_sign_${record.id}',
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sheet handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with date and mood
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${record.date.year}年${record.date.month}月${record.date.day}日',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: moodColors[record.mood]!.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                moodIcons[record.mood],
                                size: 18,
                                color: moodColors[record.mood],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getMoodText(record.mood),
                                style: TextStyle(
                                  color: moodColors[record.mood],
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Main content
                    // Expanded version with more details
                    Text(
                      record.content,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.8,
                        letterSpacing: 0.3,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Additional details here (if needed)
                    // For example, related images, interpretations, etc.
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: moodColors[record.mood],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '喵仙人的解读：这段话反映了你当时的心情和状态，希望能给你带来一些思考和启发。',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '关闭',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getMoodText(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return '愉悦';
      case MoodType.calm: return '平静';
      case MoodType.energetic: return '活力';
      case MoodType.reflective: return '思考';
    }
  }
}

class _EmptyStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            '暂无喵签记录',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '未来的喵签将会显示在这里',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// Enums and Data Models
enum MoodType {
  happy,
  calm,
  energetic,
  reflective,
}

class MeowSignRecord {
  final String id;
  final DateTime date;
  final String content;
  final MoodType mood;

  MeowSignRecord({
    required this.id,
    required this.date,
    required this.content,
    required this.mood,
  });
}

// Helper function
double? lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}
