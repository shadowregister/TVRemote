import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/utils/logger.dart';
import '../../../device_discovery/domain/discovered_device.dart';
import '../../../remote_control/domain/remote_command.dart';
import '../../base_tv_controller.dart';

class SamsungController extends BaseTvController {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isPaired = false;
  String? _token;

  // Samsung uses app name for identification
  static const String _appName = 'TVRemote';
  static final String _appNameEncoded = base64Encode(utf8.encode(_appName));

  SamsungController(super.device);

  @override
  bool get isConnected => _isConnected;

  @override
  bool get isPaired => _isPaired;

  String get _wsUrl {
    final ip = device.ipAddress;
    final port = device.port ?? 8001;
    // For secure connection (newer TVs), use port 8002 with wss
    if (port == 8002) {
      return 'wss://$ip:$port/api/v2/channels/samsung.remote.control?name=$_appNameEncoded';
    }
    return 'ws://$ip:$port/api/v2/channels/samsung.remote.control?name=$_appNameEncoded';
  }

  @override
  Future<bool> connect() async {
    try {
      AppLogger.info('Connecting to Samsung TV at ${device.ipAddress}', tag: 'Samsung');

      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

      // Wait for connection
      await _channel!.ready;

      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          AppLogger.error('Samsung WebSocket error', tag: 'Samsung', error: error);
          _isConnected = false;
          notifyConnectionChange(false);
        },
        onDone: () {
          AppLogger.info('Samsung WebSocket closed', tag: 'Samsung');
          _isConnected = false;
          notifyConnectionChange(false);
        },
      );

