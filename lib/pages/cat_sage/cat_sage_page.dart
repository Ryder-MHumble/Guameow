import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../modules/style/app_theme.dart';

class CatSagePage extends StatefulWidget {
  const CatSagePage({super.key});

  @override
  State<CatSagePage> createState() => _CatSagePageState();
}

class _CatSagePageState extends State<CatSagePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  bool _isInCall = false;
  final List<double> _waveHeights = List.filled(30, 0.0);
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
      if (_isInCall) {
        setState(() {
          // 更新波形高度
          for (var i = 0; i < _waveHeights.length; i++) {
            _waveHeights[i] = _random.nextDouble() * 40;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _toggleCall() {
    setState(() {
      _isInCall = !_isInCall;
      if (_isInCall) {
        _waveController.repeat();
      } else {
        _waveController.stop();
        // 重置波形
        for (var i = 0; i < _waveHeights.length; i++) {
          _waveHeights[i] = 0;
        }
      }
    });
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // title: const Text(
          //   '喵仙人',
          //   style: TextStyle(
          //     color: Colors.black87,
          //     fontSize: 18,
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 通话状态文本
                    Text(
                      _isInCall ? '正在通话中...' : '点击开始对话',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 波形动画
                    CustomPaint(
                      size: const Size(200, 60),
                      painter: WaveformPainter(
                        waveHeights: _waveHeights,
                        color: AppTheme.primary.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 底部按钮区域
            Container(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _toggleCall,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isInCall ? Colors.red : AppTheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isInCall ? Icons.call_end : Icons.mic,
                        color: Colors.white,
                        size: 32,
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
}

class WaveformPainter extends CustomPainter {
  final List<double> waveHeights;
  final Color color;

  WaveformPainter({required this.waveHeights, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

    final spacing = size.width / (waveHeights.length - 1);
    final middle = size.height / 2;

    for (var i = 0; i < waveHeights.length; i++) {
      final x = i * spacing;
      final height = waveHeights[i];
      canvas.drawLine(
        Offset(x, middle - height / 2),
        Offset(x, middle + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return true;
  }
}
