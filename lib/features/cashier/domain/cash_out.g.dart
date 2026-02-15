// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CashOutEntityImpl _$$CashOutEntityImplFromJson(Map<String, dynamic> json) =>
    _$CashOutEntityImpl(
      id: json['id'] as String,
      shiftId: json['shiftId'] as String,
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String,
      timestamp: const TimestampConverter().fromJson(json['timestamp']),
      performedBy: json['performedBy'] as String?,
    );

Map<String, dynamic> _$$CashOutEntityImplToJson(_$CashOutEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shiftId': instance.shiftId,
      'amount': instance.amount,
      'reason': instance.reason,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
      'performedBy': instance.performedBy,
    };
