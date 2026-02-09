// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

OrderEntity _$OrderEntityFromJson(Map<String, dynamic> json) {
  return _Order.fromJson(json);
}

/// @nodoc
class _$OrderEntityTearOff {
  const _$OrderEntityTearOff();

  _Order call(
      {required String id,
      String customerName = 'Guest',
      String? customerPhone,
      required double total,
      @TimestampConverter() required DateTime orderDate,
      required String orderTime,
      OrderStatus status = OrderStatus.belum,
      required List<OrderItem> items,
      int? queueNumber,
      String? executorName,
      String? executorId,
      @TimestampNullableConverter() DateTime? createdAt,
      @TimestampNullableConverter() DateTime? updatedAt,
      String? voidReason,
      String? voidBy,
      @TimestampNullableConverter() DateTime? voidAt,
      String paymentMethod = 'Cash',
      double? paidAmount,
      double? changeAmount}) {
    return _Order(
      id: id,
      customerName: customerName,
      customerPhone: customerPhone,
      total: total,
      orderDate: orderDate,
      orderTime: orderTime,
      status: status,
      items: items,
      queueNumber: queueNumber,
      executorName: executorName,
      executorId: executorId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      voidReason: voidReason,
      voidBy: voidBy,
      voidAt: voidAt,
      paymentMethod: paymentMethod,
      paidAmount: paidAmount,
      changeAmount: changeAmount,
    );
  }

  OrderEntity fromJson(Map<String, Object?> json) {
    return OrderEntity.fromJson(json);
  }
}

/// @nodoc
const $OrderEntity = _$OrderEntityTearOff();

/// @nodoc
mixin _$OrderEntity {
  String get id => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String? get customerPhone => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get orderDate => throw _privateConstructorUsedError; // "tanggal"
  String get orderTime => throw _privateConstructorUsedError; // "jam"
  OrderStatus get status => throw _privateConstructorUsedError;
  List<OrderItem> get items => throw _privateConstructorUsedError;
  int? get queueNumber =>
      throw _privateConstructorUsedError; // Queue number for order tracking
  String? get executorName =>
      throw _privateConstructorUsedError; // Name of the user who processed the order
  String? get executorId =>
      throw _privateConstructorUsedError; // ID of the user who processed the order
  @TimestampNullableConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampNullableConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get voidReason => throw _privateConstructorUsedError;
  String? get voidBy => throw _privateConstructorUsedError;
  @TimestampNullableConverter()
  DateTime? get voidAt => throw _privateConstructorUsedError;
  String get paymentMethod => throw _privateConstructorUsedError;
  double? get paidAmount => throw _privateConstructorUsedError;
  double? get changeAmount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OrderEntityCopyWith<OrderEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderEntityCopyWith<$Res> {
  factory $OrderEntityCopyWith(
          OrderEntity value, $Res Function(OrderEntity) then) =
      _$OrderEntityCopyWithImpl<$Res>;
  $Res call(
      {String id,
      String customerName,
      String? customerPhone,
      double total,
      @TimestampConverter() DateTime orderDate,
      String orderTime,
      OrderStatus status,
      List<OrderItem> items,
      int? queueNumber,
      String? executorName,
      String? executorId,
      @TimestampNullableConverter() DateTime? createdAt,
      @TimestampNullableConverter() DateTime? updatedAt,
      String? voidReason,
      String? voidBy,
      @TimestampNullableConverter() DateTime? voidAt,
      String paymentMethod,
      double? paidAmount,
      double? changeAmount});
}

/// @nodoc
class _$OrderEntityCopyWithImpl<$Res> implements $OrderEntityCopyWith<$Res> {
  _$OrderEntityCopyWithImpl(this._value, this._then);

  final OrderEntity _value;
  // ignore: unused_field
  final $Res Function(OrderEntity) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? total = freezed,
    Object? orderDate = freezed,
    Object? orderTime = freezed,
    Object? status = freezed,
    Object? items = freezed,
    Object? queueNumber = freezed,
    Object? executorName = freezed,
    Object? executorId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? voidReason = freezed,
    Object? voidBy = freezed,
    Object? voidAt = freezed,
    Object? paymentMethod = freezed,
    Object? paidAmount = freezed,
    Object? changeAmount = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: customerName == freezed
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: customerPhone == freezed
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      total: total == freezed
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      orderDate: orderDate == freezed
          ? _value.orderDate
          : orderDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      orderTime: orderTime == freezed
          ? _value.orderTime
          : orderTime // ignore: cast_nullable_to_non_nullable
              as String,
      status: status == freezed
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      items: items == freezed
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      queueNumber: queueNumber == freezed
          ? _value.queueNumber
          : queueNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      executorName: executorName == freezed
          ? _value.executorName
          : executorName // ignore: cast_nullable_to_non_nullable
              as String?,
      executorId: executorId == freezed
          ? _value.executorId
          : executorId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      voidReason: voidReason == freezed
          ? _value.voidReason
          : voidReason // ignore: cast_nullable_to_non_nullable
              as String?,
      voidBy: voidBy == freezed
          ? _value.voidBy
          : voidBy // ignore: cast_nullable_to_non_nullable
              as String?,
      voidAt: voidAt == freezed
          ? _value.voidAt
          : voidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentMethod: paymentMethod == freezed
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      paidAmount: paidAmount == freezed
          ? _value.paidAmount
          : paidAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      changeAmount: changeAmount == freezed
          ? _value.changeAmount
          : changeAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
abstract class _$OrderCopyWith<$Res> implements $OrderEntityCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) then) =
      __$OrderCopyWithImpl<$Res>;
  @override
  $Res call(
      {String id,
      String customerName,
      String? customerPhone,
      double total,
      @TimestampConverter() DateTime orderDate,
      String orderTime,
      OrderStatus status,
      List<OrderItem> items,
      int? queueNumber,
      String? executorName,
      String? executorId,
      @TimestampNullableConverter() DateTime? createdAt,
      @TimestampNullableConverter() DateTime? updatedAt,
      String? voidReason,
      String? voidBy,
      @TimestampNullableConverter() DateTime? voidAt,
      String paymentMethod,
      double? paidAmount,
      double? changeAmount});
}

