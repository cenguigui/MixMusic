import 'package:flutter/material.dart';

class HyperCard extends StatelessWidget {
  const HyperCard({super.key, this.width, this.height, this.borderRadius, this.child, this.color});

  final Widget? child;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: Material(
          color: color ?? Theme.of(context).colorScheme.surfaceContainer,
          child: child,
        ),
      ),
    );
  }
}
