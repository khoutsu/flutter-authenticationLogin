import 'package:flutter/material.dart';

class GradientBg extends StatelessWidget {
  final Widget child;
  const GradientBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)], // ฟ้า->ม่วง
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