/// @nodoc
class __$OrderCopyWithImpl<$Res> extends _$OrderEntityCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(_Order _value, $Res Function(_Order) _then)
      : super(_value, (v) => _then(v as _Order));

  @override
  _Order get _value => super._value as _Order;

  @override
  $Res call({
    Object? id = freezed,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? total = freezed,
    Object? orderDate = freezed,
    Object? orderTime = freezed,
    Object? status = freezed,
    Object? items = freezed,
    Object? queueNumber = freezed,
    Object? executorName = freezed,
    Object? executorId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? voidReason = freezed,
    Object? voidBy = freezed,
    Object? voidAt = freezed,
    Object? paymentMethod = freezed,
    Object? paidAmount = freezed,
    Object? changeAmount = freezed,
  }) {
    return _then(_Order(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: customerName == freezed
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: customerPhone == freezed
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      total: total == freezed
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      orderDate: orderDate == freezed
          ? _value.orderDate
          : orderDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      orderTime: orderTime == freezed
          ? _value.orderTime
          : orderTime // ignore: cast_nullable_to_non_nullable
              as String,
      status: status == freezed
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      items: items == freezed
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      queueNumber: queueNumber == freezed
          ? _value.queueNumber
          : queueNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      executorName: executorName == freezed
          ? _value.executorName
          : executorName // ignore: cast_nullable_to_non_nullable
              as String?,
      executorId: executorId == freezed
          ? _value.executorId
          : executorId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      voidReason: voidReason == freezed
          ? _value.voidReason
          : voidReason // ignore: cast_nullable_to_non_nullable
              as String?,
      voidBy: voidBy == freezed
          ? _value.voidBy
          : voidBy // ignore: cast_nullable_to_non_nullable
              as String?,
      voidAt: voidAt == freezed
          ? _value.voidAt
          : voidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentMethod: paymentMethod == freezed
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      paidAmount: paidAmount == freezed
          ? _value.paidAmount
          : paidAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      changeAmount: changeAmount == freezed
          ? _value.changeAmount
          : changeAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_Order implements _Order {
  const _$_Order(
      {required this.id,
      this.customerName = 'Guest',
      this.customerPhone,
      required this.total,
      @TimestampConverter() required this.orderDate,
      required this.orderTime,
      this.status = OrderStatus.belum,
      required this.items,
      this.queueNumber,
      this.executorName,
      this.executorId,
      @TimestampNullableConverter() this.createdAt,
      @TimestampNullableConverter() this.updatedAt,
      this.voidReason,
      this.voidBy,
      @TimestampNullableConverter() this.voidAt,
      this.paymentMethod = 'Cash',
      this.paidAmount,
      this.changeAmount});

  factory _$_Order.fromJson(Map<String, dynamic> json) =>
      _$$_OrderFromJson(json);

  @override
  final String id;
  @JsonKey()
  @override
  final String customerName;
  @override
  final String? customerPhone;
  @override
  final double total;
  @override
  @TimestampConverter()
  final DateTime orderDate;
  @override // "tanggal"
  final String orderTime;
  @JsonKey()
  @override // "jam"
  final OrderStatus status;
  @override
  final List<OrderItem> items;
  @override
  final int? queueNumber;
  @override // Queue number for order tracking
  final String? executorName;
  @override // Name of the user who processed the order
  final String? executorId;
  @override // ID of the user who processed the order
  @TimestampNullableConverter()
  final DateTime? createdAt;
  @override
  @TimestampNullableConverter()
  final DateTime? updatedAt;
  @override
  final String? voidReason;
  @override
  final String? voidBy;
  @override
  @TimestampNullableConverter()
  final DateTime? voidAt;
  @JsonKey()
  @override
  final String paymentMethod;
  @override
  final double? paidAmount;
  @override
  final double? changeAmount;

  @override
  String toString() {
    return 'OrderEntity(id: $id, customerName: $customerName, customerPhone: $customerPhone, total: $total, orderDate: $orderDate, orderTime: $orderTime, status: $status, items: $items, queueNumber: $queueNumber, executorName: $executorName, executorId: $executorId, createdAt: $createdAt, updatedAt: $updatedAt, voidReason: $voidReason, voidBy: $voidBy, voidAt: $voidAt, paymentMethod: $paymentMethod, paidAmount: $paidAmount, changeAmount: $changeAmount)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Order &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality()
                .equals(other.customerName, customerName) &&
            const DeepCollectionEquality()
                .equals(other.customerPhone, customerPhone) &&
            const DeepCollectionEquality().equals(other.total, total) &&
            const DeepCollectionEquality().equals(other.orderDate, orderDate) &&
            const DeepCollectionEquality().equals(other.orderTime, orderTime) &&
            const DeepCollectionEquality().equals(other.status, status) &&
            const DeepCollectionEquality().equals(other.items, items) &&
            const DeepCollectionEquality()
                .equals(other.queueNumber, queueNumber) &&
            const DeepCollectionEquality()
                .equals(other.executorName, executorName) &&
            const DeepCollectionEquality()
                .equals(other.executorId, executorId) &&
            const DeepCollectionEquality().equals(other.createdAt, createdAt) &&
            const DeepCollectionEquality().equals(other.updatedAt, updatedAt) &&
            const DeepCollectionEquality()
                .equals(other.voidReason, voidReason) &&
            const DeepCollectionEquality().equals(other.voidBy, voidBy) &&
            const DeepCollectionEquality().equals(other.voidAt, voidAt) &&
            const DeepCollectionEquality()
                .equals(other.paymentMethod, paymentMethod) &&
            const DeepCollectionEquality()
                .equals(other.paidAmount, paidAmount) &&
            const DeepCollectionEquality()
                .equals(other.changeAmount, changeAmount));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        const DeepCollectionEquality().hash(id),
        const DeepCollectionEquality().hash(customerName),
        const DeepCollectionEquality().hash(customerPhone),
        const DeepCollectionEquality().hash(total),
        const DeepCollectionEquality().hash(orderDate),
        const DeepCollectionEquality().hash(orderTime),
        const DeepCollectionEquality().hash(status),
        const DeepCollectionEquality().hash(items),
        const DeepCollectionEquality().hash(queueNumber),
        const DeepCollectionEquality().hash(executorName),
        const DeepCollectionEquality().hash(executorId),
        const DeepCollectionEquality().hash(createdAt),
        const DeepCollectionEquality().hash(updatedAt),
        const DeepCollectionEquality().hash(voidReason),
        const DeepCollectionEquality().hash(voidBy),
        const DeepCollectionEquality().hash(voidAt),
        const DeepCollectionEquality().hash(paymentMethod),
        const DeepCollectionEquality().hash(paidAmount),
        const DeepCollectionEquality().hash(changeAmount)
      ]);

  @JsonKey(ignore: true)
  @override
  _$OrderCopyWith<_Order> get copyWith =>
      __$OrderCopyWithImpl<_Order>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_OrderToJson(this);
  }
}

