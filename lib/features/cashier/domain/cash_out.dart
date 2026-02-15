import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/timestamp_converter.dart';

part 'cash_out.freezed.dart';
part 'cash_out.g.dart';

@freezed
class CashOutEntity with _$CashOutEntity {
  @JsonSerializable(explicitToJson: true)
  const factory CashOutEntity({
    required String id,
    required String shiftId,
    required double amount,
    required String reason,
    @TimestampConverter() required DateTime timestamp,
    String? performedBy,
  }) = _CashOutEntity;

  factory CashOutEntity.fromJson(Map<String, dynamic> json) => _$CashOutEntityFromJson(json);
}
