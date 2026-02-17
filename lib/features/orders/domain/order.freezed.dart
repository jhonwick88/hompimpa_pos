// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
OrderEntity _$OrderEntityFromJson(
  Map<String, dynamic> json
) {
    return _Order.fromJson(
      json
    );
}

/// @nodoc
mixin _$OrderEntity {

 String get id; String get customerName; String? get customerPhone; double get total;@TimestampConverter() DateTime get orderDate;// "tanggal"
 String get orderTime;// "jam"
 OrderStatus get status; List<OrderItem> get items; int? get queueNumber;// Queue number for order tracking
 String? get executorName;// Name of the user who processed the order
 String? get executorId;// ID of the user who processed the order
@TimestampNullableConverter() DateTime? get createdAt;@TimestampNullableConverter() DateTime? get updatedAt; String? get voidReason; String? get voidBy;@TimestampNullableConverter() DateTime? get voidAt; String get paymentMethod; double? get paidAmount; double? get changeAmount; String? get shiftId;
/// Create a copy of OrderEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderEntityCopyWith<OrderEntity> get copyWith => _$OrderEntityCopyWithImpl<OrderEntity>(this as OrderEntity, _$identity);

  /// Serializes this OrderEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.total, total) || other.total == total)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.orderTime, orderTime) || other.orderTime == orderTime)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.queueNumber, queueNumber) || other.queueNumber == queueNumber)&&(identical(other.executorName, executorName) || other.executorName == executorName)&&(identical(other.executorId, executorId) || other.executorId == executorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.voidReason, voidReason) || other.voidReason == voidReason)&&(identical(other.voidBy, voidBy) || other.voidBy == voidBy)&&(identical(other.voidAt, voidAt) || other.voidAt == voidAt)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.changeAmount, changeAmount) || other.changeAmount == changeAmount)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,customerName,customerPhone,total,orderDate,orderTime,status,const DeepCollectionEquality().hash(items),queueNumber,executorName,executorId,createdAt,updatedAt,voidReason,voidBy,voidAt,paymentMethod,paidAmount,changeAmount,shiftId]);

@override
String toString() {
  return 'OrderEntity(id: $id, customerName: $customerName, customerPhone: $customerPhone, total: $total, orderDate: $orderDate, orderTime: $orderTime, status: $status, items: $items, queueNumber: $queueNumber, executorName: $executorName, executorId: $executorId, createdAt: $createdAt, updatedAt: $updatedAt, voidReason: $voidReason, voidBy: $voidBy, voidAt: $voidAt, paymentMethod: $paymentMethod, paidAmount: $paidAmount, changeAmount: $changeAmount, shiftId: $shiftId)';
}


}

