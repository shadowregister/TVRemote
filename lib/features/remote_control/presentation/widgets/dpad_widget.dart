import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

class DPadWidget extends StatelessWidget {
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onCenter;

  const DPadWidget({
    super.key,
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
    required this.onCenter,
  });

  void _handleTap(VoidCallback callback) {
    HapticFeedback.lightImpact();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    const size = 180.0;
    const buttonSize = 56.0;
    const centerSize = 60.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.darkCard,
              border: Border.all(
                color: AppTheme.darkDivider,
                width: 2,
              ),
            ),
          ),

          // Up button
          Positioned(
            top: 8,
            child: _DPadButton(
              icon: Icons.keyboard_arrow_up,
              onPressed: () => _handleTap(onUp),
              size: buttonSize,
            ),
          ),

          // Down button
          Positioned(
            bottom: 8,
            child: _DPadButton(
              icon: Icons.keyboard_arrow_down,
              onPressed: () => _handleTap(onDown),
              size: buttonSize,
            ),
          ),

          // Left button
          Positioned(
            left: 8,
            child: _DPadButton(
              icon: Icons.keyboard_arrow_left,
              onPressed: () => _handleTap(onLeft),
              size: buttonSize,
            ),
          ),

          // Right button
          Positioned(
            right: 8,
            child: _DPadButton(
              icon: Icons.keyboard_arrow_right,
              onPressed: () => _handleTap(onRight),
              size: buttonSize,
            ),
          ),

          // Center OK button
          Material(
            color: AppTheme.primaryColor,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => _handleTap(onCenter),
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: centerSize,
                height: centerSize,
                child: const Center(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DPadButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  const _DPadButton({
    required this.icon,
    required this.onPressed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: 32,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
