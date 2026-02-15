// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shift.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ShiftEntity _$ShiftEntityFromJson(Map<String, dynamic> json) {
  return _ShiftEntity.fromJson(json);
}

/// @nodoc
mixin _$ShiftEntity {
  String get id => throw _privateConstructorUsedError;
  String get shiftName => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get startTime => throw _privateConstructorUsedError;
  @TimestampNullableConverter()
  DateTime? get endTime => throw _privateConstructorUsedError;
  double get startCash => throw _privateConstructorUsedError;
  double? get endCash =>
      throw _privateConstructorUsedError; // Physical cash counted at closing
  double? get expectedCash =>
      throw _privateConstructorUsedError; // Calculated system cash at closing
  double? get difference =>
      throw _privateConstructorUsedError; // endCash - expectedCash
  String get status => throw _privateConstructorUsedError; // OPEN, CLOSED
// Summary fields (populated on close)
  double? get totalCashSales => throw _privateConstructorUsedError;
  double? get totalNonCashSales => throw _privateConstructorUsedError;
  double? get totalCashOut => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShiftEntityCopyWith<ShiftEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShiftEntityCopyWith<$Res> {
  factory $ShiftEntityCopyWith(
          ShiftEntity value, $Res Function(ShiftEntity) then) =
      _$ShiftEntityCopyWithImpl<$Res, ShiftEntity>;
  @useResult
  $Res call(
      {String id,
      String shiftName,
      @TimestampConverter() DateTime startTime,
      @TimestampNullableConverter() DateTime? endTime,
      double startCash,
      double? endCash,
      double? expectedCash,
      double? difference,
      String status,
      double? totalCashSales,
      double? totalNonCashSales,
      double? totalCashOut});
}

/// @nodoc
class _$ShiftEntityCopyWithImpl<$Res, $Val extends ShiftEntity>
    implements $ShiftEntityCopyWith<$Res> {
  _$ShiftEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shiftName = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? startCash = null,
    Object? endCash = freezed,
    Object? expectedCash = freezed,
    Object? difference = freezed,
    Object? status = null,
    Object? totalCashSales = freezed,
    Object? totalNonCashSales = freezed,
    Object? totalCashOut = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shiftName: null == shiftName
          ? _value.shiftName
          : shiftName // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startCash: null == startCash
          ? _value.startCash
          : startCash // ignore: cast_nullable_to_non_nullable
              as double,
      endCash: freezed == endCash
          ? _value.endCash
          : endCash // ignore: cast_nullable_to_non_nullable
              as double?,
      expectedCash: freezed == expectedCash
          ? _value.expectedCash
          : expectedCash // ignore: cast_nullable_to_non_nullable
              as double?,
      difference: freezed == difference
          ? _value.difference
          : difference // ignore: cast_nullable_to_non_nullable
              as double?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      totalCashSales: freezed == totalCashSales
          ? _value.totalCashSales
          : totalCashSales // ignore: cast_nullable_to_non_nullable
              as double?,
      totalNonCashSales: freezed == totalNonCashSales
          ? _value.totalNonCashSales
          : totalNonCashSales // ignore: cast_nullable_to_non_nullable
              as double?,
      totalCashOut: freezed == totalCashOut
          ? _value.totalCashOut
          : totalCashOut // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShiftEntityImplCopyWith<$Res>
    implements $ShiftEntityCopyWith<$Res> {
  factory _$$ShiftEntityImplCopyWith(
          _$ShiftEntityImpl value, $Res Function(_$ShiftEntityImpl) then) =
      __$$ShiftEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String shiftName,
      @TimestampConverter() DateTime startTime,
      @TimestampNullableConverter() DateTime? endTime,
      double startCash,
      double? endCash,
      double? expectedCash,
      double? difference,
      String status,
      double? totalCashSales,
      double? totalNonCashSales,
      double? totalCashOut});
}

