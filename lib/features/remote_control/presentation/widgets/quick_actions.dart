import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback? onNetflix;
  final VoidCallback? onYouTube;
  final VoidCallback? onPrimeVideo;
  final VoidCallback? onDisney;
  final VoidCallback? onHulu;

  const QuickActions({
    super.key,
    this.onNetflix,
    this.onYouTube,
    this.onPrimeVideo,
    this.onDisney,
    this.onHulu,
  });

  void _handleTap(VoidCallback? callback) {
    if (callback != null) {
      HapticFeedback.lightImpact();
      callback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _AppButton(
          label: 'Netflix',
          color: const Color(0xFFE50914),
          onPressed: onNetflix != null ? () => _handleTap(onNetflix) : null,
        ),
        _AppButton(
          label: 'YouTube',
          color: const Color(0xFFFF0000),
          onPressed: onYouTube != null ? () => _handleTap(onYouTube) : null,
        ),
        _AppButton(
          label: 'Prime',
          color: const Color(0xFF00A8E1),
          onPressed: onPrimeVideo != null ? () => _handleTap(onPrimeVideo) : null,
        ),
        _AppButton(
          label: 'Disney+',
          color: const Color(0xFF113CCF),
          onPressed: onDisney != null ? () => _handleTap(onDisney) : null,
        ),
      ],
    );
  }
}

class _AppButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _AppButton({
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(onPressed != null ? 1.0 : 0.3),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: onPressed != null ? Colors.white : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }
}
