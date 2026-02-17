// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShiftEntity _$ShiftEntityFromJson(Map<String, dynamic> json) => _ShiftEntity(
  id: json['id'] as String,
  shiftName: json['shiftName'] as String,
  startTime: const TimestampConverter().fromJson(json['startTime']),
  endTime: const TimestampNullableConverter().fromJson(json['endTime']),
  startCash: (json['startCash'] as num).toDouble(),
  endCash: (json['endCash'] as num?)?.toDouble(),
  expectedCash: (json['expectedCash'] as num?)?.toDouble(),
  difference: (json['difference'] as num?)?.toDouble(),
  status: json['status'] as String? ?? 'OPEN',
  totalCashSales: (json['totalCashSales'] as num?)?.toDouble(),
  totalNonCashSales: (json['totalNonCashSales'] as num?)?.toDouble(),
  totalCashOut: (json['totalCashOut'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ShiftEntityToJson(_ShiftEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shiftName': instance.shiftName,
      'startTime': const TimestampConverter().toJson(instance.startTime),
      'endTime': const TimestampNullableConverter().toJson(instance.endTime),
      'startCash': instance.startCash,
      'endCash': instance.endCash,
      'expectedCash': instance.expectedCash,
      'difference': instance.difference,
      'status': instance.status,
      'totalCashSales': instance.totalCashSales,
      'totalNonCashSales': instance.totalNonCashSales,
      'totalCashOut': instance.totalCashOut,
    };
