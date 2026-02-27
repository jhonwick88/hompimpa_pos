// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['id'] as String,
  customerName: json['customerName'] as String? ?? 'Guest',
  customerPhone: json['customerPhone'] as String?,
  total: (json['total'] as num).toDouble(),
  orderDate: const TimestampConverter().fromJson(json['orderDate']),
  orderTime: json['orderTime'] as String,
  status:
      $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
      OrderStatus.belum,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  queueNumber: (json['queueNumber'] as num?)?.toInt(),
  executorName: json['executorName'] as String?,
  executorId: json['executorId'] as String?,
  createdAt: const TimestampNullableConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampNullableConverter().fromJson(json['updatedAt']),
  voidReason: json['voidReason'] as String?,
  voidBy: json['voidBy'] as String?,
  voidAt: const TimestampNullableConverter().fromJson(json['voidAt']),
  paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
  orderSource: json['orderSource'] as String? ?? 'Offline',
  isDineIn: json['isDineIn'] as bool? ?? false,
  tableNumber: json['tableNumber'] as String? ?? '0',
  paidAmount: (json['paidAmount'] as num?)?.toDouble(),
  changeAmount: (json['changeAmount'] as num?)?.toDouble(),
  shiftId: json['shiftId'] as String?,
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'customerName': instance.customerName,
  'customerPhone': instance.customerPhone,
  'total': instance.total,
  'orderDate': const TimestampConverter().toJson(instance.orderDate),
  'orderTime': instance.orderTime,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'queueNumber': instance.queueNumber,
  'executorName': instance.executorName,
  'executorId': instance.executorId,
  'createdAt': const TimestampNullableConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampNullableConverter().toJson(instance.updatedAt),
  'voidReason': instance.voidReason,
  'voidBy': instance.voidBy,
  'voidAt': const TimestampNullableConverter().toJson(instance.voidAt),
  'paymentMethod': instance.paymentMethod,
  'orderSource': instance.orderSource,
  'isDineIn': instance.isDineIn,
  'tableNumber': instance.tableNumber,
  'paidAmount': instance.paidAmount,
  'changeAmount': instance.changeAmount,
  'shiftId': instance.shiftId,
};

const _$OrderStatusEnumMap = {
  OrderStatus.belum: 'belum',
  OrderStatus.proses: 'proses',
  OrderStatus.selesai: 'selesai',
  OrderStatus.batal: 'batal',
  OrderStatus.menungguReview: 'menungguReview',
  OrderStatus.ditolak: 'ditolak',
};