/// @nodoc
class __$$ShiftEntityImplCopyWithImpl<$Res>
    extends _$ShiftEntityCopyWithImpl<$Res, _$ShiftEntityImpl>
    implements _$$ShiftEntityImplCopyWith<$Res> {
  __$$ShiftEntityImplCopyWithImpl(
      _$ShiftEntityImpl _value, $Res Function(_$ShiftEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shiftName = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? startCash = null,
    Object? endCash = freezed,
    Object? expectedCash = freezed,
    Object? difference = freezed,
    Object? status = null,
    Object? totalCashSales = freezed,
    Object? totalNonCashSales = freezed,
    Object? totalCashOut = freezed,
  }) {
    return _then(_$ShiftEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shiftName: null == shiftName
          ? _value.shiftName
          : shiftName // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startCash: null == startCash
          ? _value.startCash
          : startCash // ignore: cast_nullable_to_non_nullable
              as double,
      endCash: freezed == endCash
          ? _value.endCash
          : endCash // ignore: cast_nullable_to_non_nullable
              as double?,
      expectedCash: freezed == expectedCash
          ? _value.expectedCash
          : expectedCash // ignore: cast_nullable_to_non_nullable
              as double?,
      difference: freezed == difference
          ? _value.difference
          : difference // ignore: cast_nullable_to_non_nullable
              as double?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      totalCashSales: freezed == totalCashSales
          ? _value.totalCashSales
          : totalCashSales // ignore: cast_nullable_to_non_nullable
              as double?,
      totalNonCashSales: freezed == totalNonCashSales
          ? _value.totalNonCashSales
          : totalNonCashSales // ignore: cast_nullable_to_non_nullable
              as double?,
      totalCashOut: freezed == totalCashOut
          ? _value.totalCashOut
          : totalCashOut // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$ShiftEntityImpl implements _ShiftEntity {
  const _$ShiftEntityImpl(
      {required this.id,
      required this.shiftName,
      @TimestampConverter() required this.startTime,
      @TimestampNullableConverter() this.endTime,
      required this.startCash,
      this.endCash,
      this.expectedCash,
      this.difference,
      this.status = 'OPEN',
      this.totalCashSales,
      this.totalNonCashSales,
      this.totalCashOut});

  factory _$ShiftEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShiftEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String shiftName;
  @override
  @TimestampConverter()
  final DateTime startTime;
  @override
  @TimestampNullableConverter()
  final DateTime? endTime;
  @override
  final double startCash;
  @override
  final double? endCash;
// Physical cash counted at closing
  @override
  final double? expectedCash;
// Calculated system cash at closing
  @override
  final double? difference;
// endCash - expectedCash
  @override
  @JsonKey()
  final String status;
// OPEN, CLOSED
// Summary fields (populated on close)
  @override
  final double? totalCashSales;
  @override
  final double? totalNonCashSales;
  @override
  final double? totalCashOut;

  @override
  String toString() {
    return 'ShiftEntity(id: $id, shiftName: $shiftName, startTime: $startTime, endTime: $endTime, startCash: $startCash, endCash: $endCash, expectedCash: $expectedCash, difference: $difference, status: $status, totalCashSales: $totalCashSales, totalNonCashSales: $totalNonCashSales, totalCashOut: $totalCashOut)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShiftEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shiftName, shiftName) ||
                other.shiftName == shiftName) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.startCash, startCash) ||
                other.startCash == startCash) &&
            (identical(other.endCash, endCash) || other.endCash == endCash) &&
            (identical(other.expectedCash, expectedCash) ||
                other.expectedCash == expectedCash) &&
            (identical(other.difference, difference) ||
                other.difference == difference) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalCashSales, totalCashSales) ||
                other.totalCashSales == totalCashSales) &&
            (identical(other.totalNonCashSales, totalNonCashSales) ||
                other.totalNonCashSales == totalNonCashSales) &&
            (identical(other.totalCashOut, totalCashOut) ||
                other.totalCashOut == totalCashOut));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      shiftName,
      startTime,
      endTime,
      startCash,
      endCash,
      expectedCash,
      difference,
      status,
      totalCashSales,
      totalNonCashSales,
      totalCashOut);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShiftEntityImplCopyWith<_$ShiftEntityImpl> get copyWith =>
      __$$ShiftEntityImplCopyWithImpl<_$ShiftEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShiftEntityImplToJson(
      this,
    );
  }
}

abstract class _ShiftEntity implements ShiftEntity {
  const factory _ShiftEntity(
      {required final String id,
      required final String shiftName,
      @TimestampConverter() required final DateTime startTime,
      @TimestampNullableConverter() final DateTime? endTime,
      required final double startCash,
      final double? endCash,
      final double? expectedCash,
      final double? difference,
      final String status,
      final double? totalCashSales,
      final double? totalNonCashSales,
      final double? totalCashOut}) = _$ShiftEntityImpl;

  factory _ShiftEntity.fromJson(Map<String, dynamic> json) =
      _$ShiftEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get shiftName;
  @override
  @TimestampConverter()
  DateTime get startTime;
  @override
  @TimestampNullableConverter()
  DateTime? get endTime;
  @override
  double get startCash;
  @override
  double? get endCash;
  @override // Physical cash counted at closing
  double? get expectedCash;
  @override // Calculated system cash at closing
  double? get difference;
  @override // endCash - expectedCash
  String get status;
  @override // OPEN, CLOSED
// Summary fields (populated on close)
  double? get totalCashSales;
  @override
  double? get totalNonCashSales;
  @override
  double? get totalCashOut;
  @override
  @JsonKey(ignore: true)
  _$$ShiftEntityImplCopyWith<_$ShiftEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
