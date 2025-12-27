import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../device_discovery/domain/discovered_device.dart';
import '../../device_discovery/presentation/discovery_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showManageDevicesDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ManageDevicesSheet(ref: ref),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final textPrimary = NeumorphicColors.getTextPrimary(context);

    return Scaffold(
      backgroundColor: NeumorphicColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SectionHeader(title: 'Appearance'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: _getThemeModeLabel(themeMode),
                    trailing: _NeumorphicSwitch(
                      value: themeMode == ThemeMode.dark,
                      onChanged: (_) {
                        HapticFeedback.lightImpact();
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Feedback'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.vibration,
                    title: 'Haptic Feedback',
                    subtitle: 'Vibrate when pressing buttons',
                    trailing: _NeumorphicSwitch(
                      value: ref.watch(hapticEnabledProvider),
                      onChanged: (_) {
                        HapticFeedback.lightImpact();
                        ref.read(hapticEnabledProvider.notifier).toggle();
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Devices'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.tv,
                    title: 'Manage Devices',
                    subtitle: 'View and remove saved TVs',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showManageDevicesDialog(context, ref);
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'About'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About TV Remote',
                    subtitle: 'Version, donations & more',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push(AppRoutes.about);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textPrimary = NeumorphicColors.getTextPrimary(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          NeumorphicIconButton(
            onPressed: () => context.pop(),
            icon: Icons.arrow_back_ios_new,
            size: 44,
          ),
          const SizedBox(width: 16),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.accentColor,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = NeumorphicColors.getBackground(context);
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);
    final textPrimary = NeumorphicColors.getTextPrimary(context);
    final textSecondary = NeumorphicColors.getTextSecondary(context);
    final textMuted = NeumorphicColors.getTextMuted(context);

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed
              ? null
              : [
                  BoxShadow(
                    color: shadowDark,
                    offset: const Offset(5, 5),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: shadowLight,
                    offset: const Offset(-5, -5),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: Row(
          children: [
            NeumorphicIconButton(
              onPressed: () {},
              icon: widget.icon,
              size: 44,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            widget.trailing ?? Icon(Icons.chevron_right, color: textMuted),
          ],
        ),
      ),
    );
  }
}

class _NeumorphicSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NeumorphicSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final bgColor = NeumorphicColors.getBackground(context);
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppTheme.accentColor : bgColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: value
              ? null
              : [
                  BoxShadow(
                    color: shadowDark,
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: shadowLight,
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ManageDevicesSheet extends StatelessWidget {
  final WidgetRef ref;

  const _ManageDevicesSheet({required this.ref});

  IconData _getBrandIcon(TvBrand brand) {
    switch (brand) {
      case TvBrand.samsung:
      case TvBrand.lg:
      case TvBrand.vizio:
      case TvBrand.sony:
        return Icons.tv;
      case TvBrand.androidTv:
        return Icons.android;
      case TvBrand.roku:
        return Icons.connected_tv;
      case TvBrand.fireTv:
        return Icons.local_fire_department;
      case TvBrand.unknown:
        return Icons.device_unknown;
    }
  }

  void _confirmRemoveDevice(BuildContext context, DiscoveredDevice device) {
    final bgColor = NeumorphicColors.getBackground(context);
    final textPrimary = NeumorphicColors.getTextPrimary(context);
    final textSecondary = NeumorphicColors.getTextSecondary(context);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeumorphicIconButton(
                onPressed: () {},
                icon: Icons.delete_outline,
                size: 60,
                iconColor: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Remove Device?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Remove "${device.name}" from saved devices?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: NeumorphicButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeumorphicButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ref.read(discoveredDevicesProvider.notifier).removeDevice(device.id);
                        Navigator.pop(dialogContext);
                      },
                      accentColor: AppTheme.errorColor,
                      child: const Text(
                        'Remove',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(discoveredDevicesProvider);
    final savedDevices = devices.where((d) => d.lastConnected != null || d.authToken != null).toList();
    final bgColor = NeumorphicColors.getBackground(context);
    final textPrimary = NeumorphicColors.getTextPrimary(context);
    final textSecondary = NeumorphicColors.getTextSecondary(context);
    final textMuted = NeumorphicColors.getTextMuted(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Saved Devices',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${savedDevices.length} device${savedDevices.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: savedDevices.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NeumorphicIconButton(
                          onPressed: () {},
                          icon: Icons.tv_off,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Saved Devices',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connect to a TV and it will appear here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: savedDevices.length,
                    itemBuilder: (context, index) {
                      final device = savedDevices[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NeumorphicContainer(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              NeumorphicIconButton(
                                onPressed: () {},
                                icon: _getBrandIcon(device.brand),
                                size: 48,
                                isAccent: true,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${device.brand.displayName} • ${device.ipAddress}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              NeumorphicIconButton(
                                onPressed: () => _confirmRemoveDevice(context, device),
                                icon: Icons.delete_outline,
                                size: 40,
                                iconColor: AppTheme.errorColor,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
