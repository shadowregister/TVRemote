import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/utils/logger.dart';
import '../../../device_discovery/domain/discovered_device.dart';
import '../../../remote_control/domain/remote_command.dart';
import '../../base_tv_controller.dart';

class RokuController extends BaseTvController {
  final Dio _dio = Dio();
  bool _isConnected = false;

  RokuController(super.device) {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    );
  }

  String get _baseUrl => 'http://${device.ipAddress}:${device.port ?? 8060}';

  @override
  bool get isConnected => _isConnected;

  @override
  bool get isPaired => true; // Roku doesn't require pairing

  @override
  Future<bool> connect() async {
    try {
      AppLogger.info('Connecting to Roku at ${device.ipAddress}', tag: 'Roku');

      // Test connection by querying device info
      final response = await _dio.get('$_baseUrl/query/device-info');
      if (response.statusCode == 200) {
        _isConnected = true;
        notifyConnectionChange(true);
        AppLogger.info('Connected to Roku', tag: 'Roku');
        return true;
      }
      return false;
    } catch (e, st) {
      AppLogger.error('Failed to connect to Roku', tag: 'Roku', error: e, stackTrace: st);
      _isConnected = false;
      notifyConnectionChange(false);
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    notifyConnectionChange(false);
    AppLogger.info('Disconnected from Roku', tag: 'Roku');
    dispose();
  }

  @override
  Future<bool> pair(String? pin) async {
    // Roku ECP doesn't require pairing
    return true;
  }

  @override
  Future<bool> sendCommand(RemoteKey key) async {
    if (!_isConnected) {
      AppLogger.warning('Cannot send command: not connected', tag: 'Roku');
      return false;
    }

    final keyCode = _mapKeyToRoku(key);
    if (keyCode == null) {
      AppLogger.warning('Unknown key: $key', tag: 'Roku');
      return false;
    }

    try {
      await _dio.post('$_baseUrl/keypress/$keyCode');
      AppLogger.debug('Sent Roku command: $keyCode', tag: 'Roku');
      return true;
    } catch (e) {
      AppLogger.error('Failed to send Roku command', tag: 'Roku', error: e);
      // Mark as disconnected on connection errors
      _isConnected = false;
      notifyConnectionChange(false);
      return false;
    }
  }

  String? _mapKeyToRoku(RemoteKey key) {
    const keyMap = {
      RemoteKey.power: 'Power',
      RemoteKey.powerOff: 'PowerOff',
      RemoteKey.powerOn: 'PowerOn',
      RemoteKey.up: 'Up',
      RemoteKey.down: 'Down',
      RemoteKey.left: 'Left',
      RemoteKey.right: 'Right',
      RemoteKey.enter: 'Select',
      RemoteKey.back: 'Back',
      RemoteKey.home: 'Home',
      RemoteKey.menu: 'Info',
      RemoteKey.volumeUp: 'VolumeUp',
      RemoteKey.volumeDown: 'VolumeDown',
      RemoteKey.mute: 'VolumeMute',
      RemoteKey.channelUp: 'ChannelUp',
      RemoteKey.channelDown: 'ChannelDown',
      RemoteKey.play: 'Play',
      RemoteKey.pause: 'Play', // Roku uses Play for toggle
      RemoteKey.playPause: 'Play',
      RemoteKey.stop: 'Play',
      RemoteKey.rewind: 'Rev',
      RemoteKey.fastForward: 'Fwd',
      RemoteKey.previous: 'InstantReplay',
      RemoteKey.info: 'Info',
      RemoteKey.search: 'Search',
      RemoteKey.settings: 'Info',
    };
    return keyMap[key];
  }

  @override
  Future<bool> launchApp(String appId) async {
    if (!_isConnected) return false;

    try {
      await _dio.post('$_baseUrl/launch/$appId');
      AppLogger.info('Launched Roku app: $appId', tag: 'Roku');
      return true;
    } catch (e) {
      AppLogger.error('Failed to launch Roku app', tag: 'Roku', error: e);
      return false;
    }
  }

  @override
  Future<List<TvApp>> getInstalledApps() async {
    if (!_isConnected) return [];

    try {
      final response = await _dio.get('$_baseUrl/query/apps');
      if (response.statusCode == 200) {
        // Parse XML response
        final apps = <TvApp>[];
        // Simplified parsing - in production use XML parser
        final data = response.data.toString();
        final regex = RegExp(r'<app id="(\d+)"[^>]*>([^<]+)</app>');
        for (final match in regex.allMatches(data)) {
          apps.add(TvApp(
            id: match.group(1)!,
            name: match.group(2)!,
          ));
        }
        return apps;
      }
    } catch (e) {
      AppLogger.error('Failed to get Roku apps', tag: 'Roku', error: e);
    }
    return [
      const TvApp(id: '12', name: 'Netflix'),
      const TvApp(id: '837', name: 'YouTube'),
      const TvApp(id: '13', name: 'Prime Video'),
      const TvApp(id: '291097', name: 'Disney+'),
    ];
  }

  @override
  Future<TvDeviceInfo?> getDeviceInfo() async {
    if (!_isConnected) return null;

    try {
      final response = await _dio.get('$_baseUrl/query/device-info');
      if (response.statusCode == 200) {
        final data = response.data.toString();
        // Parse XML
        String? extractValue(String tag) {
          final regex = RegExp('<$tag>([^<]+)</$tag>');
          return regex.firstMatch(data)?.group(1);
        }

        return TvDeviceInfo(
          name: extractValue('friendly-device-name') ?? 'Roku',
          model: extractValue('model-name') ?? 'Unknown',
          firmwareVersion: extractValue('software-version') ?? 'Unknown',
          macAddress: extractValue('wifi-mac'),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to get Roku device info', tag: 'Roku', error: e);
    }

    return TvDeviceInfo(
      name: device.name,
      model: device.modelName ?? 'Roku',
      firmwareVersion: 'Unknown',
    );
  }
}
