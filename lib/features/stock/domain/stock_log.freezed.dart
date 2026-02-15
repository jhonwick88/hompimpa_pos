// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StockLog _$StockLogFromJson(Map<String, dynamic> json) {
  return _StockLog.fromJson(json);
}

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
      _$StockLogCopyWithImpl<$Res, StockLog>;
  @useResult
  $Res call(
      {String id,
      String productId,
      int qtyChange,
      String reason,
      DateTime createdAt});
}

/// @nodoc
class _$StockLogCopyWithImpl<$Res, $Val extends StockLog>
    implements $StockLogCopyWith<$Res> {
  _$StockLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? qtyChange = null,
    Object? reason = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      qtyChange: null == qtyChange
          ? _value.qtyChange
          : qtyChange // ignore: cast_nullable_to_non_nullable
              as int,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StockLogImplCopyWith<$Res>
    implements $StockLogCopyWith<$Res> {
  factory _$$StockLogImplCopyWith(
          _$StockLogImpl value, $Res Function(_$StockLogImpl) then) =
      __$$StockLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String productId,
      int qtyChange,
      String reason,
      DateTime createdAt});
}

/// @nodoc
class __$$StockLogImplCopyWithImpl<$Res>
    extends _$StockLogCopyWithImpl<$Res, _$StockLogImpl>
    implements _$$StockLogImplCopyWith<$Res> {
  __$$StockLogImplCopyWithImpl(
      _$StockLogImpl _value, $Res Function(_$StockLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? qtyChange = null,
    Object? reason = null,
    Object? createdAt = null,
  }) {
    return _then(_$StockLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      qtyChange: null == qtyChange
          ? _value.qtyChange
          : qtyChange // ignore: cast_nullable_to_non_nullable
              as int,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StockLogImpl implements _StockLog {
  const _$StockLogImpl(
      {required this.id,
      required this.productId,
      required this.qtyChange,
      required this.reason,
      required this.createdAt});

  factory _$StockLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$StockLogImplFromJson(json);

  @override
  final String id;
  @override
  final String productId;
  @override
  final int qtyChange;
  @override
  final String reason;
// Order ID or "Manual Adjustment"
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'StockLog(id: $id, productId: $productId, qtyChange: $qtyChange, reason: $reason, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.qtyChange, qtyChange) ||
                other.qtyChange == qtyChange) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, productId, qtyChange, reason, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StockLogImplCopyWith<_$StockLogImpl> get copyWith =>
      __$$StockLogImplCopyWithImpl<_$StockLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StockLogImplToJson(
      this,
    );
  }
}

abstract class _StockLog implements StockLog {
  const factory _StockLog(
      {required final String id,
      required final String productId,
      required final int qtyChange,
      required final String reason,
      required final DateTime createdAt}) = _$StockLogImpl;

  factory _StockLog.fromJson(Map<String, dynamic> json) =
      _$StockLogImpl.fromJson;

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
  _$$StockLogImplCopyWith<_$StockLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
