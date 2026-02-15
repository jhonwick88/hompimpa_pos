// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OrderEntity _$OrderEntityFromJson(Map<String, dynamic> json) {
  return _Order.fromJson(json);
}

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
  String? get shiftId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OrderEntityCopyWith<OrderEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderEntityCopyWith<$Res> {
  factory $OrderEntityCopyWith(
          OrderEntity value, $Res Function(OrderEntity) then) =
      _$OrderEntityCopyWithImpl<$Res, OrderEntity>;
  @useResult
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
      double? changeAmount,
      String? shiftId});
}

/// @nodoc
class _$OrderEntityCopyWithImpl<$Res, $Val extends OrderEntity>
    implements $OrderEntityCopyWith<$Res> {
  _$OrderEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? customerPhone = freezed,
    Object? total = null,
    Object? orderDate = null,
    Object? orderTime = null,
    Object? status = null,
    Object? items = null,
    Object? queueNumber = freezed,
    Object? executorName = freezed,
    Object? executorId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? voidReason = freezed,
    Object? voidBy = freezed,
    Object? voidAt = freezed,
    Object? paymentMethod = null,
    Object? paidAmount = freezed,
    Object? changeAmount = freezed,
    Object? shiftId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: freezed == customerPhone
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      orderDate: null == orderDate
          ? _value.orderDate
          : orderDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      orderTime: null == orderTime
          ? _value.orderTime
          : orderTime // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      queueNumber: freezed == queueNumber
          ? _value.queueNumber
          : queueNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      executorName: freezed == executorName
          ? _value.executorName
          : executorName // ignore: cast_nullable_to_non_nullable
              as String?,
      executorId: freezed == executorId
          ? _value.executorId
          : executorId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      voidReason: freezed == voidReason
          ? _value.voidReason
          : voidReason // ignore: cast_nullable_to_non_nullable
              as String?,
      voidBy: freezed == voidBy
          ? _value.voidBy
          : voidBy // ignore: cast_nullable_to_non_nullable
              as String?,
      voidAt: freezed == voidAt
          ? _value.voidAt
          : voidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      paidAmount: freezed == paidAmount
          ? _value.paidAmount
          : paidAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      changeAmount: freezed == changeAmount
          ? _value.changeAmount
          : changeAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      shiftId: freezed == shiftId
          ? _value.shiftId
          : shiftId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderImplCopyWith<$Res>
    implements $OrderEntityCopyWith<$Res> {
  factory _$$OrderImplCopyWith(
          _$OrderImpl value, $Res Function(_$OrderImpl) then) =
      __$$OrderImplCopyWithImpl<$Res>;
  @override
  @useResult
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
      double? changeAmount,
      String? shiftId});
}