/// @nodoc
abstract mixin class $OrderEntityCopyWith<$Res>  {
  factory $OrderEntityCopyWith(OrderEntity value, $Res Function(OrderEntity) _then) = _$OrderEntityCopyWithImpl;
@useResult
$Res call({
 String id, String customerName, String? customerPhone, double total,@TimestampConverter() DateTime orderDate, String orderTime, OrderStatus status, List<OrderItem> items, int? queueNumber, String? executorName, String? executorId,@TimestampNullableConverter() DateTime? createdAt,@TimestampNullableConverter() DateTime? updatedAt, String? voidReason, String? voidBy,@TimestampNullableConverter() DateTime? voidAt, String paymentMethod, double? paidAmount, double? changeAmount, String? shiftId
});




}
/// @nodoc
class _$OrderEntityCopyWithImpl<$Res>
    implements $OrderEntityCopyWith<$Res> {
  _$OrderEntityCopyWithImpl(this._self, this._then);

  final OrderEntity _self;
  final $Res Function(OrderEntity) _then;

/// Create a copy of OrderEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerName = null,Object? customerPhone = freezed,Object? total = null,Object? orderDate = null,Object? orderTime = null,Object? status = null,Object? items = null,Object? queueNumber = freezed,Object? executorName = freezed,Object? executorId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? voidReason = freezed,Object? voidBy = freezed,Object? voidAt = freezed,Object? paymentMethod = null,Object? paidAmount = freezed,Object? changeAmount = freezed,Object? shiftId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as DateTime,orderTime: null == orderTime ? _self.orderTime : orderTime // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,queueNumber: freezed == queueNumber ? _self.queueNumber : queueNumber // ignore: cast_nullable_to_non_nullable
as int?,executorName: freezed == executorName ? _self.executorName : executorName // ignore: cast_nullable_to_non_nullable
as String?,executorId: freezed == executorId ? _self.executorId : executorId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,voidReason: freezed == voidReason ? _self.voidReason : voidReason // ignore: cast_nullable_to_non_nullable
as String?,voidBy: freezed == voidBy ? _self.voidBy : voidBy // ignore: cast_nullable_to_non_nullable
as String?,voidAt: freezed == voidAt ? _self.voidAt : voidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,paidAmount: freezed == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double?,changeAmount: freezed == changeAmount ? _self.changeAmount : changeAmount // ignore: cast_nullable_to_non_nullable
as double?,shiftId: freezed == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderEntity].
extension OrderEntityPatterns on OrderEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String customerName,  String? customerPhone,  double total, @TimestampConverter()  DateTime orderDate,  String orderTime,  OrderStatus status,  List<OrderItem> items,  int? queueNumber,  String? executorName,  String? executorId, @TimestampNullableConverter()  DateTime? createdAt, @TimestampNullableConverter()  DateTime? updatedAt,  String? voidReason,  String? voidBy, @TimestampNullableConverter()  DateTime? voidAt,  String paymentMethod,  double? paidAmount,  double? changeAmount,  String? shiftId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.customerName,_that.customerPhone,_that.total,_that.orderDate,_that.orderTime,_that.status,_that.items,_that.queueNumber,_that.executorName,_that.executorId,_that.createdAt,_that.updatedAt,_that.voidReason,_that.voidBy,_that.voidAt,_that.paymentMethod,_that.paidAmount,_that.changeAmount,_that.shiftId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String customerName,  String? customerPhone,  double total, @TimestampConverter()  DateTime orderDate,  String orderTime,  OrderStatus status,  List<OrderItem> items,  int? queueNumber,  String? executorName,  String? executorId, @TimestampNullableConverter()  DateTime? createdAt, @TimestampNullableConverter()  DateTime? updatedAt,  String? voidReason,  String? voidBy, @TimestampNullableConverter()  DateTime? voidAt,  String paymentMethod,  double? paidAmount,  double? changeAmount,  String? shiftId)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.customerName,_that.customerPhone,_that.total,_that.orderDate,_that.orderTime,_that.status,_that.items,_that.queueNumber,_that.executorName,_that.executorId,_that.createdAt,_that.updatedAt,_that.voidReason,_that.voidBy,_that.voidAt,_that.paymentMethod,_that.paidAmount,_that.changeAmount,_that.shiftId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String customerName,  String? customerPhone,  double total, @TimestampConverter()  DateTime orderDate,  String orderTime,  OrderStatus status,  List<OrderItem> items,  int? queueNumber,  String? executorName,  String? executorId, @TimestampNullableConverter()  DateTime? createdAt, @TimestampNullableConverter()  DateTime? updatedAt,  String? voidReason,  String? voidBy, @TimestampNullableConverter()  DateTime? voidAt,  String paymentMethod,  double? paidAmount,  double? changeAmount,  String? shiftId)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.customerName,_that.customerPhone,_that.total,_that.orderDate,_that.orderTime,_that.status,_that.items,_that.queueNumber,_that.executorName,_that.executorId,_that.createdAt,_that.updatedAt,_that.voidReason,_that.voidBy,_that.voidAt,_that.paymentMethod,_that.paidAmount,_that.changeAmount,_that.shiftId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Order implements OrderEntity {
  const _Order({required this.id, this.customerName = 'Guest', this.customerPhone, required this.total, @TimestampConverter() required this.orderDate, required this.orderTime, this.status = OrderStatus.belum, required final  List<OrderItem> items, this.queueNumber, this.executorName, this.executorId, @TimestampNullableConverter() this.createdAt, @TimestampNullableConverter() this.updatedAt, this.voidReason, this.voidBy, @TimestampNullableConverter() this.voidAt, this.paymentMethod = 'Cash', this.paidAmount, this.changeAmount, this.shiftId}): _items = items;
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  String id;
@override@JsonKey() final  String customerName;
@override final  String? customerPhone;
@override final  double total;
@override@TimestampConverter() final  DateTime orderDate;
// "tanggal"
@override final  String orderTime;
// "jam"
@override@JsonKey() final  OrderStatus status;
 final  List<OrderItem> _items;
@override List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int? queueNumber;
// Queue number for order tracking
@override final  String? executorName;
// Name of the user who processed the order
@override final  String? executorId;
// ID of the user who processed the order
@override@TimestampNullableConverter() final  DateTime? createdAt;
@override@TimestampNullableConverter() final  DateTime? updatedAt;
@override final  String? voidReason;
@override final  String? voidBy;
@override@TimestampNullableConverter() final  DateTime? voidAt;
@override@JsonKey() final  String paymentMethod;
@override final  double? paidAmount;
@override final  double? changeAmount;
@override final  String? shiftId;

/// Create a copy of OrderEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.total, total) || other.total == total)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.orderTime, orderTime) || other.orderTime == orderTime)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.queueNumber, queueNumber) || other.queueNumber == queueNumber)&&(identical(other.executorName, executorName) || other.executorName == executorName)&&(identical(other.executorId, executorId) || other.executorId == executorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.voidReason, voidReason) || other.voidReason == voidReason)&&(identical(other.voidBy, voidBy) || other.voidBy == voidBy)&&(identical(other.voidAt, voidAt) || other.voidAt == voidAt)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.changeAmount, changeAmount) || other.changeAmount == changeAmount)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,customerName,customerPhone,total,orderDate,orderTime,status,const DeepCollectionEquality().hash(_items),queueNumber,executorName,executorId,createdAt,updatedAt,voidReason,voidBy,voidAt,paymentMethod,paidAmount,changeAmount,shiftId]);

@override
String toString() {
  return 'OrderEntity(id: $id, customerName: $customerName, customerPhone: $customerPhone, total: $total, orderDate: $orderDate, orderTime: $orderTime, status: $status, items: $items, queueNumber: $queueNumber, executorName: $executorName, executorId: $executorId, createdAt: $createdAt, updatedAt: $updatedAt, voidReason: $voidReason, voidBy: $voidBy, voidAt: $voidAt, paymentMethod: $paymentMethod, paidAmount: $paidAmount, changeAmount: $changeAmount, shiftId: $shiftId)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderEntityCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String customerName, String? customerPhone, double total,@TimestampConverter() DateTime orderDate, String orderTime, OrderStatus status, List<OrderItem> items, int? queueNumber, String? executorName, String? executorId,@TimestampNullableConverter() DateTime? createdAt,@TimestampNullableConverter() DateTime? updatedAt, String? voidReason, String? voidBy,@TimestampNullableConverter() DateTime? voidAt, String paymentMethod, double? paidAmount, double? changeAmount, String? shiftId
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of OrderEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerName = null,Object? customerPhone = freezed,Object? total = null,Object? orderDate = null,Object? orderTime = null,Object? status = null,Object? items = null,Object? queueNumber = freezed,Object? executorName = freezed,Object? executorId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? voidReason = freezed,Object? voidBy = freezed,Object? voidAt = freezed,Object? paymentMethod = null,Object? paidAmount = freezed,Object? changeAmount = freezed,Object? shiftId = freezed,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as DateTime,orderTime: null == orderTime ? _self.orderTime : orderTime // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,queueNumber: freezed == queueNumber ? _self.queueNumber : queueNumber // ignore: cast_nullable_to_non_nullable
as int?,executorName: freezed == executorName ? _self.executorName : executorName // ignore: cast_nullable_to_non_nullable
as String?,executorId: freezed == executorId ? _self.executorId : executorId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,voidReason: freezed == voidReason ? _self.voidReason : voidReason // ignore: cast_nullable_to_non_nullable
as String?,voidBy: freezed == voidBy ? _self.voidBy : voidBy // ignore: cast_nullable_to_non_nullable
as String?,voidAt: freezed == voidAt ? _self.voidAt : voidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,paidAmount: freezed == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double?,changeAmount: freezed == changeAmount ? _self.changeAmount : changeAmount // ignore: cast_nullable_to_non_nullable
as double?,shiftId: freezed == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
