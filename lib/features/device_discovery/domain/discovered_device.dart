import 'package:freezed_annotation/freezed_annotation.dart';

part 'discovered_device.freezed.dart';
part 'discovered_device.g.dart';

enum TvBrand {
  samsung,
  lg,
  androidTv,
  roku,
  fireTv,
  vizio,
  sony,
  unknown,
}

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  paired,
  error,
}

@freezed
class DiscoveredDevice with _$DiscoveredDevice {
  const factory DiscoveredDevice({
    required String id,
    required String name,
    required String ipAddress,
    required TvBrand brand,
    @Default(ConnectionStatus.disconnected) ConnectionStatus status,
    String? modelName,
    String? macAddress,
    int? port,
    String? authToken,
    DateTime? lastConnected,
    @Default({}) Map<String, dynamic> metadata,
  }) = _DiscoveredDevice;

  factory DiscoveredDevice.fromJson(Map<String, dynamic> json) =>
      _$DiscoveredDeviceFromJson(json);
}

extension TvBrandExtension on TvBrand {
  String get displayName {
    switch (this) {
      case TvBrand.samsung:
        return 'Samsung';
      case TvBrand.lg:
        return 'LG';
      case TvBrand.androidTv:
        return 'Android TV';
      case TvBrand.roku:
        return 'Roku';
      case TvBrand.fireTv:
        return 'Fire TV';
      case TvBrand.vizio:
        return 'Vizio';
      case TvBrand.sony:
        return 'Sony';
      case TvBrand.unknown:
        return 'Unknown';
    }
  }

  int get defaultPort {
    switch (this) {
      case TvBrand.samsung:
        return 8001;
      case TvBrand.lg:
        return 3000;
      case TvBrand.androidTv:
        return 6466;
      case TvBrand.roku:
        return 8060;
      case TvBrand.fireTv:
        return 5555;
      case TvBrand.vizio:
        return 7345;
      case TvBrand.sony:
        return 80;
      case TvBrand.unknown:
        return 0;
    }
  }
}
