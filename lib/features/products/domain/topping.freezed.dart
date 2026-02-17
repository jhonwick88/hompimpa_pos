// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topping.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Topping {

 String get id; String get name; double get price; int get stock; String? get imageUrl; bool get isActive;
/// Create a copy of Topping
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToppingCopyWith<Topping> get copyWith => _$ToppingCopyWithImpl<Topping>(this as Topping, _$identity);

  /// Serializes this Topping to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Topping&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,stock,imageUrl,isActive);

@override
String toString() {
  return 'Topping(id: $id, name: $name, price: $price, stock: $stock, imageUrl: $imageUrl, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $ToppingCopyWith<$Res>  {
  factory $ToppingCopyWith(Topping value, $Res Function(Topping) _then) = _$ToppingCopyWithImpl;
@useResult
$Res call({
 String id, String name, double price, int stock, String? imageUrl, bool isActive
});




}
/// @nodoc
class _$ToppingCopyWithImpl<$Res>
    implements $ToppingCopyWith<$Res> {
  _$ToppingCopyWithImpl(this._self, this._then);

  final Topping _self;
  final $Res Function(Topping) _then;

/// Create a copy of Topping
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = null,Object? stock = null,Object? imageUrl = freezed,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Topping].
extension ToppingPatterns on Topping {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Topping value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Topping() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Topping value)  $default,){
final _that = this;
switch (_that) {
case _Topping():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Topping value)?  $default,){
final _that = this;
switch (_that) {
case _Topping() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double price,  int stock,  String? imageUrl,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Topping() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.stock,_that.imageUrl,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double price,  int stock,  String? imageUrl,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _Topping():
return $default(_that.id,_that.name,_that.price,_that.stock,_that.imageUrl,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double price,  int stock,  String? imageUrl,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _Topping() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.stock,_that.imageUrl,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Topping implements Topping {
  const _Topping({required this.id, required this.name, required this.price, required this.stock, this.imageUrl, this.isActive = true});
  factory _Topping.fromJson(Map<String, dynamic> json) => _$ToppingFromJson(json);

@override final  String id;
@override final  String name;
@override final  double price;
@override final  int stock;
@override final  String? imageUrl;
@override@JsonKey() final  bool isActive;

/// Create a copy of Topping
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToppingCopyWith<_Topping> get copyWith => __$ToppingCopyWithImpl<_Topping>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ToppingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Topping&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,stock,imageUrl,isActive);

@override
String toString() {
  return 'Topping(id: $id, name: $name, price: $price, stock: $stock, imageUrl: $imageUrl, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$ToppingCopyWith<$Res> implements $ToppingCopyWith<$Res> {
  factory _$ToppingCopyWith(_Topping value, $Res Function(_Topping) _then) = __$ToppingCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double price, int stock, String? imageUrl, bool isActive
});




}
/// @nodoc
class __$ToppingCopyWithImpl<$Res>
    implements _$ToppingCopyWith<$Res> {
  __$ToppingCopyWithImpl(this._self, this._then);

  final _Topping _self;
  final $Res Function(_Topping) _then;

/// Create a copy of Topping
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = null,Object? stock = null,Object? imageUrl = freezed,Object? isActive = null,}) {
  return _then(_Topping(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
