import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tv_brands/base_tv_controller.dart';
import '../../tv_brands/tv_controller_factory.dart';
import '../domain/discovered_device.dart';
import 'discovery_provider.dart';

/// States for a connection attempt
enum ConnectionAttemptState {
  idle,
  connecting,
  connected,
  error,
  cancelled,
}

/// Represents an ongoing or completed connection attempt
class ConnectionAttempt {
  final String deviceId;
  final ConnectionAttemptState state;
  final String? errorMessage;
  final BaseTvController? controller;

  const ConnectionAttempt({
    required this.deviceId,
    required this.state,
    this.errorMessage,
    this.controller,
  });

  ConnectionAttempt copyWith({
    String? deviceId,
    ConnectionAttemptState? state,
    String? errorMessage,
    BaseTvController? controller,
  }) {
    return ConnectionAttempt(
      deviceId: deviceId ?? this.deviceId,
      state: state ?? this.state,
      errorMessage: errorMessage,
      controller: controller ?? this.controller,
    );
  }
}

/// Provider that tracks the current connection attempt
final connectionAttemptProvider =
    StateNotifierProvider<ConnectionAttemptNotifier, ConnectionAttempt?>((ref) {
  return ConnectionAttemptNotifier(ref);
});

/// Manages the connection lifecycle on the discovery screen
class ConnectionAttemptNotifier extends StateNotifier<ConnectionAttempt?> {
  final Ref _ref;
  Timer? _timeoutTimer;
  static const Duration _connectionTimeout = Duration(seconds: 15);

  ConnectionAttemptNotifier(this._ref) : super(null);

  /// Attempt to connect to a device
  /// Returns true if connection was successful, false otherwise
  Future<bool> attemptConnection(DiscoveredDevice device) async {
    // Cancel any existing attempt
    await cancelConnection();

    // Update device status to connecting in the discovered devices list
    _ref.read(discoveredDevicesProvider.notifier).updateDeviceStatus(
          device.id,
          ConnectionStatus.connecting,
        );

    // Set initial connecting state
    state = ConnectionAttempt(
      deviceId: device.id,
      state: ConnectionAttemptState.connecting,
    );

    // Start timeout timer
    _timeoutTimer = Timer(_connectionTimeout, () {
      if (state?.state == ConnectionAttemptState.connecting) {
        _handleError(device.id, 'Connection timed out');
      }
    });

    try {
      // Create the appropriate controller for this TV brand
      final controller = TvControllerFactory.createController(device);
      if (controller == null) {
        _handleError(device.id, 'Unsupported TV brand');
        return false;
      }

      // Attempt the actual connection
      final success = await controller.connect();

      _timeoutTimer?.cancel();

      // Check if cancelled while connecting
      if (state?.state == ConnectionAttemptState.cancelled) {
        await controller.disconnect();
        return false;
      }

      if (success) {
        // Update device status to connected
        _ref.read(discoveredDevicesProvider.notifier).updateDeviceStatus(
              device.id,
              ConnectionStatus.connected,
            );
        await _ref
            .read(discoveredDevicesProvider.notifier)
            .markDeviceConnected(device.id);

        // Store the connected controller for handoff to remote screen
        state = ConnectionAttempt(
          deviceId: device.id,
          state: ConnectionAttemptState.connected,
          controller: controller,
        );

        return true;
      } else {
        _handleError(device.id, 'Failed to connect to TV');
        return false;
      }
    } catch (e) {
      _timeoutTimer?.cancel();
      _handleError(device.id, e.toString());
      return false;
    }
  }

  /// Handle connection errors
  void _handleError(String deviceId, String message) {
    _ref.read(discoveredDevicesProvider.notifier).updateDeviceStatus(
          deviceId,
          ConnectionStatus.error,
        );

    state = ConnectionAttempt(
      deviceId: deviceId,
      state: ConnectionAttemptState.error,
      errorMessage: message,
    );
  }

  /// Cancel the current connection attempt
  Future<void> cancelConnection() async {
    _timeoutTimer?.cancel();

    if (state != null && state!.state == ConnectionAttemptState.connecting) {
      // Disconnect any partially connected controller
      await state?.controller?.disconnect();

      // Reset device status
      _ref.read(discoveredDevicesProvider.notifier).updateDeviceStatus(
            state!.deviceId,
            ConnectionStatus.disconnected,
          );

      state = ConnectionAttempt(
        deviceId: state!.deviceId,
        state: ConnectionAttemptState.cancelled,
      );
    }

    state = null;
  }

  /// Clear error state and reset device to disconnected
  void clearError() {
    if (state?.state == ConnectionAttemptState.error) {
      _ref.read(discoveredDevicesProvider.notifier).updateDeviceStatus(
            state!.deviceId,
            ConnectionStatus.disconnected,
          );
      state = null;
    }
  }

  /// Get the connected controller for handoff
  BaseTvController? getConnectedController() {
    if (state?.state == ConnectionAttemptState.connected) {
      return state?.controller;
    }
    return null;
  }

  /// Clear the connection attempt after handoff
  void clearAfterHandoff() {
    state = null;
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    state?.controller?.disconnect();
    super.dispose();
  }
}
