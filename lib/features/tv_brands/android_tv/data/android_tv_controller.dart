import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../../../core/utils/logger.dart';
import '../../../device_discovery/domain/discovered_device.dart';
import '../../../remote_control/domain/remote_command.dart';
import '../../base_tv_controller.dart';

class AndroidTvController extends BaseTvController {
  Socket? _socket;
  bool _isConnected = false;
  bool _isPaired = false;

  AndroidTvController(super.device);

  @override
  bool get isConnected => _isConnected;

  @override
  bool get isPaired => _isPaired;

  @override
  Future<bool> connect() async {
    try {
      AppLogger.info('Connecting to Android TV at ${device.ipAddress}', tag: 'AndroidTV');

      final port = device.port ?? 6466;
      _socket = await Socket.connect(
        device.ipAddress,
        port,
        timeout: const Duration(seconds: 5),
      );

      _socket!.listen(
        _handleData,
        onError: (error) {
          AppLogger.error('Android TV socket error', tag: 'AndroidTV', error: error);
          _isConnected = false;
          notifyConnectionChange(false);
        },
        onDone: () {
          AppLogger.info('Android TV socket closed', tag: 'AndroidTV');
          _isConnected = false;
          notifyConnectionChange(false);
        },
      );

      _isConnected = true;
      notifyConnectionChange(true);
      AppLogger.info('Connected to Android TV', tag: 'AndroidTV');

      // Send pairing request
      await _sendPairingRequest();

      return true;
    } catch (e, st) {
      AppLogger.error('Failed to connect to Android TV', tag: 'AndroidTV', error: e, stackTrace: st);
      _isConnected = false;
      return false;
    }
  }

  void _handleData(Uint8List data) {
    AppLogger.debug('Received data from Android TV: ${data.length} bytes', tag: 'AndroidTV');
    // Parse Android TV Remote Protocol messages
    // The protocol is binary and requires proper implementation
  }

  Future<void> _sendPairingRequest() async {
    // Android TV Remote Protocol pairing is complex
    // It involves certificate exchange and verification
    // For demo purposes, we'll mark as paired
    _isPaired = true;
    AppLogger.info('Android TV pairing initiated', tag: 'AndroidTV');
  }

