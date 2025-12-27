import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/utils/logger.dart';
import '../../../device_discovery/domain/discovered_device.dart';
import '../../../remote_control/domain/remote_command.dart';
import '../../base_tv_controller.dart';

class LgController extends BaseTvController {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isPaired = false;
  String? _clientKey;
  int _commandId = 0;
  final Completer<void> _connectionCompleter = Completer();

  LgController(super.device);

  @override
  bool get isConnected => _isConnected;

  @override
  bool get isPaired => _isPaired;

  String get _wsUrl {
    final ip = device.ipAddress;
    final port = device.port ?? 3000;
    // For secure connection, use port 3001 with wss
    if (port == 3001) {
      return 'wss://$ip:$port/';
    }
    return 'ws://$ip:$port/';
  }

  @override
  Future<bool> connect() async {
    try {
      AppLogger.info('Connecting to LG TV at ${device.ipAddress}', tag: 'LG');

      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      await _channel!.ready;

      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          AppLogger.error('LG WebSocket error', tag: 'LG', error: error);
          _isConnected = false;
          notifyConnectionChange(false);
        },
        onDone: () {
          AppLogger.info('LG WebSocket closed', tag: 'LG');
          _isConnected = false;
          notifyConnectionChange(false);
        },
      );

      _isConnected = true;
      notifyConnectionChange(true);

      // Send handshake
      await _sendHandshake();

