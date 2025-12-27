import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/discovered_device.dart';
import 'discovery_provider.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScan();
    });
  }

  Future<void> _startScan() async {
    ref.read(isScanningProvider.notifier).state = true;
    await ref.read(discoveredDevicesProvider.notifier).startScan();

    await Future.delayed(const Duration(seconds: 10));
    if (mounted) {
      ref.read(isScanningProvider.notifier).state = false;
      await ref.read(discoveredDevicesProvider.notifier).stopScan();
    }
  }

  Future<void> _connectToDevice(DiscoveredDevice device) async {
    HapticFeedback.mediumImpact();
    ref.read(connectedDeviceProvider.notifier).state = device;
    await ref.read(discoveredDevicesProvider.notifier).markDeviceConnected(device.id);
    if (mounted) {
      context.go(AppRoutes.remote, extra: device.id);
    }
  }

  void _showAddManualDialog() {
    final ipController = TextEditingController();
    TvBrand selectedBrand = TvBrand.samsung;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final bgColor = NeumorphicColors.getBackground(dialogContext);
          final shadowDark = NeumorphicColors.getShadowDark(dialogContext);
          final shadowLight = NeumorphicColors.getShadowLight(dialogContext);
          final textPrimary = NeumorphicColors.getTextPrimary(dialogContext);
          final textSecondary = NeumorphicColors.getTextSecondary(dialogContext);
          final textMuted = NeumorphicColors.getTextMuted(dialogContext);

          return Dialog(
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: shadowDark,
                    offset: const Offset(8, 8),
                    blurRadius: 16,
                  ),
                  BoxShadow(
                    color: shadowLight,
                    offset: const Offset(-8, -8),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add TV Manually',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the IP address of your TV',
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  NeumorphicInset(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: ipController,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '192.168.1.100',
                        hintStyle: TextStyle(color: textMuted),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeumorphicInset(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TvBrand>(
                        value: selectedBrand,
                        isExpanded: true,
                        dropdownColor: bgColor,
                        style: TextStyle(color: textPrimary),
                        items: TvBrand.values
                            .where((b) => b != TvBrand.unknown)
                            .map((brand) => DropdownMenuItem(
                                  value: brand,
                                  child: Text(brand.displayName),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => selectedBrand = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      NeumorphicButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: textSecondary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      NeumorphicButton(
                        onPressed: () {
                          if (ipController.text.isNotEmpty) {
                            ref.read(discoveredDevicesProvider.notifier).addManualDevice(
                                  ipController.text,
                                  selectedBrand,
                                );
                            Navigator.pop(dialogContext);
                          }
                        },
                        accentColor: AppTheme.accentColor,
                        child: const Text(
                          'Add TV',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(discoveredDevicesProvider);
    final isScanning = ref.watch(isScanningProvider);

    return Scaffold(
      backgroundColor: NeumorphicColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (isScanning) _buildScanningIndicator(context),
            Expanded(
              child: devices.isEmpty
                  ? _buildEmptyState(context, isScanning)
                  : _buildDeviceList(devices),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeumorphicIconButton(
            onPressed: _showAddManualDialog,
            icon: Icons.add,
            size: 48,
          ),
          const SizedBox(height: 16),
          NeumorphicIconButton(
            onPressed: isScanning ? () {} : _startScan,
            icon: Icons.radar,
            size: 56,
            isAccent: !isScanning,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textPrimary = NeumorphicColors.getTextPrimary(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'TV Remote',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ),
          NeumorphicIconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: Icons.settings_outlined,
            size: 44,
          ),
        ],
      ),
    );
  }

  Widget _buildScanningIndicator(BuildContext context) {
    final textSecondary = NeumorphicColors.getTextSecondary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: NeumorphicContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Scanning network...',
              style: TextStyle(
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isScanning) {
    final textPrimary = NeumorphicColors.getTextPrimary(context);
    final textSecondary = NeumorphicColors.getTextSecondary(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeumorphicIconButton(
                onPressed: () {},
                icon: isScanning ? Icons.radar : Icons.tv_off,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                isScanning ? 'Searching for TVs...' : 'No TVs Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Make sure your TV is powered on and\nconnected to the same WiFi network',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              NeumorphicButton(
                onPressed: _showAddManualDialog,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: textPrimary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Add TV manually',
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceList(List<DiscoveredDevice> devices) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return _DeviceCard(
          device: device,
          onTap: () => _connectToDevice(device),
        );
      },
    );
  }
}

class _DeviceCard extends StatefulWidget {
  final DiscoveredDevice device;
  final VoidCallback onTap;

  const _DeviceCard({required this.device, required this.onTap});

  @override
  State<_DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<_DeviceCard> {
  bool _isPressed = false;

  IconData _getBrandIcon() {
    switch (widget.device.brand) {
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

  @override
  Widget build(BuildContext context) {
    final bgColor = NeumorphicColors.getBackground(context);
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);
    final textPrimary = NeumorphicColors.getTextPrimary(context);
    final textSecondary = NeumorphicColors.getTextSecondary(context);
    final textMuted = NeumorphicColors.getTextMuted(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isPressed
                ? null
                : [
                    BoxShadow(
                      color: shadowDark,
                      offset: const Offset(6, 6),
                      blurRadius: 12,
                    ),
                    BoxShadow(
                      color: shadowLight,
                      offset: const Offset(-6, -6),
                      blurRadius: 12,
                    ),
                  ],
          ),
          child: Row(
            children: [
              NeumorphicIconButton(
                onPressed: () {},
                icon: _getBrandIcon(),
                size: 52,
                isAccent: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.device.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.device.brand.displayName} • ${widget.device.ipAddress}',
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusIndicator(
                isConnected: widget.device.status != ConnectionStatus.error,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
