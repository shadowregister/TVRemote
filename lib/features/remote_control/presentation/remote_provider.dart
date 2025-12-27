import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../device_discovery/domain/discovered_device.dart';
import '../../device_discovery/presentation/discovery_provider.dart';
import '../../tv_brands/base_tv_controller.dart';
import '../../tv_brands/tv_controller_factory.dart';
import '../domain/remote_command.dart';

// Connection state that can be watched for changes
final connectionStateProvider = StateProvider<bool>((ref) => false);

// Holds a pre-connected controller handed off from the discovery screen
final activeControllerProvider = StateProvider<BaseTvController?>((ref) => null);

// Current TV controller
final tvControllerProvider = StateNotifierProvider<TvControllerNotifier, BaseTvController?>((ref) {
  final device = ref.watch(connectedDeviceProvider);
  return TvControllerNotifier(device, ref);
});

class TvControllerNotifier extends StateNotifier<BaseTvController?> {
  final DiscoveredDevice? _device;
  final Ref _ref;
  StreamSubscription? _connectionSubscription;

  TvControllerNotifier(this._device, this._ref) : super(null) {
    if (_device != null) {
      _initController();
    }
  }

  Future<void> _initController() async {
    if (_device == null) return;

    // Check if we have a pre-connected controller from the discovery screen
    final existingController = _ref.read(activeControllerProvider);

    if (existingController != null && existingController.isConnected) {
      // Use the existing connected controller (handoff from discovery screen)
      _connectionSubscription = existingController.connectionStream.listen((isConnected) {
        _ref.read(connectionStateProvider.notifier).state = isConnected;
      });

      _ref.read(connectionStateProvider.notifier).state = true;
      state = existingController;

      // Clear the handoff provider
      _ref.read(activeControllerProvider.notifier).state = null;
      return;
    }

    // Fallback: Create new controller (shouldn't happen with new flow)
    final controller = TvControllerFactory.createController(_device);
    if (controller != null) {
      // Listen to connection state changes
      _connectionSubscription = controller.connectionStream.listen((isConnected) {
        _ref.read(connectionStateProvider.notifier).state = isConnected;
      });

      final connected = await controller.connect();
      _ref.read(connectionStateProvider.notifier).state = connected;
      state = controller;
    }
  }

  Future<bool> sendCommand(RemoteKey key) async {
    if (state == null || !state!.isConnected) {
      // Try to reconnect if disconnected
      if (state != null && !state!.isConnected) {
        final reconnected = await state!.connect();
        if (!reconnected) return false;
        _ref.read(connectionStateProvider.notifier).state = true;
      } else {
        return false;
      }
    }
    return state!.sendCommand(key);
  }

  Future<bool> launchApp(String appId) async {
    if (state == null || !state!.isConnected) return false;
    return state!.launchApp(appId);
  }

  Future<void> disconnect() async {
    _connectionSubscription?.cancel();
    await state?.disconnect();
    _ref.read(connectionStateProvider.notifier).state = false;
    state = null;
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    state?.disconnect();
    super.dispose();
  }
}

// Connection state - now reactive!
final isConnectedProvider = Provider<bool>((ref) {
  // Watch the reactive connection state
  return ref.watch(connectionStateProvider);
});

// Paired state
final isPairedProvider = Provider<bool>((ref) {
  final controller = ref.watch(tvControllerProvider);
  return controller?.isPaired ?? false;
});
