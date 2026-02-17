// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shift.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShiftEntity {

 String get id; String get shiftName;@TimestampConverter() DateTime get startTime;@TimestampNullableConverter() DateTime? get endTime; double get startCash; double? get endCash;// Physical cash counted at closing
 double? get expectedCash;// Calculated system cash at closing
 double? get difference;// endCash - expectedCash
 String get status;// OPEN, CLOSED
// Summary fields (populated on close)
 double? get totalCashSales; double? get totalNonCashSales; double? get totalCashOut;
/// Create a copy of ShiftEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShiftEntityCopyWith<ShiftEntity> get copyWith => _$ShiftEntityCopyWithImpl<ShiftEntity>(this as ShiftEntity, _$identity);

  /// Serializes this ShiftEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShiftEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.shiftName, shiftName) || other.shiftName == shiftName)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.startCash, startCash) || other.startCash == startCash)&&(identical(other.endCash, endCash) || other.endCash == endCash)&&(identical(other.expectedCash, expectedCash) || other.expectedCash == expectedCash)&&(identical(other.difference, difference) || other.difference == difference)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalCashSales, totalCashSales) || other.totalCashSales == totalCashSales)&&(identical(other.totalNonCashSales, totalNonCashSales) || other.totalNonCashSales == totalNonCashSales)&&(identical(other.totalCashOut, totalCashOut) || other.totalCashOut == totalCashOut));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shiftName,startTime,endTime,startCash,endCash,expectedCash,difference,status,totalCashSales,totalNonCashSales,totalCashOut);

@override
String toString() {
  return 'ShiftEntity(id: $id, shiftName: $shiftName, startTime: $startTime, endTime: $endTime, startCash: $startCash, endCash: $endCash, expectedCash: $expectedCash, difference: $difference, status: $status, totalCashSales: $totalCashSales, totalNonCashSales: $totalNonCashSales, totalCashOut: $totalCashOut)';
}


}

