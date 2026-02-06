// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'topping.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Topping _$ToppingFromJson(Map<String, dynamic> json) {
  return _Topping.fromJson(json);
}

/// @nodoc
class _$ToppingTearOff {
  const _$ToppingTearOff();

  _Topping call(
      {required String id,
      required String name,
      required double price,
      required int stock,
      bool isActive = true}) {
    return _Topping(
      id: id,
      name: name,
      price: price,
      stock: stock,
      isActive: isActive,
    );
  }

  Topping fromJson(Map<String, Object?> json) {
    return Topping.fromJson(json);
  }
}

/// @nodoc
const $Topping = _$ToppingTearOff();

/// @nodoc
mixin _$Topping {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int get stock => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ToppingCopyWith<Topping> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ToppingCopyWith<$Res> {
  factory $ToppingCopyWith(Topping value, $Res Function(Topping) then) =
      _$ToppingCopyWithImpl<$Res>;
  $Res call({String id, String name, double price, int stock, bool isActive});
}

/// @nodoc
class _$ToppingCopyWithImpl<$Res> implements $ToppingCopyWith<$Res> {
  _$ToppingCopyWithImpl(this._value, this._then);

  final Topping _value;
  // ignore: unused_field
  final $Res Function(Topping) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? price = freezed,
    Object? stock = freezed,
    Object? isActive = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: price == freezed
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      stock: stock == freezed
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: isActive == freezed
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
abstract class _$ToppingCopyWith<$Res> implements $ToppingCopyWith<$Res> {
  factory _$ToppingCopyWith(_Topping value, $Res Function(_Topping) then) =
      __$ToppingCopyWithImpl<$Res>;
  @override
  $Res call({String id, String name, double price, int stock, bool isActive});
}

/// @nodoc
class __$ToppingCopyWithImpl<$Res> extends _$ToppingCopyWithImpl<$Res>
    implements _$ToppingCopyWith<$Res> {
  __$ToppingCopyWithImpl(_Topping _value, $Res Function(_Topping) _then)
      : super(_value, (v) => _then(v as _Topping));

  @override
  _Topping get _value => super._value as _Topping;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? price = freezed,
    Object? stock = freezed,
    Object? isActive = freezed,
  }) {
    return _then(_Topping(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: price == freezed
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      stock: stock == freezed
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: isActive == freezed
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Topping implements _Topping {
  const _$_Topping(
      {required this.id,
      required this.name,
      required this.price,
      required this.stock,
      this.isActive = true});

  factory _$_Topping.fromJson(Map<String, dynamic> json) =>
      _$$_ToppingFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double price;
  @override
  final int stock;
  @JsonKey()
  @override
  final bool isActive;

  @override
  String toString() {
    return 'Topping(id: $id, name: $name, price: $price, stock: $stock, isActive: $isActive)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Topping &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.price, price) &&
            const DeepCollectionEquality().equals(other.stock, stock) &&
            const DeepCollectionEquality().equals(other.isActive, isActive));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(price),
      const DeepCollectionEquality().hash(stock),
      const DeepCollectionEquality().hash(isActive));

  @JsonKey(ignore: true)
  @override
  _$ToppingCopyWith<_Topping> get copyWith =>
      __$ToppingCopyWithImpl<_Topping>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ToppingToJson(this);
  }
}

abstract class _Topping implements Topping {
  const factory _Topping(
      {required String id,
      required String name,
      required double price,
      required int stock,
      bool isActive}) = _$_Topping;

  factory _Topping.fromJson(Map<String, dynamic> json) = _$_Topping.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get price;
  @override
  int get stock;
  @override
  bool get isActive;
  @override
  @JsonKey(ignore: true)
  _$ToppingCopyWith<_Topping> get copyWith =>
      throw _privateConstructorUsedError;
}
