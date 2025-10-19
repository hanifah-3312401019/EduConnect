import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppTitle extends StatelessWidget {
  final String? welcomeText;
  final bool showSubtitleCard;

  const AppTitle({
    super.key,
    this.welcomeText,
    this.showSubtitleCard = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (welcomeText != null) ...[
          Text(
            welcomeText!,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppConstants.primaryColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 30),
        ],
        
        const Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: AppConstants.primaryColor,
            letterSpacing: -1.0,
          ),
        ),
        
        if (showSubtitleCard) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              AppConstants.appName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}