      _isConnected = true;
      notifyConnectionChange(true);
      AppLogger.info('Connected to Samsung TV', tag: 'Samsung');
      return true;
    } catch (e, st) {
      AppLogger.error('Failed to connect to Samsung TV', tag: 'Samsung', error: e, stackTrace: st);
      _isConnected = false;
      return false;
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final event = data['event'];

      switch (event) {
        case 'ms.channel.connect':
          AppLogger.info('Samsung TV connected successfully', tag: 'Samsung');
          // Check if we received a token
          if (data['data']?['token'] != null) {
            _token = data['data']['token'];
            _isPaired = true;
            AppLogger.info('Received pairing token', tag: 'Samsung');
          }
          break;

        case 'ms.channel.clientConnect':
          AppLogger.info('Client connected to Samsung TV', tag: 'Samsung');
          break;

        case 'ms.channel.clientDisconnect':
          AppLogger.info('Client disconnected from Samsung TV', tag: 'Samsung');
          _isConnected = false;
          notifyConnectionChange(false);
          break;

        case 'ms.error':
          AppLogger.warning('Samsung TV error: ${data['data']}', tag: 'Samsung');
          break;

        default:
          AppLogger.debug('Samsung event: $event', tag: 'Samsung');
      }
    } catch (e) {
      AppLogger.error('Error parsing Samsung message', tag: 'Samsung', error: e);
    }
  }

  @override
  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    notifyConnectionChange(false);
    AppLogger.info('Disconnected from Samsung TV', tag: 'Samsung');
    dispose();
  }

  @override
  Future<bool> pair(String? pin) async {
    // Samsung TVs auto-pair when connected, TV shows allow/deny prompt
    // After user accepts, we receive a token
    AppLogger.info('Waiting for Samsung TV pairing approval...', tag: 'Samsung');
    return _isPaired;
  }

  @override
  Future<bool> sendCommand(RemoteKey key) async {
    if (!_isConnected || _channel == null) {
      AppLogger.warning('Cannot send command: not connected', tag: 'Samsung');
      return false;
    }

    final keyCode = _mapKeyToSamsung(key);
    if (keyCode == null) {
      AppLogger.warning('Unknown key: $key', tag: 'Samsung');
      return false;
    }

    final command = {
      'method': 'ms.remote.control',
      'params': {
        'Cmd': 'Click',
        'DataOfCmd': keyCode,
        'Option': 'false',
        'TypeOfRemote': 'SendRemoteKey',
      },
    };

    try {
      _channel!.sink.add(jsonEncode(command));
      AppLogger.debug('Sent Samsung command: $keyCode', tag: 'Samsung');
      return true;
    } catch (e) {
      AppLogger.error('Failed to send Samsung command', tag: 'Samsung', error: e);
      return false;
    }
  }

  String? _mapKeyToSamsung(RemoteKey key) {
    const keyMap = {
      RemoteKey.power: 'KEY_POWER',
      RemoteKey.powerOff: 'KEY_POWEROFF',
      RemoteKey.powerOn: 'KEY_POWERON',
      RemoteKey.up: 'KEY_UP',
      RemoteKey.down: 'KEY_DOWN',
      RemoteKey.left: 'KEY_LEFT',
      RemoteKey.right: 'KEY_RIGHT',
      RemoteKey.enter: 'KEY_ENTER',
      RemoteKey.back: 'KEY_RETURN',
      RemoteKey.home: 'KEY_HOME',
      RemoteKey.menu: 'KEY_MENU',
      RemoteKey.volumeUp: 'KEY_VOLUP',
      RemoteKey.volumeDown: 'KEY_VOLDOWN',
      RemoteKey.mute: 'KEY_MUTE',
      RemoteKey.channelUp: 'KEY_CHUP',
      RemoteKey.channelDown: 'KEY_CHDOWN',
      RemoteKey.play: 'KEY_PLAY',
      RemoteKey.pause: 'KEY_PAUSE',
      RemoteKey.playPause: 'KEY_PLAY',
      RemoteKey.stop: 'KEY_STOP',
      RemoteKey.rewind: 'KEY_REWIND',
      RemoteKey.fastForward: 'KEY_FF',
      RemoteKey.previous: 'KEY_REWIND_',
      RemoteKey.next: 'KEY_FF_',
      RemoteKey.num0: 'KEY_0',
      RemoteKey.num1: 'KEY_1',
      RemoteKey.num2: 'KEY_2',
      RemoteKey.num3: 'KEY_3',
      RemoteKey.num4: 'KEY_4',
      RemoteKey.num5: 'KEY_5',
      RemoteKey.num6: 'KEY_6',
      RemoteKey.num7: 'KEY_7',
      RemoteKey.num8: 'KEY_8',
      RemoteKey.num9: 'KEY_9',
      RemoteKey.source: 'KEY_SOURCE',
      RemoteKey.input: 'KEY_SOURCE',
      RemoteKey.info: 'KEY_INFO',
      RemoteKey.guide: 'KEY_GUIDE',
      RemoteKey.red: 'KEY_RED',
      RemoteKey.green: 'KEY_GREEN',
      RemoteKey.yellow: 'KEY_YELLOW',
      RemoteKey.blue: 'KEY_BLUE',
      RemoteKey.settings: 'KEY_MENU',
    };
    return keyMap[key];
  }

  @override
  Future<bool> launchApp(String appId) async {
    if (!_isConnected || _channel == null) return false;

    final command = {
      'method': 'ms.channel.emit',
      'params': {
        'event': 'ed.apps.launch',
        'to': 'host',
        'data': {
          'appId': appId,
          'action_type': 'DEEP_LINK',
        },
      },
    };

    try {
      _channel!.sink.add(jsonEncode(command));
      return true;
    } catch (e) {
      AppLogger.error('Failed to launch app', tag: 'Samsung', error: e);
      return false;
    }
  }

  @override
  Future<List<TvApp>> getInstalledApps() async {
    // Samsung TV apps list requires HTTP request to different endpoint
    // For now, return common apps
    return [
      const TvApp(id: 'Netflix', name: 'Netflix'),
      const TvApp(id: 'YouTube', name: 'YouTube'),
      const TvApp(id: 'Amazon', name: 'Prime Video'),
      const TvApp(id: 'Disney', name: 'Disney+'),
    ];
  }

  @override
  Future<TvDeviceInfo?> getDeviceInfo() async {
    // Device info available through HTTP API
    return TvDeviceInfo(
      name: device.name,
      model: device.modelName ?? 'Samsung TV',
      firmwareVersion: 'Unknown',
      macAddress: device.macAddress,
    );
  }
}
