import 'dart:async';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../utils/logger.dart';
import '../../features/device_discovery/domain/discovered_device.dart';
import 'ssdp_discovery.dart';

class DeviceScanner {
  final SsdpDiscovery _ssdpDiscovery = SsdpDiscovery();
  final NetworkInfo _networkInfo = NetworkInfo();

  BonsoirDiscovery? _bonsoirDiscovery;
  final StreamController<DiscoveredDevice> _deviceController =
      StreamController<DiscoveredDevice>.broadcast();
  final Set<String> _discoveredIds = {};
  final List<DiscoveredDevice> _devices = [];

  Stream<DiscoveredDevice> get deviceStream => _deviceController.stream;
  List<DiscoveredDevice> get devices => List.unmodifiable(_devices);

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  Future<String?> getLocalIpAddress() async {
    try {
      return await _networkInfo.getWifiIP();
    } catch (e) {
      AppLogger.error('Failed to get WiFi IP', tag: 'DeviceScanner', error: e);
      return null;
    }
  }

  Future<void> startScan() async {
    if (_isScanning) return;

    _isScanning = true;
    _discoveredIds.clear();
    _devices.clear();

    AppLogger.info('Starting device scan...', tag: 'DeviceScanner');

    // Start SSDP discovery
    _ssdpDiscovery.deviceStream.listen(_onDeviceFound);
    await _ssdpDiscovery.startDiscovery();

    // Start mDNS discovery for Android TV
    await _startMdnsDiscovery();

    // Also do a port scan for common TV ports
    final localIp = await getLocalIpAddress();
    if (localIp != null) {
      _scanLocalNetwork(localIp);
    }
  }

  Future<void> _startMdnsDiscovery() async {
    try {
      // Look for Android TV Remote service
      _bonsoirDiscovery = BonsoirDiscovery(type: '_androidtvremote2._tcp');

      await _bonsoirDiscovery!.ready;
      _bonsoirDiscovery!.eventStream?.listen((event) {
        if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
          final service = event.service as ResolvedBonsoirService;
          final ip = service.host;
          if (ip != null) {
            final device = DiscoveredDevice(
              id: '$ip-androidtv',
              name: service.name,
              ipAddress: ip,
              brand: TvBrand.androidTv,
              port: service.port,
              metadata: {'txt': service.attributes},
            );
            _onDeviceFound(device);
          }
        }
      });

      await _bonsoirDiscovery!.start();
      AppLogger.info('mDNS discovery started', tag: 'DeviceScanner');
    } catch (e) {
      AppLogger.error('mDNS discovery error', tag: 'DeviceScanner', error: e);
    }
  }

  Future<void> _scanLocalNetwork(String localIp) async {
    // Extract subnet from local IP
    final parts = localIp.split('.');
    if (parts.length != 4) return;

    final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
    AppLogger.info('Scanning subnet $subnet.*', tag: 'DeviceScanner');

    // Scan common TV ports on the local network
    final tvPorts = [
      (8001, TvBrand.samsung),
      (8002, TvBrand.samsung),
      (3000, TvBrand.lg),
      (3001, TvBrand.lg),
      (8060, TvBrand.roku),
      (7345, TvBrand.vizio),
      (9000, TvBrand.vizio),
    ];

    // Parallel port scanning (limited concurrency)
    const batchSize = 20;
    for (var i = 1; i < 255; i += batchSize) {
      final futures = <Future>[];
      for (var j = i; j < i + batchSize && j < 255; j++) {
        final ip = '$subnet.$j';
        if (ip == localIp) continue;

        for (final (port, brand) in tvPorts) {
          futures.add(_checkPort(ip, port, brand));
        }
      }
      await Future.wait(futures);
    }
  }

  Future<void> _checkPort(String ip, int port, TvBrand brand) async {
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(milliseconds: 300),
      );
      socket.destroy();

      // Port is open, this might be a TV
      final device = DiscoveredDevice(
        id: '$ip-${brand.name}',
        name: '${brand.displayName} (${ip.split('.').last})',
        ipAddress: ip,
        brand: brand,
        port: port,
      );
      _onDeviceFound(device);
    } catch (_) {
      // Port closed or timeout, ignore
    }
  }

  void _onDeviceFound(DiscoveredDevice device) {
    if (_discoveredIds.contains(device.id)) return;

    _discoveredIds.add(device.id);
    _devices.add(device);
    _deviceController.add(device);

    AppLogger.info(
      'Found device: ${device.name} (${device.ipAddress}) - ${device.brand.displayName}',
      tag: 'DeviceScanner',
    );
  }

  Future<void> addManualDevice(String ipAddress, TvBrand brand) async {
    final device = DiscoveredDevice(
      id: '$ipAddress-${brand.name}-manual',
      name: '${brand.displayName} (Manual)',
      ipAddress: ipAddress,
      brand: brand,
      port: brand.defaultPort,
    );
    _onDeviceFound(device);
  }

  Future<void> stopScan() async {
    _isScanning = false;
    await _ssdpDiscovery.stopDiscovery();
    await _bonsoirDiscovery?.stop();
    _bonsoirDiscovery = null;
    AppLogger.info('Device scan stopped', tag: 'DeviceScanner');
  }

  void dispose() {
    stopScan();
    _ssdpDiscovery.dispose();
    _deviceController.close();
  }
}
