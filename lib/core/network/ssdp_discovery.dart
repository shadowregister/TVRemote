import 'dart:async';
import 'dart:io';

import '../utils/logger.dart';
import '../../features/device_discovery/domain/discovered_device.dart';

class SsdpDiscovery {
  static const String _ssdpAddress = '239.255.255.250';
  static const int _ssdpPort = 1900;
  static const Duration _timeout = Duration(seconds: 5);

  RawDatagramSocket? _socket;
  final StreamController<DiscoveredDevice> _deviceController =
      StreamController<DiscoveredDevice>.broadcast();

  Stream<DiscoveredDevice> get deviceStream => _deviceController.stream;

  // SSDP M-SEARCH message templates for different TV types
  static const Map<String, String> _searchTargets = {
    'samsung': 'urn:samsung.com:device:RemoteControlReceiver:1',
    'lg': 'urn:lge-com:service:webos-second-screen:1',
    'roku': 'roku:ecp',
    'dial': 'urn:dial-multiscreen-org:service:dial:1',
    'upnp': 'ssdp:all',
  };

  String _buildSearchMessage(String searchTarget) {
    return 'M-SEARCH * HTTP/1.1\r\n'
        'HOST: $_ssdpAddress:$_ssdpPort\r\n'
        'MAN: "ssdp:discover"\r\n'
        'MX: 3\r\n'
        'ST: $searchTarget\r\n'
        '\r\n';
  }

  Future<void> startDiscovery() async {
    AppLogger.info('Starting SSDP discovery...', tag: 'SsdpDiscovery');

    try {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
        reuseAddress: true,
        reusePort: true,
      );

      _socket!.broadcastEnabled = true;
      _socket!.multicastHops = 4;

      _socket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          if (datagram != null) {
            _handleResponse(datagram);
          }
        }
      });

      // Send discovery requests for all targets
      for (final entry in _searchTargets.entries) {
        final message = _buildSearchMessage(entry.value);
        _socket!.send(
          message.codeUnits,
          InternetAddress(_ssdpAddress),
          _ssdpPort,
        );
        AppLogger.debug('Sent SSDP search for ${entry.key}', tag: 'SsdpDiscovery');
      }

      // Auto-close after timeout
      Timer(_timeout, () {
        if (!_deviceController.isClosed) {
          AppLogger.info('SSDP discovery timeout', tag: 'SsdpDiscovery');
        }
      });
    } catch (e, st) {
      AppLogger.error('SSDP discovery error', tag: 'SsdpDiscovery', error: e, stackTrace: st);
    }
  }

  void _handleResponse(Datagram datagram) {
    final response = String.fromCharCodes(datagram.data);
    final address = datagram.address.address;

    AppLogger.debug('SSDP response from $address', tag: 'SsdpDiscovery');

    final device = _parseResponse(response, address);
    if (device != null) {
      _deviceController.add(device);
    }
  }

  DiscoveredDevice? _parseResponse(String response, String address) {
    final headers = _parseHeaders(response);
    final server = headers['server'] ?? headers['SERVER'] ?? '';
    final location = headers['location'] ?? headers['LOCATION'] ?? '';
    final usn = headers['usn'] ?? headers['USN'] ?? '';

    TvBrand brand = TvBrand.unknown;
    String name = 'Unknown TV';

    // Detect brand from response
    final responseLower = response.toLowerCase();

    if (responseLower.contains('samsung') || responseLower.contains('tizen')) {
      brand = TvBrand.samsung;
      name = 'Samsung TV';
    } else if (responseLower.contains('lg') || responseLower.contains('webos')) {
      brand = TvBrand.lg;
      name = 'LG TV';
    } else if (responseLower.contains('roku')) {
      brand = TvBrand.roku;
      name = 'Roku';
    } else if (responseLower.contains('amazon') || responseLower.contains('fire')) {
      brand = TvBrand.fireTv;
      name = 'Fire TV';
    } else if (responseLower.contains('vizio') || responseLower.contains('smartcast')) {
      brand = TvBrand.vizio;
      name = 'Vizio TV';
    } else if (responseLower.contains('sony') || responseLower.contains('bravia')) {
      brand = TvBrand.sony;
      name = 'Sony TV';
    } else if (responseLower.contains('android') || responseLower.contains('google')) {
      brand = TvBrand.androidTv;
      name = 'Android TV';
    } else {
      // Not a TV we support, skip
      return null;
    }

    // Extract model name if available
    String? modelName;
    final modelMatch = RegExp(r'model[:\s]*([^\r\n]+)', caseSensitive: false).firstMatch(response);
    if (modelMatch != null) {
      modelName = modelMatch.group(1)?.trim();
    }

    return DiscoveredDevice(
      id: '$address-${brand.name}',
      name: name,
      ipAddress: address,
      brand: brand,
      port: brand.defaultPort,
      modelName: modelName,
      metadata: {
        'server': server,
        'location': location,
        'usn': usn,
      },
    );
  }

  Map<String, String> _parseHeaders(String response) {
    final headers = <String, String>{};
    final lines = response.split('\r\n');

    for (final line in lines) {
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        final key = line.substring(0, colonIndex).trim();
        final value = line.substring(colonIndex + 1).trim();
        headers[key] = value;
      }
    }

    return headers;
  }

  Future<void> stopDiscovery() async {
    _socket?.close();
    _socket = null;
    AppLogger.info('SSDP discovery stopped', tag: 'SsdpDiscovery');
  }

  void dispose() {
    stopDiscovery();
    _deviceController.close();
  }
}
