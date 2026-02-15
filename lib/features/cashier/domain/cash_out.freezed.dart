// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_out.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CashOutEntity _$CashOutEntityFromJson(Map<String, dynamic> json) {
  return _CashOutEntity.fromJson(json);
}

/// @nodoc
mixin _$CashOutEntity {
  String get id => throw _privateConstructorUsedError;
  String get shiftId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get performedBy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CashOutEntityCopyWith<CashOutEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashOutEntityCopyWith<$Res> {
  factory $CashOutEntityCopyWith(
          CashOutEntity value, $Res Function(CashOutEntity) then) =
      _$CashOutEntityCopyWithImpl<$Res, CashOutEntity>;
  @useResult
  $Res call(
      {String id,
      String shiftId,
      double amount,
      String reason,
      @TimestampConverter() DateTime timestamp,
      String? performedBy});
}

/// @nodoc
class _$CashOutEntityCopyWithImpl<$Res, $Val extends CashOutEntity>
    implements $CashOutEntityCopyWith<$Res> {
  _$CashOutEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shiftId = null,
    Object? amount = null,
    Object? reason = null,
    Object? timestamp = null,
    Object? performedBy = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shiftId: null == shiftId
          ? _value.shiftId
          : shiftId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      performedBy: freezed == performedBy
          ? _value.performedBy
          : performedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CashOutEntityImplCopyWith<$Res>
    implements $CashOutEntityCopyWith<$Res> {
  factory _$$CashOutEntityImplCopyWith(
          _$CashOutEntityImpl value, $Res Function(_$CashOutEntityImpl) then) =
      __$$CashOutEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String shiftId,
      double amount,
      String reason,
      @TimestampConverter() DateTime timestamp,
      String? performedBy});
}

/// @nodoc
class __$$CashOutEntityImplCopyWithImpl<$Res>
    extends _$CashOutEntityCopyWithImpl<$Res, _$CashOutEntityImpl>
    implements _$$CashOutEntityImplCopyWith<$Res> {
  __$$CashOutEntityImplCopyWithImpl(
      _$CashOutEntityImpl _value, $Res Function(_$CashOutEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shiftId = null,
    Object? amount = null,
    Object? reason = null,
    Object? timestamp = null,
    Object? performedBy = freezed,
  }) {
    return _then(_$CashOutEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shiftId: null == shiftId
          ? _value.shiftId
          : shiftId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      performedBy: freezed == performedBy
          ? _value.performedBy
          : performedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$CashOutEntityImpl implements _CashOutEntity {
  const _$CashOutEntityImpl(
      {required this.id,
      required this.shiftId,
      required this.amount,
      required this.reason,
      @TimestampConverter() required this.timestamp,
      this.performedBy});

  factory _$CashOutEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CashOutEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String shiftId;
  @override
  final double amount;
  @override
  final String reason;
  @override
  @TimestampConverter()
  final DateTime timestamp;
  @override
  final String? performedBy;

  @override
  String toString() {
    return 'CashOutEntity(id: $id, shiftId: $shiftId, amount: $amount, reason: $reason, timestamp: $timestamp, performedBy: $performedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CashOutEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shiftId, shiftId) || other.shiftId == shiftId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.performedBy, performedBy) ||
                other.performedBy == performedBy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, shiftId, amount, reason, timestamp, performedBy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CashOutEntityImplCopyWith<_$CashOutEntityImpl> get copyWith =>
      __$$CashOutEntityImplCopyWithImpl<_$CashOutEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CashOutEntityImplToJson(
      this,
    );
  }
}

abstract class _CashOutEntity implements CashOutEntity {
  const factory _CashOutEntity(
      {required final String id,
      required final String shiftId,
      required final double amount,
      required final String reason,
      @TimestampConverter() required final DateTime timestamp,
      final String? performedBy}) = _$CashOutEntityImpl;

  factory _CashOutEntity.fromJson(Map<String, dynamic> json) =
      _$CashOutEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get shiftId;
  @override
  double get amount;
  @override
  String get reason;
  @override
  @TimestampConverter()
  DateTime get timestamp;
  @override
  String? get performedBy;
  @override
  @JsonKey(ignore: true)
  _$$CashOutEntityImplCopyWith<_$CashOutEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
