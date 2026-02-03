// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'stock_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

StockLog _$StockLogFromJson(Map<String, dynamic> json) {
  return _StockLog.fromJson(json);
}

/// @nodoc
class _$StockLogTearOff {
  const _$StockLogTearOff();

  _StockLog call(
      {required String id,
      required String productId,
      required int qtyChange,
      required String reason,
      required DateTime createdAt}) {
    return _StockLog(
      id: id,
      productId: productId,
      qtyChange: qtyChange,
      reason: reason,
      createdAt: createdAt,
    );
  }

  StockLog fromJson(Map<String, Object?> json) {
    return StockLog.fromJson(json);
  }
}

/// @nodoc
const $StockLog = _$StockLogTearOff();

/// @nodoc
mixin _$StockLog {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  int get qtyChange => throw _privateConstructorUsedError;
  String get reason =>
      throw _privateConstructorUsedError; // Order ID or "Manual Adjustment"
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StockLogCopyWith<StockLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockLogCopyWith<$Res> {
  factory $StockLogCopyWith(StockLog value, $Res Function(StockLog) then) =
      _$StockLogCopyWithImpl<$Res>;
  $Res call(
      {String id,
      String productId,
      int qtyChange,
      String reason,
      DateTime createdAt});
}

/// @nodoc
class _$StockLogCopyWithImpl<$Res> implements $StockLogCopyWith<$Res> {
  _$StockLogCopyWithImpl(this._value, this._then);

  final StockLog _value;
  // ignore: unused_field
  final $Res Function(StockLog) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? productId = freezed,
    Object? qtyChange = freezed,
    Object? reason = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: productId == freezed
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      qtyChange: qtyChange == freezed
          ? _value.qtyChange
          : qtyChange // ignore: cast_nullable_to_non_nullable
              as int,
      reason: reason == freezed
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
abstract class _$StockLogCopyWith<$Res> implements $StockLogCopyWith<$Res> {
  factory _$StockLogCopyWith(_StockLog value, $Res Function(_StockLog) then) =
      __$StockLogCopyWithImpl<$Res>;
  @override
  $Res call(
      {String id,
      String productId,
      int qtyChange,
      String reason,
      DateTime createdAt});
}

/// @nodoc
class __$StockLogCopyWithImpl<$Res> extends _$StockLogCopyWithImpl<$Res>
    implements _$StockLogCopyWith<$Res> {
  __$StockLogCopyWithImpl(_StockLog _value, $Res Function(_StockLog) _then)
      : super(_value, (v) => _then(v as _StockLog));

  @override
  _StockLog get _value => super._value as _StockLog;

  @override
  $Res call({
    Object? id = freezed,
    Object? productId = freezed,
    Object? qtyChange = freezed,
    Object? reason = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_StockLog(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: productId == freezed
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      qtyChange: qtyChange == freezed
          ? _value.qtyChange
          : qtyChange // ignore: cast_nullable_to_non_nullable
              as int,
      reason: reason == freezed
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_StockLog implements _StockLog {
  const _$_StockLog(
      {required this.id,
      required this.productId,
      required this.qtyChange,
      required this.reason,
      required this.createdAt});

  factory _$_StockLog.fromJson(Map<String, dynamic> json) =>
      _$$_StockLogFromJson(json);

  @override
  final String id;
  @override
  final String productId;
  @override
  final int qtyChange;
  @override
  final String reason;
  @override // Order ID or "Manual Adjustment"
  final DateTime createdAt;

  @override
  String toString() {
    return 'StockLog(id: $id, productId: $productId, qtyChange: $qtyChange, reason: $reason, createdAt: $createdAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StockLog &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.productId, productId) &&
            const DeepCollectionEquality().equals(other.qtyChange, qtyChange) &&
            const DeepCollectionEquality().equals(other.reason, reason) &&
            const DeepCollectionEquality().equals(other.createdAt, createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(productId),
      const DeepCollectionEquality().hash(qtyChange),
      const DeepCollectionEquality().hash(reason),
      const DeepCollectionEquality().hash(createdAt));

  @JsonKey(ignore: true)
  @override
  _$StockLogCopyWith<_StockLog> get copyWith =>
      __$StockLogCopyWithImpl<_StockLog>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_StockLogToJson(this);
  }
}

abstract class _StockLog implements StockLog {
  const factory _StockLog(
      {required String id,
      required String productId,
      required int qtyChange,
      required String reason,
      required DateTime createdAt}) = _$_StockLog;

  factory _StockLog.fromJson(Map<String, dynamic> json) = _$_StockLog.fromJson;

  @override
  String get id;
  @override
  String get productId;
  @override
  int get qtyChange;
  @override
  String get reason;
  @override // Order ID or "Manual Adjustment"
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$StockLogCopyWith<_StockLog> get copyWith =>
      throw _privateConstructorUsedError;
}
