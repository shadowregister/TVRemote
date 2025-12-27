import 'dart:async';

import '../device_discovery/domain/discovered_device.dart';
import '../remote_control/domain/remote_command.dart';

abstract class BaseTvController {
  final DiscoveredDevice device;

  // Stream controller for broadcasting connection state changes
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  /// Stream that emits connection state changes
  Stream<bool> get connectionStream => _connectionController.stream;

  BaseTvController(this.device);

  /// Notify listeners of connection state change
  void notifyConnectionChange(bool isConnected) {
    if (!_connectionController.isClosed) {
      _connectionController.add(isConnected);
    }
  }

  Future<bool> connect();
  Future<void> disconnect();
  Future<bool> sendCommand(RemoteKey key);
  Future<bool> pair(String? pin);
  bool get isConnected;
  bool get isPaired;

  Future<bool> launchApp(String appId);
  Future<List<TvApp>> getInstalledApps();
  Future<TvDeviceInfo?> getDeviceInfo();

  /// Dispose resources
  void dispose() {
    _connectionController.close();
  }
}

class TvApp {
  final String id;
  final String name;
  final String? iconUrl;

  const TvApp({
    required this.id,
    required this.name,
    this.iconUrl,
  });
}

class TvDeviceInfo {
  final String name;
  final String model;
  final String firmwareVersion;
  final String? macAddress;

  const TvDeviceInfo({
    required this.name,
    required this.model,
    required this.firmwareVersion,
    this.macAddress,
  });
}
