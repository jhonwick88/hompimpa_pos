// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CashOutEntity _$CashOutEntityFromJson(Map<String, dynamic> json) =>
    _CashOutEntity(
      id: json['id'] as String,
      shiftId: json['shiftId'] as String,
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String,
      timestamp: const TimestampConverter().fromJson(json['timestamp']),
      performedBy: json['performedBy'] as String?,
    );

Map<String, dynamic> _$CashOutEntityToJson(_CashOutEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shiftId': instance.shiftId,
      'amount': instance.amount,
      'reason': instance.reason,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
      'performedBy': instance.performedBy,
    };
