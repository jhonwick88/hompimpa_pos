// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sambal_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SambalSettings {

 double get level0to3Price; double get level4to5Price; double get level6to7Price;
/// Create a copy of SambalSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SambalSettingsCopyWith<SambalSettings> get copyWith => _$SambalSettingsCopyWithImpl<SambalSettings>(this as SambalSettings, _$identity);

  /// Serializes this SambalSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SambalSettings&&(identical(other.level0to3Price, level0to3Price) || other.level0to3Price == level0to3Price)&&(identical(other.level4to5Price, level4to5Price) || other.level4to5Price == level4to5Price)&&(identical(other.level6to7Price, level6to7Price) || other.level6to7Price == level6to7Price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level0to3Price,level4to5Price,level6to7Price);

@override
String toString() {
  return 'SambalSettings(level0to3Price: $level0to3Price, level4to5Price: $level4to5Price, level6to7Price: $level6to7Price)';
}


}

/// @nodoc
abstract mixin class $SambalSettingsCopyWith<$Res>  {
  factory $SambalSettingsCopyWith(SambalSettings value, $Res Function(SambalSettings) _then) = _$SambalSettingsCopyWithImpl;
@useResult
$Res call({
 double level0to3Price, double level4to5Price, double level6to7Price
});




}
/// @nodoc
class _$SambalSettingsCopyWithImpl<$Res>
    implements $SambalSettingsCopyWith<$Res> {
  _$SambalSettingsCopyWithImpl(this._self, this._then);

  final SambalSettings _self;
  final $Res Function(SambalSettings) _then;

/// Create a copy of SambalSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level0to3Price = null,Object? level4to5Price = null,Object? level6to7Price = null,}) {
  return _then(_self.copyWith(
level0to3Price: null == level0to3Price ? _self.level0to3Price : level0to3Price // ignore: cast_nullable_to_non_nullable
as double,level4to5Price: null == level4to5Price ? _self.level4to5Price : level4to5Price // ignore: cast_nullable_to_non_nullable
as double,level6to7Price: null == level6to7Price ? _self.level6to7Price : level6to7Price // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SambalSettings].
extension SambalSettingsPatterns on SambalSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SambalSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SambalSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SambalSettings value)  $default,){
final _that = this;
switch (_that) {
case _SambalSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SambalSettings value)?  $default,){
final _that = this;
switch (_that) {
case _SambalSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double level0to3Price,  double level4to5Price,  double level6to7Price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SambalSettings() when $default != null:
return $default(_that.level0to3Price,_that.level4to5Price,_that.level6to7Price);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double level0to3Price,  double level4to5Price,  double level6to7Price)  $default,) {final _that = this;
switch (_that) {
case _SambalSettings():
return $default(_that.level0to3Price,_that.level4to5Price,_that.level6to7Price);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double level0to3Price,  double level4to5Price,  double level6to7Price)?  $default,) {final _that = this;
switch (_that) {
case _SambalSettings() when $default != null:
return $default(_that.level0to3Price,_that.level4to5Price,_that.level6to7Price);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SambalSettings extends SambalSettings {
  const _SambalSettings({this.level0to3Price = 0, this.level4to5Price = 500, this.level6to7Price = 1000}): super._();
  factory _SambalSettings.fromJson(Map<String, dynamic> json) => _$SambalSettingsFromJson(json);

@override@JsonKey() final  double level0to3Price;
@override@JsonKey() final  double level4to5Price;
@override@JsonKey() final  double level6to7Price;

/// Create a copy of SambalSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SambalSettingsCopyWith<_SambalSettings> get copyWith => __$SambalSettingsCopyWithImpl<_SambalSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SambalSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SambalSettings&&(identical(other.level0to3Price, level0to3Price) || other.level0to3Price == level0to3Price)&&(identical(other.level4to5Price, level4to5Price) || other.level4to5Price == level4to5Price)&&(identical(other.level6to7Price, level6to7Price) || other.level6to7Price == level6to7Price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level0to3Price,level4to5Price,level6to7Price);

@override
String toString() {
  return 'SambalSettings(level0to3Price: $level0to3Price, level4to5Price: $level4to5Price, level6to7Price: $level6to7Price)';
}


}

/// @nodoc
abstract mixin class _$SambalSettingsCopyWith<$Res> implements $SambalSettingsCopyWith<$Res> {
  factory _$SambalSettingsCopyWith(_SambalSettings value, $Res Function(_SambalSettings) _then) = __$SambalSettingsCopyWithImpl;
@override @useResult
$Res call({
 double level0to3Price, double level4to5Price, double level6to7Price
});




}
/// @nodoc
class __$SambalSettingsCopyWithImpl<$Res>
    implements _$SambalSettingsCopyWith<$Res> {
  __$SambalSettingsCopyWithImpl(this._self, this._then);

  final _SambalSettings _self;
  final $Res Function(_SambalSettings) _then;

/// Create a copy of SambalSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level0to3Price = null,Object? level4to5Price = null,Object? level6to7Price = null,}) {
  return _then(_SambalSettings(
level0to3Price: null == level0to3Price ? _self.level0to3Price : level0to3Price // ignore: cast_nullable_to_non_nullable
as double,level4to5Price: null == level4to5Price ? _self.level4to5Price : level4to5Price // ignore: cast_nullable_to_non_nullable
as double,level6to7Price: null == level6to7Price ? _self.level6to7Price : level6to7Price // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
