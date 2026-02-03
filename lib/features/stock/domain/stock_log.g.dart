// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_StockLog _$$_StockLogFromJson(Map<String, dynamic> json) => _$_StockLog(
      id: json['id'] as String,
      productId: json['productId'] as String,
      qtyChange: json['qtyChange'] as int,
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$_StockLogToJson(_$_StockLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'qtyChange': instance.qtyChange,
      'reason': instance.reason,
      'createdAt': instance.createdAt.toIso8601String(),
    };
