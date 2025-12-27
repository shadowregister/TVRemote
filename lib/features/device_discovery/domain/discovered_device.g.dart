// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovered_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiscoveredDeviceImpl _$$DiscoveredDeviceImplFromJson(
        Map<String, dynamic> json) =>
    _$DiscoveredDeviceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String,
      brand: $enumDecode(_$TvBrandEnumMap, json['brand']),
      status: $enumDecodeNullable(_$ConnectionStatusEnumMap, json['status']) ??
          ConnectionStatus.disconnected,
      modelName: json['modelName'] as String?,
      macAddress: json['macAddress'] as String?,
      port: (json['port'] as num?)?.toInt(),
      authToken: json['authToken'] as String?,
      lastConnected: json['lastConnected'] == null
          ? null
          : DateTime.parse(json['lastConnected'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$DiscoveredDeviceImplToJson(
        _$DiscoveredDeviceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ipAddress': instance.ipAddress,
      'brand': _$TvBrandEnumMap[instance.brand]!,
      'status': _$ConnectionStatusEnumMap[instance.status]!,
      'modelName': instance.modelName,
      'macAddress': instance.macAddress,
      'port': instance.port,
      'authToken': instance.authToken,
      'lastConnected': instance.lastConnected?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$TvBrandEnumMap = {
  TvBrand.samsung: 'samsung',
  TvBrand.lg: 'lg',
  TvBrand.androidTv: 'androidTv',
  TvBrand.roku: 'roku',
  TvBrand.fireTv: 'fireTv',
  TvBrand.vizio: 'vizio',
  TvBrand.sony: 'sony',
  TvBrand.unknown: 'unknown',
};

const _$ConnectionStatusEnumMap = {
  ConnectionStatus.disconnected: 'disconnected',
  ConnectionStatus.connecting: 'connecting',
  ConnectionStatus.connected: 'connected',
  ConnectionStatus.paired: 'paired',
  ConnectionStatus.error: 'error',
};
