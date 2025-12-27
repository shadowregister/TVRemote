import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/device_scanner.dart';
import '../../../core/constants/app_constants.dart';
import '../../../main.dart';
import '../domain/discovered_device.dart';

// Device scanner singleton
final deviceScannerProvider = Provider<DeviceScanner>((ref) {
  final scanner = DeviceScanner();
  ref.onDispose(() => scanner.dispose());
  return scanner;
});

// Scanning state
final isScanningProvider = StateProvider<bool>((ref) => false);

// Discovered devices state
class DiscoveredDevicesNotifier extends StateNotifier<List<DiscoveredDevice>> {
  final DeviceScanner _scanner;
  final SharedPreferences _prefs;
  StreamSubscription? _subscription;

  DiscoveredDevicesNotifier(this._scanner, this._prefs) : super([]) {
    _loadSavedDevices();
  }

  void _loadSavedDevices() {
    try {
      final savedJson = _prefs.getStringList(StorageKeys.savedDevices);
      if (savedJson != null && savedJson.isNotEmpty) {
        final devices = savedJson.map((jsonStr) {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          return DiscoveredDevice.fromJson(json);
        }).toList();
        // Mark saved devices as disconnected initially (will update when scanned)
        state = devices.map((d) => d.copyWith(status: ConnectionStatus.disconnected)).toList();
        debugPrint('Loaded ${devices.length} saved devices');
      }
    } catch (e) {
      debugPrint('Error loading saved devices: $e');
    }
  }

  Future<void> _saveDevices() async {
    try {
      // Only save devices that have been connected or manually added
      final devicesToSave = state.where((d) =>
        d.status == ConnectionStatus.paired ||
        d.status == ConnectionStatus.connected ||
        d.authToken != null ||
        d.lastConnected != null
      ).toList();

      // Also include devices that were previously saved (even if currently disconnected)
      final allToSave = state.where((d) {
        // Save if it has auth info or was manually added or has been connected before
        return d.authToken != null || d.lastConnected != null;
      }).toList();

      final jsonList = allToSave.map((d) => jsonEncode(d.toJson())).toList();
      await _prefs.setStringList(StorageKeys.savedDevices, jsonList);
      debugPrint('Saved ${allToSave.length} devices');
    } catch (e) {
      debugPrint('Error saving devices: $e');
    }
  }

  Future<void> startScan() async {
    // Keep saved devices, mark them as disconnected for re-discovery
    final savedDevices = state.map((d) => d.copyWith(status: ConnectionStatus.disconnected)).toList();
    state = savedDevices;

    _subscription?.cancel();
    _subscription = _scanner.deviceStream.listen((device) {
      _mergeDevice(device);
    });
    await _scanner.startScan();
  }

  void _mergeDevice(DiscoveredDevice scannedDevice) {
    final existingIndex = state.indexWhere((d) =>
      d.id == scannedDevice.id ||
      d.ipAddress == scannedDevice.ipAddress
    );

    if (existingIndex >= 0) {
      // Update existing device with fresh info but keep auth token and last connected
      final existing = state[existingIndex];
      final updated = scannedDevice.copyWith(
        authToken: existing.authToken,
        lastConnected: existing.lastConnected,
        status: existing.authToken != null ? ConnectionStatus.paired : ConnectionStatus.disconnected,
      );
      state = [
        ...state.sublist(0, existingIndex),
        updated,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // Add new device
      state = [...state, scannedDevice];
    }
  }

  Future<void> stopScan() async {
    await _scanner.stopScan();
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> addManualDevice(String ip, TvBrand brand) async {
    await _scanner.addManualDevice(ip, brand);
    // Manual devices should be saved
    final device = DiscoveredDevice(
      id: '${brand.name}_$ip',
      name: '${brand.displayName} TV',
      ipAddress: ip,
      brand: brand,
      port: brand.defaultPort,
      lastConnected: DateTime.now(), // Mark as "touched" so it gets saved
    );
    _mergeDevice(device);
    await _saveDevices();
  }

  void updateDeviceStatus(String deviceId, ConnectionStatus status) {
    state = state.map((d) {
      if (d.id == deviceId) {
        return d.copyWith(status: status);
      }
      return d;
    }).toList();

    // Save when device becomes connected or paired
    if (status == ConnectionStatus.connected || status == ConnectionStatus.paired) {
      _saveDevices();
    }
  }

  void updateDeviceWithToken(String deviceId, String token) {
    state = state.map((d) {
      if (d.id == deviceId) {
        return d.copyWith(
          authToken: token,
          status: ConnectionStatus.paired,
          lastConnected: DateTime.now(),
        );
      }
      return d;
    }).toList();
    // Save when device is paired with token
    _saveDevices();
  }

  /// Save current device as connected (call after successful connection)
  Future<void> markDeviceConnected(String deviceId) async {
    state = state.map((d) {
      if (d.id == deviceId) {
        return d.copyWith(
          status: ConnectionStatus.connected,
          lastConnected: DateTime.now(),
        );
      }
      return d;
    }).toList();
    await _saveDevices();

    // Also save as last connected device
    await _prefs.setString(StorageKeys.lastConnectedDevice, deviceId);
  }

  /// Remove a saved device
  Future<void> removeDevice(String deviceId) async {
    state = state.where((d) => d.id != deviceId).toList();
    await _saveDevices();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final discoveredDevicesProvider =
    StateNotifierProvider<DiscoveredDevicesNotifier, List<DiscoveredDevice>>((ref) {
  final scanner = ref.watch(deviceScannerProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return DiscoveredDevicesNotifier(scanner, prefs);
});

// Currently connected device
final connectedDeviceProvider = StateProvider<DiscoveredDevice?>((ref) => null);

// Last connected device ID for auto-connect
final lastConnectedDeviceIdProvider = Provider<String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString(StorageKeys.lastConnectedDevice);
});
