// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockLogImpl _$$StockLogImplFromJson(Map<String, dynamic> json) =>
    _$StockLogImpl(
      id: json['id'] as String,
      productId: json['productId'] as String,
      qtyChange: (json['qtyChange'] as num).toInt(),
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StockLogImplToJson(_$StockLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'qtyChange': instance.qtyChange,
      'reason': instance.reason,
      'createdAt': instance.createdAt.toIso8601String(),
    };
