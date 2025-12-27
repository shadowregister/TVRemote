import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../main.dart';
import '../../device_discovery/domain/discovered_device.dart';
import '../../device_discovery/presentation/discovery_provider.dart';
import '../domain/remote_command.dart';
import 'remote_provider.dart';

class RemoteScreen extends ConsumerStatefulWidget {
  final String? deviceId;

  const RemoteScreen({super.key, this.deviceId});

  @override
  ConsumerState<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends ConsumerState<RemoteScreen> {
  DiscoveredDevice? _device;
  bool _showNumberPad = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _initConnection();
  }

  void _initConnection() {
    final devices = ref.read(discoveredDevicesProvider);
    try {
      _device = devices.firstWhere(
        (d) => d.id == widget.deviceId,
        orElse: () => devices.isNotEmpty ? devices.first : throw Exception('No device'),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(connectedDeviceProvider.notifier).state = _device;
      });
    } catch (e) {
      debugPrint('Error finding device: $e');
    }
  }

  Future<void> _sendCommand(RemoteKey key) async {
    triggerHaptic(ref);
    debugPrint('Sending command: ${key.name} to ${_device?.brand.displayName}');

    final success = await ref.read(tvControllerProvider.notifier).sendCommand(key);

    if (!success && mounted) {
      setState(() => _lastError = 'Command failed');
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _lastError = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(isConnectedProvider);

    if (_device == null) {
      return Scaffold(
        backgroundColor: NeumorphicColors.getBackground(context),
        body: Center(
          child: Text('No device connected', style: TextStyle(color: NeumorphicColors.getTextSecondary(context))),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NeumorphicColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isConnected),
            Expanded(
              child: _showNumberPad ? _buildNumberPad(context) : _buildRemote(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isConnected) {
    final textPrimary = NeumorphicColors.getTextPrimary(context);
    final textSecondary = NeumorphicColors.getTextSecondary(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          NeumorphicIconButton(
            onPressed: () {
              ref.read(tvControllerProvider.notifier).disconnect();
              ref.read(connectedDeviceProvider.notifier).state = null;
              context.go(AppRoutes.discovery);
            },
            icon: Icons.arrow_back_ios_new,
            size: 44,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: NeumorphicContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: 16,
              child: Row(
                children: [
                  StatusIndicator(isConnected: isConnected),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _device!.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _lastError ?? (isConnected ? 'Connected' : 'Connecting...'),
                          style: TextStyle(
                            fontSize: 12,
                            color: _lastError != null ? AppTheme.errorColor : textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          NeumorphicIconButton(
            onPressed: () => setState(() => _showNumberPad = !_showNumberPad),
            icon: _showNumberPad ? Icons.gamepad_outlined : Icons.dialpad,
            size: 44,
            isAccent: _showNumberPad,
          ),
          const SizedBox(width: 12),
          NeumorphicIconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: Icons.settings_outlined,
            size: 44,
          ),
        ],
      ),
    );
  }

  Widget _buildRemote(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildTopControls(context),
          const SizedBox(height: 32),
          _buildDPad(context),
          const SizedBox(height: 32),
          _buildNavigationRow(context),
          const SizedBox(height: 32),
          _buildPlaybackControls(context),
          const SizedBox(height: 32),
          _buildQuickApps(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTopControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NeumorphicIconButton(
          onPressed: () => _sendCommand(RemoteKey.source),
          icon: Icons.input,
          label: 'Source',
          size: 52,
        ),
        _PowerButton(onPressed: () => _sendCommand(RemoteKey.power)),
        NeumorphicIconButton(
          onPressed: () => _sendCommand(RemoteKey.settings),
          icon: Icons.tune,
          label: 'Settings',
          size: 52,
        ),
      ],
    );
  }

  Widget _buildDPad(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildVolumeControls(context),
        const SizedBox(width: 12),
        _buildDPadCircle(context),
        const SizedBox(width: 12),
        _buildChannelControls(context),
      ],
    );
  }

  Widget _buildVolumeControls(BuildContext context) {
    final textMuted = NeumorphicColors.getTextMuted(context);

    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      borderRadius: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SmallButton(
            icon: Icons.add,
            onPressed: () => _sendCommand(RemoteKey.volumeUp),
          ),
          const SizedBox(height: 12),
          Text(
            'VOL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _SmallButton(
            icon: Icons.remove,
            onPressed: () => _sendCommand(RemoteKey.volumeDown),
          ),
          const SizedBox(height: 16),
          _SmallButton(
            icon: Icons.volume_off,
            onPressed: () => _sendCommand(RemoteKey.mute),
            isAccent: true,
          ),
        ],
      ),
    );
  }

  Widget _buildChannelControls(BuildContext context) {
    final textMuted = NeumorphicColors.getTextMuted(context);

    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      borderRadius: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SmallButton(
            icon: Icons.keyboard_arrow_up,
            onPressed: () => _sendCommand(RemoteKey.channelUp),
          ),
          const SizedBox(height: 12),
          Text(
            'CH',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _SmallButton(
            icon: Icons.keyboard_arrow_down,
            onPressed: () => _sendCommand(RemoteKey.channelDown),
          ),
          const SizedBox(height: 16),
          _SmallButton(
            icon: Icons.list,
            onPressed: () => _sendCommand(RemoteKey.guide),
            isAccent: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDPadCircle(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 100,
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: _DPadButton(
                icon: Icons.keyboard_arrow_up,
                onPressed: () => _sendCommand(RemoteKey.up),
              ),
            ),
            Positioned(
              bottom: 0,
              child: _DPadButton(
                icon: Icons.keyboard_arrow_down,
                onPressed: () => _sendCommand(RemoteKey.down),
              ),
            ),
            Positioned(
              left: 0,
              child: _DPadButton(
                icon: Icons.keyboard_arrow_left,
                onPressed: () => _sendCommand(RemoteKey.left),
              ),
            ),
            Positioned(
              right: 0,
              child: _DPadButton(
                icon: Icons.keyboard_arrow_right,
                onPressed: () => _sendCommand(RemoteKey.right),
              ),
            ),
            _OKButton(onPressed: () => _sendCommand(RemoteKey.enter)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRow(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NeumorphicIconButton(
            onPressed: () => _sendCommand(RemoteKey.back),
            icon: Icons.arrow_back,
            label: 'Back',
            size: 48,
          ),
          NeumorphicIconButton(
            onPressed: () => _sendCommand(RemoteKey.home),
            icon: Icons.home,
            label: 'Home',
            size: 48,
            isAccent: true,
          ),
          NeumorphicIconButton(
            onPressed: () => _sendCommand(RemoteKey.menu),
            icon: Icons.menu,
            label: 'Menu',
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SmallButton(
            icon: Icons.fast_rewind,
            onPressed: () => _sendCommand(RemoteKey.rewind),
          ),
          _SmallButton(
            icon: Icons.skip_previous,
            onPressed: () => _sendCommand(RemoteKey.previous),
          ),
          NeumorphicIconButton(
            onPressed: () => _sendCommand(RemoteKey.playPause),
            icon: Icons.play_arrow,
            size: 52,
            isAccent: true,
          ),
          _SmallButton(
            icon: Icons.skip_next,
            onPressed: () => _sendCommand(RemoteKey.next),
          ),
          _SmallButton(
            icon: Icons.fast_forward,
            onPressed: () => _sendCommand(RemoteKey.fastForward),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickApps(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _AppButton(
          label: 'Netflix',
          onPressed: () => _sendCommand(RemoteKey.netflix),
        ),
        _AppButton(
          label: 'YouTube',
          onPressed: () => _sendCommand(RemoteKey.youtube),
        ),
        _AppButton(
          label: 'Prime',
          onPressed: () => _sendCommand(RemoteKey.amazonPrime),
        ),
        _AppButton(
          label: 'Disney+',
          onPressed: () => _sendCommand(RemoteKey.disney),
        ),
      ],
    );
  }

  Widget _buildNumberPad(BuildContext context) {
    final textPrimary = NeumorphicColors.getTextPrimary(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Number Pad',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            for (var row = 0; row < 4; row++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var col = 0; col < 3; col++)
                      Builder(builder: (context) {
                        final index = row * 3 + col;
                        if (row == 3) {
                          if (col == 0) return const SizedBox(width: 72);
                          if (col == 1) {
                            return _NumberButton(
                              number: 0,
                              onPressed: () => _sendCommand(RemoteKey.num0),
                            );
                          }
                          return _SmallButton(
                            icon: Icons.backspace_outlined,
                            onPressed: () => _sendCommand(RemoteKey.back),
                          );
                        }
                        return _NumberButton(
                          number: index + 1,
                          onPressed: () => _sendCommand(
                            RemoteKey.values.firstWhere((k) => k.name == 'num${index + 1}'),
                          ),
                        );
                      }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PowerButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PowerButton({required this.onPressed});

  @override
  State<_PowerButton> createState() => _PowerButtonState();
}

class _PowerButtonState extends State<_PowerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = NeumorphicColors.getBackground(context);
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);
    final textMuted = NeumorphicColors.getTextMuted(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            HapticFeedback.mediumImpact();
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: _isPressed
                  ? [BoxShadow(color: shadowDark.withOpacity(0.8), offset: const Offset(2, 2), blurRadius: 4)]
                  : [
                      BoxShadow(color: shadowDark, offset: const Offset(5, 5), blurRadius: 10),
                      BoxShadow(color: shadowLight, offset: const Offset(-5, -5), blurRadius: 10),
                    ],
            ),
            child: const Icon(Icons.power_settings_new, color: AppTheme.errorColor, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text('Power', style: TextStyle(fontSize: 11, color: textMuted, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _SmallButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isAccent;

  const _SmallButton({required this.icon, required this.onPressed, this.isAccent = false});

  @override
  State<_SmallButton> createState() => _SmallButtonState();
}

class _SmallButtonState extends State<_SmallButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isAccent ? AppTheme.accentColor : NeumorphicColors.getBackground(context);
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);
    final textPrimary = NeumorphicColors.getTextPrimary(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: _isPressed
              ? null
              : [
                  BoxShadow(color: shadowDark, offset: const Offset(3, 3), blurRadius: 6),
                  BoxShadow(color: shadowLight, offset: const Offset(-3, -3), blurRadius: 6),
                ],
        ),
        child: Icon(widget.icon, color: widget.isAccent ? Colors.white : textPrimary, size: 18),
      ),
    );
  }
}

class _DPadButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _DPadButton({required this.icon, required this.onPressed});

  @override
  State<_DPadButton> createState() => _DPadButtonState();
}

class _DPadButtonState extends State<_DPadButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = NeumorphicColors.getBackground(context);
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);
    final textPrimary = NeumorphicColors.getTextPrimary(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: _isPressed
              ? null
              : [
                  BoxShadow(color: shadowDark, offset: const Offset(3, 3), blurRadius: 6),
                  BoxShadow(color: shadowLight, offset: const Offset(-3, -3), blurRadius: 6),
                ],
        ),
        child: Icon(widget.icon, color: textPrimary, size: 24),
      ),
    );
  }
}