abstract class _Order implements OrderEntity {
  const factory _Order(
      {required String id,
      String customerName,
      String? customerPhone,
      required double total,
      @TimestampConverter() required DateTime orderDate,
      required String orderTime,
      OrderStatus status,
      required List<OrderItem> items,
      int? queueNumber,
      String? executorName,
      String? executorId,
      @TimestampNullableConverter() DateTime? createdAt,
      @TimestampNullableConverter() DateTime? updatedAt,
      String? voidReason,
      String? voidBy,
      @TimestampNullableConverter() DateTime? voidAt,
      String paymentMethod,
      double? paidAmount,
      double? changeAmount}) = _$_Order;

  factory _Order.fromJson(Map<String, dynamic> json) = _$_Order.fromJson;

  @override
  String get id;
  @override
  String get customerName;
  @override
  String? get customerPhone;
  @override
  double get total;
  @override
  @TimestampConverter()
  DateTime get orderDate;
  @override // "tanggal"
  String get orderTime;
  @override // "jam"
  OrderStatus get status;
  @override
  List<OrderItem> get items;
  @override
  int? get queueNumber;
  @override // Queue number for order tracking
  String? get executorName;
  @override // Name of the user who processed the order
  String? get executorId;
  @override // ID of the user who processed the order
  @TimestampNullableConverter()
  DateTime? get createdAt;
  @override
  @TimestampNullableConverter()
  DateTime? get updatedAt;
  @override
  String? get voidReason;
  @override
  String? get voidBy;
  @override
  @TimestampNullableConverter()
  DateTime? get voidAt;
  @override
  String get paymentMethod;
  @override
  double? get paidAmount;
  @override
  double? get changeAmount;
  @override
  @JsonKey(ignore: true)
  _$OrderCopyWith<_Order> get copyWith => throw _privateConstructorUsedError;
}