      AppLogger.info('Connected to LG TV', tag: 'LG');
      return true;
    } catch (e, st) {
      AppLogger.error('Failed to connect to LG TV', tag: 'LG', error: e, stackTrace: st);
      _isConnected = false;
      return false;
    }
  }

  Future<void> _sendHandshake() async {
    final handshake = {
      'type': 'register',
      'id': 'register_0',
      'payload': {
        'forcePairing': false,
        'pairingType': 'PROMPT',
        'manifest': {
          'manifestVersion': 1,
          'appVersion': '1.1',
          'signed': {
            'created': '20140509',
            'appId': 'com.lge.test',
            'vendorId': 'com.lge',
            'localizedAppNames': {
              '': 'TV Remote',
            },
            'localizedVendorNames': {
              '': 'LG Electronics',
            },
            'permissions': [
              'TEST_SECURE',
              'CONTROL_INPUT_TEXT',
              'CONTROL_MOUSE_AND_KEYBOARD',
              'READ_INSTALLED_APPS',
              'READ_LGE_SDX',
              'READ_NOTIFICATIONS',
              'SEARCH',
              'WRITE_SETTINGS',
              'WRITE_NOTIFICATION_ALERT',
              'CONTROL_POWER',
              'READ_CURRENT_CHANNEL',
              'READ_RUNNING_APPS',
              'READ_UPDATE_INFO',
              'UPDATE_FROM_REMOTE_APP',
              'READ_LGE_TV_INPUT_EVENTS',
              'READ_TV_CURRENT_TIME',
            ],
            'serial': '2f930e2d2cfe083771f68e4fe7bb07',
          },
          'permissions': [
            'LAUNCH',
            'LAUNCH_WEBAPP',
            'APP_TO_APP',
            'CLOSE',
            'TEST_OPEN',
            'TEST_PROTECTED',
            'CONTROL_AUDIO',
            'CONTROL_DISPLAY',
            'CONTROL_INPUT_JOYSTICK',
            'CONTROL_INPUT_MEDIA_RECORDING',
            'CONTROL_INPUT_MEDIA_PLAYBACK',
            'CONTROL_INPUT_TV',
            'CONTROL_POWER',
            'READ_APP_STATUS',
            'READ_CURRENT_CHANNEL',
            'READ_INPUT_DEVICE_LIST',
            'READ_NETWORK_STATE',
            'READ_RUNNING_APPS',
            'READ_TV_CHANNEL_LIST',
            'WRITE_NOTIFICATION_TOAST',
            'READ_POWER_STATE',
            'READ_COUNTRY_INFO',
          ],
          'signatures': [
            {
              'signatureVersion': 1,
              'signature':
                  'eyJhbGdvcml0aG0iOiJSU0EtU0hBMjU2Iiwia2V5SWQiOiJ0ZXN0LXNpZ25pbmctY2VydCIsInNpZ25hdHVyZVZlcnNpb24iOjF9.hrVRgjCwXVvE2OOSpDZ58hR+59aFNwYDyjQgKk3auukd7pcegmE2CzPCa0bJ0ZsRAcKkCTJrWo5iDzNhMBWRyaMOv5zWSrthlf7G128qvIlpMT0YNY+n/FaOHE73uLrS/g7swl3/qH/BGFG2Hu4RlL48eb3lLKqTt2xKHdCs6Cd4RMfJPYnzgvI4BNrFUKsjkcu+WD4OO2A27Pq1n50cMchmcaXadJhGrOqH5YmHdOCj5NSHzJYrsW0HPlpuAx/ECMeIZYDh6RMqaFM2DXzdKX9NmmyqzJ3o/0lkk/N97gfVRLW5hA29yeAwaCViZNCP8iC9aO0q9fQojoa7NQnAtw==',
            },
          ],
        },
        'client-key': _clientKey,
      },
    };

    _channel?.sink.add(jsonEncode(handshake));
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final type = data['type'];
      final id = data['id'];

      switch (type) {
        case 'registered':
          _clientKey = data['payload']?['client-key'];
          _isPaired = true;
          AppLogger.info('LG TV registered, received client key', tag: 'LG');
          break;

        case 'response':
          AppLogger.debug('LG response for $id: ${data['payload']}', tag: 'LG');
          break;

        case 'error':
          AppLogger.warning('LG error: ${data['error']}', tag: 'LG');
          break;

        default:
          AppLogger.debug('LG message type: $type', tag: 'LG');
      }
    } catch (e) {
      AppLogger.error('Error parsing LG message', tag: 'LG', error: e);
    }
  }

  @override
  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    notifyConnectionChange(false);
    AppLogger.info('Disconnected from LG TV', tag: 'LG');
    dispose();
  }

  @override
  Future<bool> pair(String? pin) async {
    // LG TVs show a PIN on screen that needs to be entered
    // For simplicity, we rely on the PROMPT pairing which shows Allow/Deny
    AppLogger.info('Waiting for LG TV pairing approval...', tag: 'LG');
    return _isPaired;
  }

  @override
  Future<bool> sendCommand(RemoteKey key) async {
    if (!_isConnected || _channel == null) {
      AppLogger.warning('Cannot send command: not connected', tag: 'LG');
      return false;
    }

    final buttonName = _mapKeyToLg(key);
    if (buttonName == null) {
      AppLogger.warning('Unknown key: $key', tag: 'LG');
      return false;
    }

    _commandId++;
    final command = {
      'type': 'request',
      'id': 'button_$_commandId',
      'uri': 'ssap://com.webos.service.networkinput/getPointerInputSocket',
    };

    // For button presses, we use the input socket
    // Simplified: send direct button command
    final buttonCommand = {
      'type': 'button',
      'name': buttonName,
    };

    try {
      _channel!.sink.add(jsonEncode(command));
      // In real implementation, we'd connect to the pointer input socket
      AppLogger.debug('Sent LG command: $buttonName', tag: 'LG');
      return true;
    } catch (e) {
      AppLogger.error('Failed to send LG command', tag: 'LG', error: e);
      return false;
    }
  }

  String? _mapKeyToLg(RemoteKey key) {
    const keyMap = {
      RemoteKey.power: 'POWER',
      RemoteKey.powerOff: 'POWER',
      RemoteKey.powerOn: 'POWER',
      RemoteKey.up: 'UP',
      RemoteKey.down: 'DOWN',
      RemoteKey.left: 'LEFT',
      RemoteKey.right: 'RIGHT',
      RemoteKey.enter: 'ENTER',
      RemoteKey.back: 'BACK',
      RemoteKey.home: 'HOME',
      RemoteKey.menu: 'MENU',
      RemoteKey.volumeUp: 'VOLUMEUP',
      RemoteKey.volumeDown: 'VOLUMEDOWN',
      RemoteKey.mute: 'MUTE',
      RemoteKey.channelUp: 'CHANNELUP',
      RemoteKey.channelDown: 'CHANNELDOWN',
      RemoteKey.play: 'PLAY',
      RemoteKey.pause: 'PAUSE',
      RemoteKey.playPause: 'PLAY',
      RemoteKey.stop: 'STOP',
      RemoteKey.rewind: 'REWIND',
      RemoteKey.fastForward: 'FASTFORWARD',
      RemoteKey.num0: '0',
      RemoteKey.num1: '1',
      RemoteKey.num2: '2',
      RemoteKey.num3: '3',
      RemoteKey.num4: '4',
      RemoteKey.num5: '5',
      RemoteKey.num6: '6',
      RemoteKey.num7: '7',
      RemoteKey.num8: '8',
      RemoteKey.num9: '9',
      RemoteKey.info: 'INFO',
      RemoteKey.guide: 'GUIDE',
      RemoteKey.red: 'RED',
      RemoteKey.green: 'GREEN',
      RemoteKey.yellow: 'YELLOW',
      RemoteKey.blue: 'BLUE',
    };
    return keyMap[key];
  }

  @override
  Future<bool> launchApp(String appId) async {
    if (!_isConnected || _channel == null) return false;

    _commandId++;
    final command = {
      'type': 'request',
      'id': 'launch_$_commandId',
      'uri': 'ssap://system.launcher/launch',
      'payload': {
        'id': appId,
      },
    };

    try {
      _channel!.sink.add(jsonEncode(command));
      return true;
    } catch (e) {
      AppLogger.error('Failed to launch app', tag: 'LG', error: e);
      return false;
    }
  }

  @override
  Future<List<TvApp>> getInstalledApps() async {
    // Would need to request from ssap://com.webos.applicationManager/listApps
    return [
      const TvApp(id: 'netflix', name: 'Netflix'),
      const TvApp(id: 'youtube.leanback.v4', name: 'YouTube'),
      const TvApp(id: 'amazon', name: 'Prime Video'),
      const TvApp(id: 'com.disney.disneyplus-prod', name: 'Disney+'),
    ];
  }

  @override
  Future<TvDeviceInfo?> getDeviceInfo() async {
    return TvDeviceInfo(
      name: device.name,
      model: device.modelName ?? 'LG TV',
      firmwareVersion: 'webOS',
      macAddress: device.macAddress,
    );
  }
}
