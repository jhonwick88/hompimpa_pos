// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topping.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Topping _$ToppingFromJson(Map<String, dynamic> json) {
  return _Topping.fromJson(json);
}

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
      _$ToppingCopyWithImpl<$Res, Topping>;
  @useResult
  $Res call({String id, String name, double price, int stock, bool isActive});
}

/// @nodoc
class _$ToppingCopyWithImpl<$Res, $Val extends Topping>
    implements $ToppingCopyWith<$Res> {
  _$ToppingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? price = null,
    Object? stock = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      stock: null == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ToppingImplCopyWith<$Res> implements $ToppingCopyWith<$Res> {
  factory _$$ToppingImplCopyWith(
          _$ToppingImpl value, $Res Function(_$ToppingImpl) then) =
      __$$ToppingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, double price, int stock, bool isActive});
}

/// @nodoc
class __$$ToppingImplCopyWithImpl<$Res>
    extends _$ToppingCopyWithImpl<$Res, _$ToppingImpl>
    implements _$$ToppingImplCopyWith<$Res> {
  __$$ToppingImplCopyWithImpl(
      _$ToppingImpl _value, $Res Function(_$ToppingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? price = null,
    Object? stock = null,
    Object? isActive = null,
  }) {
    return _then(_$ToppingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      stock: null == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ToppingImpl implements _Topping {
  const _$ToppingImpl(
      {required this.id,
      required this.name,
      required this.price,
      required this.stock,
      this.isActive = true});

  factory _$ToppingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ToppingImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double price;
  @override
  final int stock;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'Topping(id: $id, name: $name, price: $price, stock: $stock, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToppingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, price, stock, isActive);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ToppingImplCopyWith<_$ToppingImpl> get copyWith =>
      __$$ToppingImplCopyWithImpl<_$ToppingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ToppingImplToJson(
      this,
    );
  }
}

abstract class _Topping implements Topping {
  const factory _Topping(
      {required final String id,
      required final String name,
      required final double price,
      required final int stock,
      final bool isActive}) = _$ToppingImpl;

  factory _Topping.fromJson(Map<String, dynamic> json) = _$ToppingImpl.fromJson;

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
  _$$ToppingImplCopyWith<_$ToppingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
