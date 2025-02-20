import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedSVG extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final Color? color;
  final Duration duration;

  const AnimatedSVG({
    Key? key,
    required this.assetPath,
    this.width,
    this.height,
    this.color,
    this.duration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<AnimatedSVG> createState() => _AnimatedSVGState();
}

class _AnimatedSVGState extends State<AnimatedSVG>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Animation<double>>? _pathAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimations(int pathCount) {
    _pathAnimations = List.generate(
      pathCount,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            (index + 1) * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      widget.assetPath,
      width: widget.width,
      height: widget.height,
      colorFilter: widget.color != null
          ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
          : null,
      placeholderBuilder: (context) => const SizedBox.shrink(),
    );
  }
}