/// @nodoc
abstract mixin class $ShiftEntityCopyWith<$Res>  {
  factory $ShiftEntityCopyWith(ShiftEntity value, $Res Function(ShiftEntity) _then) = _$ShiftEntityCopyWithImpl;
@useResult
$Res call({
 String id, String shiftName,@TimestampConverter() DateTime startTime,@TimestampNullableConverter() DateTime? endTime, double startCash, double? endCash, double? expectedCash, double? difference, String status, double? totalCashSales, double? totalNonCashSales, double? totalCashOut
});




}
/// @nodoc
class _$ShiftEntityCopyWithImpl<$Res>
    implements $ShiftEntityCopyWith<$Res> {
  _$ShiftEntityCopyWithImpl(this._self, this._then);

  final ShiftEntity _self;
  final $Res Function(ShiftEntity) _then;

/// Create a copy of ShiftEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shiftName = null,Object? startTime = null,Object? endTime = freezed,Object? startCash = null,Object? endCash = freezed,Object? expectedCash = freezed,Object? difference = freezed,Object? status = null,Object? totalCashSales = freezed,Object? totalNonCashSales = freezed,Object? totalCashOut = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shiftName: null == shiftName ? _self.shiftName : shiftName // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,startCash: null == startCash ? _self.startCash : startCash // ignore: cast_nullable_to_non_nullable
as double,endCash: freezed == endCash ? _self.endCash : endCash // ignore: cast_nullable_to_non_nullable
as double?,expectedCash: freezed == expectedCash ? _self.expectedCash : expectedCash // ignore: cast_nullable_to_non_nullable
as double?,difference: freezed == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalCashSales: freezed == totalCashSales ? _self.totalCashSales : totalCashSales // ignore: cast_nullable_to_non_nullable
as double?,totalNonCashSales: freezed == totalNonCashSales ? _self.totalNonCashSales : totalNonCashSales // ignore: cast_nullable_to_non_nullable
as double?,totalCashOut: freezed == totalCashOut ? _self.totalCashOut : totalCashOut // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShiftEntity].
extension ShiftEntityPatterns on ShiftEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShiftEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShiftEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShiftEntity value)  $default,){
final _that = this;
switch (_that) {
case _ShiftEntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShiftEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ShiftEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String shiftName, @TimestampConverter()  DateTime startTime, @TimestampNullableConverter()  DateTime? endTime,  double startCash,  double? endCash,  double? expectedCash,  double? difference,  String status,  double? totalCashSales,  double? totalNonCashSales,  double? totalCashOut)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShiftEntity() when $default != null:
return $default(_that.id,_that.shiftName,_that.startTime,_that.endTime,_that.startCash,_that.endCash,_that.expectedCash,_that.difference,_that.status,_that.totalCashSales,_that.totalNonCashSales,_that.totalCashOut);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String shiftName, @TimestampConverter()  DateTime startTime, @TimestampNullableConverter()  DateTime? endTime,  double startCash,  double? endCash,  double? expectedCash,  double? difference,  String status,  double? totalCashSales,  double? totalNonCashSales,  double? totalCashOut)  $default,) {final _that = this;
switch (_that) {
case _ShiftEntity():
return $default(_that.id,_that.shiftName,_that.startTime,_that.endTime,_that.startCash,_that.endCash,_that.expectedCash,_that.difference,_that.status,_that.totalCashSales,_that.totalNonCashSales,_that.totalCashOut);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String shiftName, @TimestampConverter()  DateTime startTime, @TimestampNullableConverter()  DateTime? endTime,  double startCash,  double? endCash,  double? expectedCash,  double? difference,  String status,  double? totalCashSales,  double? totalNonCashSales,  double? totalCashOut)?  $default,) {final _that = this;
switch (_that) {
case _ShiftEntity() when $default != null:
return $default(_that.id,_that.shiftName,_that.startTime,_that.endTime,_that.startCash,_that.endCash,_that.expectedCash,_that.difference,_that.status,_that.totalCashSales,_that.totalNonCashSales,_that.totalCashOut);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ShiftEntity implements ShiftEntity {
  const _ShiftEntity({required this.id, required this.shiftName, @TimestampConverter() required this.startTime, @TimestampNullableConverter() this.endTime, required this.startCash, this.endCash, this.expectedCash, this.difference, this.status = 'OPEN', this.totalCashSales, this.totalNonCashSales, this.totalCashOut});
  factory _ShiftEntity.fromJson(Map<String, dynamic> json) => _$ShiftEntityFromJson(json);

@override final  String id;
@override final  String shiftName;
@override@TimestampConverter() final  DateTime startTime;
@override@TimestampNullableConverter() final  DateTime? endTime;
@override final  double startCash;
@override final  double? endCash;
// Physical cash counted at closing
@override final  double? expectedCash;
// Calculated system cash at closing
@override final  double? difference;
// endCash - expectedCash
@override@JsonKey() final  String status;
// OPEN, CLOSED
// Summary fields (populated on close)
@override final  double? totalCashSales;
@override final  double? totalNonCashSales;
@override final  double? totalCashOut;

/// Create a copy of ShiftEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShiftEntityCopyWith<_ShiftEntity> get copyWith => __$ShiftEntityCopyWithImpl<_ShiftEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShiftEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShiftEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.shiftName, shiftName) || other.shiftName == shiftName)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.startCash, startCash) || other.startCash == startCash)&&(identical(other.endCash, endCash) || other.endCash == endCash)&&(identical(other.expectedCash, expectedCash) || other.expectedCash == expectedCash)&&(identical(other.difference, difference) || other.difference == difference)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalCashSales, totalCashSales) || other.totalCashSales == totalCashSales)&&(identical(other.totalNonCashSales, totalNonCashSales) || other.totalNonCashSales == totalNonCashSales)&&(identical(other.totalCashOut, totalCashOut) || other.totalCashOut == totalCashOut));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shiftName,startTime,endTime,startCash,endCash,expectedCash,difference,status,totalCashSales,totalNonCashSales,totalCashOut);

@override
String toString() {
  return 'ShiftEntity(id: $id, shiftName: $shiftName, startTime: $startTime, endTime: $endTime, startCash: $startCash, endCash: $endCash, expectedCash: $expectedCash, difference: $difference, status: $status, totalCashSales: $totalCashSales, totalNonCashSales: $totalNonCashSales, totalCashOut: $totalCashOut)';
}


}

/// @nodoc
abstract mixin class _$ShiftEntityCopyWith<$Res> implements $ShiftEntityCopyWith<$Res> {
  factory _$ShiftEntityCopyWith(_ShiftEntity value, $Res Function(_ShiftEntity) _then) = __$ShiftEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String shiftName,@TimestampConverter() DateTime startTime,@TimestampNullableConverter() DateTime? endTime, double startCash, double? endCash, double? expectedCash, double? difference, String status, double? totalCashSales, double? totalNonCashSales, double? totalCashOut
});




}
/// @nodoc
class __$ShiftEntityCopyWithImpl<$Res>
    implements _$ShiftEntityCopyWith<$Res> {
  __$ShiftEntityCopyWithImpl(this._self, this._then);

  final _ShiftEntity _self;
  final $Res Function(_ShiftEntity) _then;

/// Create a copy of ShiftEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shiftName = null,Object? startTime = null,Object? endTime = freezed,Object? startCash = null,Object? endCash = freezed,Object? expectedCash = freezed,Object? difference = freezed,Object? status = null,Object? totalCashSales = freezed,Object? totalNonCashSales = freezed,Object? totalCashOut = freezed,}) {
  return _then(_ShiftEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shiftName: null == shiftName ? _self.shiftName : shiftName // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,startCash: null == startCash ? _self.startCash : startCash // ignore: cast_nullable_to_non_nullable
as double,endCash: freezed == endCash ? _self.endCash : endCash // ignore: cast_nullable_to_non_nullable
as double?,expectedCash: freezed == expectedCash ? _self.expectedCash : expectedCash // ignore: cast_nullable_to_non_nullable
as double?,difference: freezed == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalCashSales: freezed == totalCashSales ? _self.totalCashSales : totalCashSales // ignore: cast_nullable_to_non_nullable
as double?,totalNonCashSales: freezed == totalNonCashSales ? _self.totalNonCashSales : totalNonCashSales // ignore: cast_nullable_to_non_nullable
as double?,totalCashOut: freezed == totalCashOut ? _self.totalCashOut : totalCashOut // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
