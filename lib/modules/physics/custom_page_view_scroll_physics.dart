import 'package:flutter/material.dart';

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 50,       // 减小质量使滑动更轻盈
        stiffness: 150, // 增加刚度使滑动更快
        damping: 1.1,   // 适当的阻尼使停止更平滑
      );

  @override
  double get minFlingVelocity => 1.0; // 降低触发滑动的最小速度

  @override
  double get maxFlingVelocity => 1.5; // 限制最大滑动速度

  @override
  double get dragStartDistanceMotionThreshold => 12.0; // 调整开始滑动的阈值
}
