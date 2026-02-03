// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Order _$$_OrderFromJson(Map<String, dynamic> json) => _$_Order(
      id: json['id'] as String,
      customerName: json['customerName'] as String? ?? 'Guest',
      customerPhone: json['customerPhone'] as String?,
      total: (json['total'] as num).toDouble(),
      orderDate: const TimestampConverter().fromJson(json['orderDate']),
      orderTime: json['orderTime'] as String,
      status: $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
          OrderStatus.belum,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: const TimestampNullableConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampNullableConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$_OrderToJson(_$_Order instance) => <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'total': instance.total,
      'orderDate': const TimestampConverter().toJson(instance.orderDate),
      'orderTime': instance.orderTime,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'createdAt':
          const TimestampNullableConverter().toJson(instance.createdAt),
      'updatedAt':
          const TimestampNullableConverter().toJson(instance.updatedAt),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.belum: 'belum',
  OrderStatus.proses: 'proses',
  OrderStatus.selesai: 'selesai',
};
