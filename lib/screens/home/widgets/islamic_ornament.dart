import 'package:flutter/material.dart';

class IslamicOrnament extends StatelessWidget {
  final double height;
  const IslamicOrnament({this.height = 60, super.key});
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/ornament.jpg',
      height: height,
      fit: BoxFit.cover,
      color: const Color(0xFF04700D),
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
