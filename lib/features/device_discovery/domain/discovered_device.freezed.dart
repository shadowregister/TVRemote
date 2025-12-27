// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discovered_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DiscoveredDevice _$DiscoveredDeviceFromJson(Map<String, dynamic> json) {
  return _DiscoveredDevice.fromJson(json);
}

/// @nodoc
mixin _$DiscoveredDevice {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get ipAddress => throw _privateConstructorUsedError;
  TvBrand get brand => throw _privateConstructorUsedError;
  ConnectionStatus get status => throw _privateConstructorUsedError;
  String? get modelName => throw _privateConstructorUsedError;
  String? get macAddress => throw _privateConstructorUsedError;
  int? get port => throw _privateConstructorUsedError;
  String? get authToken => throw _privateConstructorUsedError;
  DateTime? get lastConnected => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this DiscoveredDevice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiscoveredDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscoveredDeviceCopyWith<DiscoveredDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscoveredDeviceCopyWith<$Res> {
  factory $DiscoveredDeviceCopyWith(
          DiscoveredDevice value, $Res Function(DiscoveredDevice) then) =
      _$DiscoveredDeviceCopyWithImpl<$Res, DiscoveredDevice>;
  @useResult
  $Res call(
      {String id,
      String name,
      String ipAddress,
      TvBrand brand,
      ConnectionStatus status,
      String? modelName,
      String? macAddress,
      int? port,
      String? authToken,
      DateTime? lastConnected,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$DiscoveredDeviceCopyWithImpl<$Res, $Val extends DiscoveredDevice>
    implements $DiscoveredDeviceCopyWith<$Res> {
  _$DiscoveredDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscoveredDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ipAddress = null,
    Object? brand = null,
    Object? status = null,
    Object? modelName = freezed,
    Object? macAddress = freezed,
    Object? port = freezed,
    Object? authToken = freezed,
    Object? lastConnected = freezed,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ipAddress: null == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String,
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as TvBrand,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ConnectionStatus,
      modelName: freezed == modelName
          ? _value.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String?,
      macAddress: freezed == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      port: freezed == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int?,
      authToken: freezed == authToken
          ? _value.authToken
          : authToken // ignore: cast_nullable_to_non_nullable
              as String?,
      lastConnected: freezed == lastConnected
          ? _value.lastConnected
          : lastConnected // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiscoveredDeviceImplCopyWith<$Res>
    implements $DiscoveredDeviceCopyWith<$Res> {
  factory _$$DiscoveredDeviceImplCopyWith(_$DiscoveredDeviceImpl value,
          $Res Function(_$DiscoveredDeviceImpl) then) =
      __$$DiscoveredDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String ipAddress,
      TvBrand brand,
      ConnectionStatus status,
      String? modelName,
      String? macAddress,
      int? port,
      String? authToken,
      DateTime? lastConnected,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$DiscoveredDeviceImplCopyWithImpl<$Res>
    extends _$DiscoveredDeviceCopyWithImpl<$Res, _$DiscoveredDeviceImpl>
    implements _$$DiscoveredDeviceImplCopyWith<$Res> {
  __$$DiscoveredDeviceImplCopyWithImpl(_$DiscoveredDeviceImpl _value,
      $Res Function(_$DiscoveredDeviceImpl) _then)
      : super(_value, _then);

  /// Create a copy of DiscoveredDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ipAddress = null,
    Object? brand = null,
    Object? status = null,
    Object? modelName = freezed,
    Object? macAddress = freezed,
    Object? port = freezed,
    Object? authToken = freezed,
    Object? lastConnected = freezed,
    Object? metadata = null,
  }) {
    return _then(_$DiscoveredDeviceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ipAddress: null == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String,
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as TvBrand,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ConnectionStatus,
      modelName: freezed == modelName
          ? _value.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String?,
      macAddress: freezed == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      port: freezed == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int?,
      authToken: freezed == authToken
          ? _value.authToken
          : authToken // ignore: cast_nullable_to_non_nullable
              as String?,
      lastConnected: freezed == lastConnected
          ? _value.lastConnected
          : lastConnected // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscoveredDeviceImpl implements _DiscoveredDevice {
  const _$DiscoveredDeviceImpl(
      {required this.id,
      required this.name,
      required this.ipAddress,
      required this.brand,
      this.status = ConnectionStatus.disconnected,
      this.modelName,
      this.macAddress,
      this.port,
      this.authToken,
      this.lastConnected,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  factory _$DiscoveredDeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscoveredDeviceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String ipAddress;
  @override
  final TvBrand brand;
  @override
  @JsonKey()
  final ConnectionStatus status;
  @override
  final String? modelName;
  @override
  final String? macAddress;
  @override
  final int? port;
  @override
  final String? authToken;
  @override
  final DateTime? lastConnected;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'DiscoveredDevice(id: $id, name: $name, ipAddress: $ipAddress, brand: $brand, status: $status, modelName: $modelName, macAddress: $macAddress, port: $port, authToken: $authToken, lastConnected: $lastConnected, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscoveredDeviceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.modelName, modelName) ||
                other.modelName == modelName) &&
            (identical(other.macAddress, macAddress) ||
                other.macAddress == macAddress) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.authToken, authToken) ||
                other.authToken == authToken) &&
            (identical(other.lastConnected, lastConnected) ||
                other.lastConnected == lastConnected) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      ipAddress,
      brand,
      status,
      modelName,
      macAddress,
      port,
      authToken,
      lastConnected,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of DiscoveredDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscoveredDeviceImplCopyWith<_$DiscoveredDeviceImpl> get copyWith =>
      __$$DiscoveredDeviceImplCopyWithImpl<_$DiscoveredDeviceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscoveredDeviceImplToJson(
      this,
    );
  }
}

abstract class _DiscoveredDevice implements DiscoveredDevice {
  const factory _DiscoveredDevice(
      {required final String id,
      required final String name,
      required final String ipAddress,
      required final TvBrand brand,
      final ConnectionStatus status,
      final String? modelName,
      final String? macAddress,
      final int? port,
      final String? authToken,
      final DateTime? lastConnected,
      final Map<String, dynamic> metadata}) = _$DiscoveredDeviceImpl;

  factory _DiscoveredDevice.fromJson(Map<String, dynamic> json) =
      _$DiscoveredDeviceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get ipAddress;
  @override
  TvBrand get brand;
  @override
  ConnectionStatus get status;
  @override
  String? get modelName;
  @override
  String? get macAddress;
  @override
  int? get port;
  @override
  String? get authToken;
  @override
  DateTime? get lastConnected;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of DiscoveredDevice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscoveredDeviceImplCopyWith<_$DiscoveredDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
