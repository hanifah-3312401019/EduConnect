import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size = AppConstants.splashLogoSize,
    this.borderRadius = AppConstants.splashLogoRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/images/Logo.png',
          fit: fit,
        ),
      ),
    );
  }
}