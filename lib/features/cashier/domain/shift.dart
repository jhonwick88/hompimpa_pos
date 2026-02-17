import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/timestamp_converter.dart';

part 'shift.freezed.dart';
part 'shift.g.dart';

@freezed
abstract class ShiftEntity with _$ShiftEntity {
  @JsonSerializable(explicitToJson: true)
  const factory ShiftEntity({
    required String id,
    required String shiftName,
    @TimestampConverter() required DateTime startTime,
    @TimestampNullableConverter() DateTime? endTime,
    required double startCash,
    double? endCash, // Physical cash counted at closing
    double? expectedCash, // Calculated system cash at closing
    double? difference, // endCash - expectedCash
    @Default('OPEN') String status, // OPEN, CLOSED
    
    // Summary fields (populated on close)
    double? totalCashSales,
    double? totalNonCashSales,
    double? totalCashOut,
  }) = _ShiftEntity;

  factory ShiftEntity.fromJson(Map<String, dynamic> json) => _$ShiftEntityFromJson(json);
}
