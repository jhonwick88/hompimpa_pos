// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_out.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CashOutEntity {

 String get id; String get shiftId; double get amount; String get reason;@TimestampConverter() DateTime get timestamp; String? get performedBy;
/// Create a copy of CashOutEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashOutEntityCopyWith<CashOutEntity> get copyWith => _$CashOutEntityCopyWithImpl<CashOutEntity>(this as CashOutEntity, _$identity);

  /// Serializes this CashOutEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashOutEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.performedBy, performedBy) || other.performedBy == performedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shiftId,amount,reason,timestamp,performedBy);

@override
String toString() {
  return 'CashOutEntity(id: $id, shiftId: $shiftId, amount: $amount, reason: $reason, timestamp: $timestamp, performedBy: $performedBy)';
}


}

/// @nodoc
abstract mixin class $CashOutEntityCopyWith<$Res>  {
  factory $CashOutEntityCopyWith(CashOutEntity value, $Res Function(CashOutEntity) _then) = _$CashOutEntityCopyWithImpl;
@useResult
$Res call({
 String id, String shiftId, double amount, String reason,@TimestampConverter() DateTime timestamp, String? performedBy
});




}
/// @nodoc
class _$CashOutEntityCopyWithImpl<$Res>
    implements $CashOutEntityCopyWith<$Res> {
  _$CashOutEntityCopyWithImpl(this._self, this._then);

  final CashOutEntity _self;
  final $Res Function(CashOutEntity) _then;

/// Create a copy of CashOutEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shiftId = null,Object? amount = null,Object? reason = null,Object? timestamp = null,Object? performedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shiftId: null == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,performedBy: freezed == performedBy ? _self.performedBy : performedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CashOutEntity].
extension CashOutEntityPatterns on CashOutEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashOutEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashOutEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashOutEntity value)  $default,){
final _that = this;
switch (_that) {
case _CashOutEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashOutEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CashOutEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String shiftId,  double amount,  String reason, @TimestampConverter()  DateTime timestamp,  String? performedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashOutEntity() when $default != null:
return $default(_that.id,_that.shiftId,_that.amount,_that.reason,_that.timestamp,_that.performedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String shiftId,  double amount,  String reason, @TimestampConverter()  DateTime timestamp,  String? performedBy)  $default,) {final _that = this;
switch (_that) {
case _CashOutEntity():
return $default(_that.id,_that.shiftId,_that.amount,_that.reason,_that.timestamp,_that.performedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String shiftId,  double amount,  String reason, @TimestampConverter()  DateTime timestamp,  String? performedBy)?  $default,) {final _that = this;
switch (_that) {
case _CashOutEntity() when $default != null:
return $default(_that.id,_that.shiftId,_that.amount,_that.reason,_that.timestamp,_that.performedBy);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CashOutEntity implements CashOutEntity {
  const _CashOutEntity({required this.id, required this.shiftId, required this.amount, required this.reason, @TimestampConverter() required this.timestamp, this.performedBy});
  factory _CashOutEntity.fromJson(Map<String, dynamic> json) => _$CashOutEntityFromJson(json);

@override final  String id;
@override final  String shiftId;
@override final  double amount;
@override final  String reason;
@override@TimestampConverter() final  DateTime timestamp;
@override final  String? performedBy;

/// Create a copy of CashOutEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashOutEntityCopyWith<_CashOutEntity> get copyWith => __$CashOutEntityCopyWithImpl<_CashOutEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CashOutEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashOutEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.performedBy, performedBy) || other.performedBy == performedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shiftId,amount,reason,timestamp,performedBy);

@override
String toString() {
  return 'CashOutEntity(id: $id, shiftId: $shiftId, amount: $amount, reason: $reason, timestamp: $timestamp, performedBy: $performedBy)';
}


}

/// @nodoc
abstract mixin class _$CashOutEntityCopyWith<$Res> implements $CashOutEntityCopyWith<$Res> {
  factory _$CashOutEntityCopyWith(_CashOutEntity value, $Res Function(_CashOutEntity) _then) = __$CashOutEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String shiftId, double amount, String reason,@TimestampConverter() DateTime timestamp, String? performedBy
});




}
/// @nodoc
class __$CashOutEntityCopyWithImpl<$Res>
    implements _$CashOutEntityCopyWith<$Res> {
  __$CashOutEntityCopyWithImpl(this._self, this._then);

  final _CashOutEntity _self;
  final $Res Function(_CashOutEntity) _then;

/// Create a copy of CashOutEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shiftId = null,Object? amount = null,Object? reason = null,Object? timestamp = null,Object? performedBy = freezed,}) {
  return _then(_CashOutEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shiftId: null == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,performedBy: freezed == performedBy ? _self.performedBy : performedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
