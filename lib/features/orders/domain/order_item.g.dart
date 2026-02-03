// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      qty: json['qty'] as int,
      price: (json['price'] as num).toDouble(),
      level: json['level'] as String?,
      sambal: json['sambal'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'qty': instance.qty,
      'price': instance.price,
      'level': instance.level,
      'sambal': instance.sambal,
      'note': instance.note,
    };
