import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_log.freezed.dart';
part 'stock_log.g.dart';

@freezed
class StockLog with _$StockLog {
  const factory StockLog({
    required String id,
    required String productId,
    required int qtyChange,
    required String reason, // Order ID or "Manual Adjustment"
    required DateTime createdAt,
  }) = _StockLog;

  factory StockLog.fromJson(Map<String, dynamic> json) => _$StockLogFromJson(json);
}