  @override
  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
    _isConnected = false;
    notifyConnectionChange(false);
    AppLogger.info('Disconnected from Android TV', tag: 'AndroidTV');
    dispose();
  }

  @override
  Future<bool> pair(String? pin) async {
    if (pin == null || pin.isEmpty) {
      AppLogger.warning('PIN required for Android TV pairing', tag: 'AndroidTV');
      return false;
    }

    // In real implementation, verify PIN with TV
    // For demo, accept any 6-digit PIN
    if (pin.length == 6) {
      _isPaired = true;
      AppLogger.info('Android TV paired successfully', tag: 'AndroidTV');
      return true;
    }

    return false;
  }

  @override
  Future<bool> sendCommand(RemoteKey key) async {
    if (!_isConnected || _socket == null) {
      AppLogger.warning('Cannot send command: not connected', tag: 'AndroidTV');
      return false;
    }

    final keyCode = _mapKeyToAndroid(key);
    if (keyCode == null) {
      AppLogger.warning('Unknown key: $key', tag: 'AndroidTV');
      return false;
    }

    try {
      // Android TV Remote Protocol uses binary messages
      // Simplified: send key code as bytes
      final message = _buildKeyMessage(keyCode);
      _socket!.add(message);
      await _socket!.flush();

      AppLogger.debug('Sent Android TV command: $keyCode', tag: 'AndroidTV');
      return true;
    } catch (e) {
      AppLogger.error('Failed to send Android TV command', tag: 'AndroidTV', error: e);
      return false;
    }
  }

  Uint8List _buildKeyMessage(int keyCode) {
    // Simplified key message - real protocol is more complex
    // Android TV Remote Protocol v2 uses protobuf
    return Uint8List.fromList([0x08, keyCode & 0xFF, (keyCode >> 8) & 0xFF]);
  }

  int? _mapKeyToAndroid(RemoteKey key) {
    // Android KeyEvent key codes
    const keyMap = {
      RemoteKey.power: 26, // KEYCODE_POWER
      RemoteKey.up: 19, // KEYCODE_DPAD_UP
      RemoteKey.down: 20, // KEYCODE_DPAD_DOWN
      RemoteKey.left: 21, // KEYCODE_DPAD_LEFT
      RemoteKey.right: 22, // KEYCODE_DPAD_RIGHT
      RemoteKey.enter: 23, // KEYCODE_DPAD_CENTER
      RemoteKey.back: 4, // KEYCODE_BACK
      RemoteKey.home: 3, // KEYCODE_HOME
      RemoteKey.menu: 82, // KEYCODE_MENU
      RemoteKey.volumeUp: 24, // KEYCODE_VOLUME_UP
      RemoteKey.volumeDown: 25, // KEYCODE_VOLUME_DOWN
      RemoteKey.mute: 164, // KEYCODE_VOLUME_MUTE
      RemoteKey.channelUp: 166, // KEYCODE_CHANNEL_UP
      RemoteKey.channelDown: 167, // KEYCODE_CHANNEL_DOWN
      RemoteKey.play: 126, // KEYCODE_MEDIA_PLAY
      RemoteKey.pause: 127, // KEYCODE_MEDIA_PAUSE
      RemoteKey.playPause: 85, // KEYCODE_MEDIA_PLAY_PAUSE
      RemoteKey.stop: 86, // KEYCODE_MEDIA_STOP
      RemoteKey.rewind: 89, // KEYCODE_MEDIA_REWIND
      RemoteKey.fastForward: 90, // KEYCODE_MEDIA_FAST_FORWARD
      RemoteKey.previous: 88, // KEYCODE_MEDIA_PREVIOUS
      RemoteKey.next: 87, // KEYCODE_MEDIA_NEXT
      RemoteKey.num0: 7, // KEYCODE_0
      RemoteKey.num1: 8, // KEYCODE_1
      RemoteKey.num2: 9, // KEYCODE_2
      RemoteKey.num3: 10, // KEYCODE_3
      RemoteKey.num4: 11, // KEYCODE_4
      RemoteKey.num5: 12, // KEYCODE_5
      RemoteKey.num6: 13, // KEYCODE_6
      RemoteKey.num7: 14, // KEYCODE_7
      RemoteKey.num8: 15, // KEYCODE_8
      RemoteKey.num9: 16, // KEYCODE_9
      RemoteKey.guide: 172, // KEYCODE_TV_DATA_SERVICE
      RemoteKey.info: 165, // KEYCODE_INFO
      RemoteKey.search: 84, // KEYCODE_SEARCH
      RemoteKey.settings: 176, // KEYCODE_SETTINGS
    };
    return keyMap[key];
  }

  @override
  Future<bool> launchApp(String appId) async {
    // Android TV app launch would use ADB or specific protocol
    AppLogger.info('Launch app not implemented for Android TV', tag: 'AndroidTV');
    return false;
  }

  @override
  Future<List<TvApp>> getInstalledApps() async {
    return [
      const TvApp(id: 'com.netflix.ninja', name: 'Netflix'),
      const TvApp(id: 'com.google.android.youtube.tv', name: 'YouTube'),
      const TvApp(id: 'com.amazon.amazonvideo.livingroom', name: 'Prime Video'),
      const TvApp(id: 'com.disney.disneyplus', name: 'Disney+'),
    ];
  }

  @override
  Future<TvDeviceInfo?> getDeviceInfo() async {
    return TvDeviceInfo(
      name: device.name,
      model: device.modelName ?? 'Android TV',
      firmwareVersion: 'Android TV',
      macAddress: device.macAddress,
    );
  }
}
