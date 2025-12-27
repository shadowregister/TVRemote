import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

class VolumeControl extends StatelessWidget {
  final VoidCallback onVolumeUp;
  final VoidCallback onVolumeDown;
  final VoidCallback onMute;
  final IconData upIcon;
  final IconData downIcon;
  final IconData muteIcon;
  final String? muteLabel;

  const VolumeControl({
    super.key,
    required this.onVolumeUp,
    required this.onVolumeDown,
    required this.onMute,
    this.upIcon = Icons.volume_up,
    this.downIcon = Icons.volume_down,
    this.muteIcon = Icons.volume_off,
    this.muteLabel,
  });

  void _handleTap(VoidCallback callback) {
    HapticFeedback.lightImpact();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Volume Up
        _VolumeButton(
          icon: upIcon,
          onPressed: () => _handleTap(onVolumeUp),
          isTop: true,
        ),

        // Mute
        _VolumeButton(
          icon: muteIcon,
          onPressed: () => _handleTap(onMute),
          isMute: true,
        ),

        // Volume Down
        _VolumeButton(
          icon: downIcon,
          onPressed: () => _handleTap(onVolumeDown),
          isBottom: true,
        ),

        if (muteLabel != null) ...[
          const SizedBox(height: 4),
          Text(
            muteLabel!,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
            ),
          ),
        ],
      ],
    );
  }
}

class _VolumeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isTop;
  final bool isBottom;
  final bool isMute;

  const _VolumeButton({
    required this.icon,
    required this.onPressed,
    this.isTop = false,
    this.isBottom = false,
    this.isMute = false,
  });

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.zero;
    if (isTop) {
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      );
    } else if (isBottom) {
      borderRadius = const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      );
    }

    return Material(
      color: isMute ? AppTheme.primaryColor.withOpacity(0.2) : AppTheme.darkCard,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: SizedBox(
          width: 48,
          height: isMute ? 40 : 48,
          child: Icon(
            icon,
            color: isMute ? AppTheme.primaryColor : Colors.white70,
            size: 24,
          ),
        ),
      ),
    );
  }
}