/// @nodoc
class __$$OrderImplCopyWithImpl<$Res>
    extends _$OrderEntityCopyWithImpl<$Res, _$OrderImpl>
    implements _$$OrderImplCopyWith<$Res> {
  __$$OrderImplCopyWithImpl(
      _$OrderImpl _value, $Res Function(_$OrderImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? customerPhone = freezed,
    Object? total = null,
    Object? orderDate = null,
    Object? orderTime = null,
    Object? status = null,
    Object? items = null,
    Object? queueNumber = freezed,
    Object? executorName = freezed,
    Object? executorId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? voidReason = freezed,
    Object? voidBy = freezed,
    Object? voidAt = freezed,
    Object? paymentMethod = null,
    Object? paidAmount = freezed,
    Object? changeAmount = freezed,
    Object? shiftId = freezed,
  }) {
    return _then(_$OrderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: freezed == customerPhone
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      orderDate: null == orderDate
          ? _value.orderDate
          : orderDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      orderTime: null == orderTime
          ? _value.orderTime
          : orderTime // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      queueNumber: freezed == queueNumber
          ? _value.queueNumber
          : queueNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      executorName: freezed == executorName
          ? _value.executorName
          : executorName // ignore: cast_nullable_to_non_nullable
              as String?,
      executorId: freezed == executorId
          ? _value.executorId
          : executorId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      voidReason: freezed == voidReason
          ? _value.voidReason
          : voidReason // ignore: cast_nullable_to_non_nullable
              as String?,
      voidBy: freezed == voidBy
          ? _value.voidBy
          : voidBy // ignore: cast_nullable_to_non_nullable
              as String?,
      voidAt: freezed == voidAt
          ? _value.voidAt
          : voidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      paidAmount: freezed == paidAmount
          ? _value.paidAmount
          : paidAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      changeAmount: freezed == changeAmount
          ? _value.changeAmount
          : changeAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      shiftId: freezed == shiftId
          ? _value.shiftId
          : shiftId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$OrderImpl implements _Order {
  const _$OrderImpl(
      {required this.id,
      this.customerName = 'Guest',
      this.customerPhone,
      required this.total,
      @TimestampConverter() required this.orderDate,
      required this.orderTime,
      this.status = OrderStatus.belum,
      required final List<OrderItem> items,
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
      this.changeAmount,
      this.shiftId})
      : _items = items;

  factory _$OrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String customerName;
  @override
  final String? customerPhone;
  @override
  final double total;
  @override
  @TimestampConverter()
  final DateTime orderDate;
// "tanggal"
  @override
  final String orderTime;
// "jam"
  @override
  @JsonKey()
  final OrderStatus status;
  final List<OrderItem> _items;
  @override
  List<OrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int? queueNumber;
// Queue number for order tracking
  @override
  final String? executorName;
// Name of the user who processed the order
  @override
  final String? executorId;
// ID of the user who processed the order
  @override
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
  @override
  @JsonKey()
  final String paymentMethod;
  @override
  final double? paidAmount;
  @override
  final double? changeAmount;
  @override
  final String? shiftId;

  @override
  String toString() {
    return 'OrderEntity(id: $id, customerName: $customerName, customerPhone: $customerPhone, total: $total, orderDate: $orderDate, orderTime: $orderTime, status: $status, items: $items, queueNumber: $queueNumber, executorName: $executorName, executorId: $executorId, createdAt: $createdAt, updatedAt: $updatedAt, voidReason: $voidReason, voidBy: $voidBy, voidAt: $voidAt, paymentMethod: $paymentMethod, paidAmount: $paidAmount, changeAmount: $changeAmount, shiftId: $shiftId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.orderDate, orderDate) ||
                other.orderDate == orderDate) &&
            (identical(other.orderTime, orderTime) ||
                other.orderTime == orderTime) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.queueNumber, queueNumber) ||
                other.queueNumber == queueNumber) &&
            (identical(other.executorName, executorName) ||
                other.executorName == executorName) &&
            (identical(other.executorId, executorId) ||
                other.executorId == executorId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.voidReason, voidReason) ||
                other.voidReason == voidReason) &&
            (identical(other.voidBy, voidBy) || other.voidBy == voidBy) &&
            (identical(other.voidAt, voidAt) || other.voidAt == voidAt) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.paidAmount, paidAmount) ||
                other.paidAmount == paidAmount) &&
            (identical(other.changeAmount, changeAmount) ||
                other.changeAmount == changeAmount) &&
            (identical(other.shiftId, shiftId) || other.shiftId == shiftId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        customerName,
        customerPhone,
        total,
        orderDate,
        orderTime,
        status,
        const DeepCollectionEquality().hash(_items),
        queueNumber,
        executorName,
        executorId,
        createdAt,
        updatedAt,
        voidReason,
        voidBy,
        voidAt,
        paymentMethod,
        paidAmount,
        changeAmount,
        shiftId
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      __$$OrderImplCopyWithImpl<_$OrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderImplToJson(
      this,
    );
  }
}

abstract class _Order implements OrderEntity {
  const factory _Order(
      {required final String id,
      final String customerName,
      final String? customerPhone,
      required final double total,
      @TimestampConverter() required final DateTime orderDate,
      required final String orderTime,
      final OrderStatus status,
      required final List<OrderItem> items,
      final int? queueNumber,
      final String? executorName,
      final String? executorId,
      @TimestampNullableConverter() final DateTime? createdAt,
      @TimestampNullableConverter() final DateTime? updatedAt,
      final String? voidReason,
      final String? voidBy,
      @TimestampNullableConverter() final DateTime? voidAt,
      final String paymentMethod,
      final double? paidAmount,
      final double? changeAmount,
      final String? shiftId}) = _$OrderImpl;

  factory _Order.fromJson(Map<String, dynamic> json) = _$OrderImpl.fromJson;

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
  String? get shiftId;
  @override
  @JsonKey(ignore: true)
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