class _OKButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _OKButton({required this.onPressed});

  @override
  State<_OKButton> createState() => _OKButtonState();
}

class _OKButtonState extends State<_OKButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppTheme.accentColor,
          shape: BoxShape.circle,
          boxShadow: _isPressed
              ? null
              : [
                  BoxShadow(color: shadowDark, offset: const Offset(4, 4), blurRadius: 8),
                  BoxShadow(color: shadowLight, offset: const Offset(-4, -4), blurRadius: 8),
                ],
        ),
        child: const Center(
          child: Text('OK', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _NumberButton extends StatefulWidget {
  final int number;
  final VoidCallback onPressed;

  const _NumberButton({required this.number, required this.onPressed});

  @override
  State<_NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<_NumberButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = NeumorphicColors.getBackground(context);
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);
    final textPrimary = NeumorphicColors.getTextPrimary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          HapticFeedback.selectionClick();
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isPressed
                ? null
                : [
                    BoxShadow(color: shadowDark, offset: const Offset(4, 4), blurRadius: 8),
                    BoxShadow(color: shadowLight, offset: const Offset(-4, -4), blurRadius: 8),
                  ],
          ),
          child: Center(
            child: Text(
              '${widget.number}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _AppButton({required this.label, required this.onPressed});

  @override
  State<_AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<_AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.accentColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _isPressed
              ? null
              : [
                  BoxShadow(color: shadowDark, offset: const Offset(3, 3), blurRadius: 6),
                  BoxShadow(color: shadowLight, offset: const Offset(-3, -3), blurRadius: 6),
                ],
        ),
        child: Text(
          widget.label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}
