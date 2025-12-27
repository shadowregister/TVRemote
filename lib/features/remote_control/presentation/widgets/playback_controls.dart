import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

class PlaybackControls extends StatelessWidget {
  final VoidCallback onRewind;
  final VoidCallback onPlayPause;
  final VoidCallback onFastForward;
  final VoidCallback? onStop;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PlaybackControls({
    super.key,
    required this.onRewind,
    required this.onPlayPause,
    required this.onFastForward,
    this.onStop,
    this.onPrevious,
    this.onNext,
  });

  void _handleTap(VoidCallback callback) {
    HapticFeedback.lightImpact();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Main controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PlaybackButton(
                icon: Icons.fast_rewind,
                onPressed: () => _handleTap(onRewind),
              ),
              _PlaybackButton(
                icon: Icons.play_arrow,
                onPressed: () => _handleTap(onPlayPause),
                isPrimary: true,
              ),
              _PlaybackButton(
                icon: Icons.fast_forward,
                onPressed: () => _handleTap(onFastForward),
              ),
            ],
          ),

          if (onStop != null || onPrevious != null || onNext != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onPrevious != null)
                  _PlaybackButton(
                    icon: Icons.skip_previous,
                    onPressed: () => _handleTap(onPrevious!),
                    size: 40,
                  ),
                if (onStop != null)
                  _PlaybackButton(
                    icon: Icons.stop,
                    onPressed: () => _handleTap(onStop!),
                    size: 40,
                  ),
                if (onNext != null)
                  _PlaybackButton(
                    icon: Icons.skip_next,
                    onPressed: () => _handleTap(onNext!),
                    size: 40,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PlaybackButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final double size;

  const _PlaybackButton({
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppTheme.primaryColor : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: Colors.white,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }
}
