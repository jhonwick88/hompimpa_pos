// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nota_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotaSettings {

 String get storeName; String get tagline; String get address1; String get address2; String get phone; String get footerMessage;
/// Create a copy of NotaSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotaSettingsCopyWith<NotaSettings> get copyWith => _$NotaSettingsCopyWithImpl<NotaSettings>(this as NotaSettings, _$identity);

  /// Serializes this NotaSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotaSettings&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.address1, address1) || other.address1 == address1)&&(identical(other.address2, address2) || other.address2 == address2)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.footerMessage, footerMessage) || other.footerMessage == footerMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,storeName,tagline,address1,address2,phone,footerMessage);

@override
String toString() {
  return 'NotaSettings(storeName: $storeName, tagline: $tagline, address1: $address1, address2: $address2, phone: $phone, footerMessage: $footerMessage)';
}


}

/// @nodoc
abstract mixin class $NotaSettingsCopyWith<$Res>  {
  factory $NotaSettingsCopyWith(NotaSettings value, $Res Function(NotaSettings) _then) = _$NotaSettingsCopyWithImpl;
@useResult
$Res call({
 String storeName, String tagline, String address1, String address2, String phone, String footerMessage
});




}
/// @nodoc
class _$NotaSettingsCopyWithImpl<$Res>
    implements $NotaSettingsCopyWith<$Res> {
  _$NotaSettingsCopyWithImpl(this._self, this._then);

  final NotaSettings _self;
  final $Res Function(NotaSettings) _then;

/// Create a copy of NotaSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? storeName = null,Object? tagline = null,Object? address1 = null,Object? address2 = null,Object? phone = null,Object? footerMessage = null,}) {
  return _then(_self.copyWith(
storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,tagline: null == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String,address1: null == address1 ? _self.address1 : address1 // ignore: cast_nullable_to_non_nullable
as String,address2: null == address2 ? _self.address2 : address2 // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,footerMessage: null == footerMessage ? _self.footerMessage : footerMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NotaSettings].
extension NotaSettingsPatterns on NotaSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotaSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotaSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotaSettings value)  $default,){
final _that = this;
switch (_that) {
case _NotaSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotaSettings value)?  $default,){
final _that = this;
switch (_that) {
case _NotaSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String storeName,  String tagline,  String address1,  String address2,  String phone,  String footerMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotaSettings() when $default != null:
return $default(_that.storeName,_that.tagline,_that.address1,_that.address2,_that.phone,_that.footerMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String storeName,  String tagline,  String address1,  String address2,  String phone,  String footerMessage)  $default,) {final _that = this;
switch (_that) {
case _NotaSettings():
return $default(_that.storeName,_that.tagline,_that.address1,_that.address2,_that.phone,_that.footerMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String storeName,  String tagline,  String address1,  String address2,  String phone,  String footerMessage)?  $default,) {final _that = this;
switch (_that) {
case _NotaSettings() when $default != null:
return $default(_that.storeName,_that.tagline,_that.address1,_that.address2,_that.phone,_that.footerMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotaSettings implements NotaSettings {
  const _NotaSettings({this.storeName = 'HOMPIMPA', this.tagline = 'Spesialis Mie & Pangsit Level', this.address1 = 'Dsn Bulak 01/05 Ds Nglaban', this.address2 = 'Kec. Loceret Kab. Nganjuk', this.phone = '085934345756', this.footerMessage = 'Terima kasih atas kunjungan Anda'});
  factory _NotaSettings.fromJson(Map<String, dynamic> json) => _$NotaSettingsFromJson(json);

@override@JsonKey() final  String storeName;
@override@JsonKey() final  String tagline;
@override@JsonKey() final  String address1;
@override@JsonKey() final  String address2;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String footerMessage;

/// Create a copy of NotaSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotaSettingsCopyWith<_NotaSettings> get copyWith => __$NotaSettingsCopyWithImpl<_NotaSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotaSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotaSettings&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.address1, address1) || other.address1 == address1)&&(identical(other.address2, address2) || other.address2 == address2)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.footerMessage, footerMessage) || other.footerMessage == footerMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,storeName,tagline,address1,address2,phone,footerMessage);

@override
String toString() {
  return 'NotaSettings(storeName: $storeName, tagline: $tagline, address1: $address1, address2: $address2, phone: $phone, footerMessage: $footerMessage)';
}


}

/// @nodoc
abstract mixin class _$NotaSettingsCopyWith<$Res> implements $NotaSettingsCopyWith<$Res> {
  factory _$NotaSettingsCopyWith(_NotaSettings value, $Res Function(_NotaSettings) _then) = __$NotaSettingsCopyWithImpl;
@override @useResult
$Res call({
 String storeName, String tagline, String address1, String address2, String phone, String footerMessage
});




}
/// @nodoc
class __$NotaSettingsCopyWithImpl<$Res>
    implements _$NotaSettingsCopyWith<$Res> {
  __$NotaSettingsCopyWithImpl(this._self, this._then);

  final _NotaSettings _self;
  final $Res Function(_NotaSettings) _then;

/// Create a copy of NotaSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? storeName = null,Object? tagline = null,Object? address1 = null,Object? address2 = null,Object? phone = null,Object? footerMessage = null,}) {
  return _then(_NotaSettings(
storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,tagline: null == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String,address1: null == address1 ? _self.address1 : address1 // ignore: cast_nullable_to_non_nullable
as String,address2: null == address2 ? _self.address2 : address2 // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,footerMessage: null == footerMessage ? _self.footerMessage : footerMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
