import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../core/timestamp_converter.dart';
import 'order_item.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus { belum, proses, selesai }

@freezed
class OrderEntity with _$OrderEntity {
  @JsonSerializable(explicitToJson: true)
  const factory OrderEntity({
    required String id,
    @Default('Guest') String customerName,
    String? customerPhone,
    required double total,
    @TimestampConverter() required DateTime orderDate, // "tanggal"
    required String orderTime, // "jam"
    @Default(OrderStatus.belum) OrderStatus status,
    required List<OrderItem> items,
    int? queueNumber, // Queue number for order tracking
    @TimestampNullableConverter() DateTime? createdAt,
    @TimestampNullableConverter() DateTime? updatedAt,
  }) = _Order;

  factory OrderEntity.fromJson(Map<String, dynamic> json) => _$OrderEntityFromJson(json);

  static OrderEntity fromJsonRobust(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{...json};
    
    normalized['customerName'] ??= json['Nama'] ?? json['Pelanggan'] ?? json['Customer'];
    normalized['customerPhone'] ??= json['Telp'] ?? json['Phone'] ?? json['WhatsApp'];
    
    normalized['total'] ??= (json['Total'] ?? json['GrandTotal'] ?? 0.0).toDouble();
    normalized['orderDate'] ??= json['Tanggal'] ?? json['Date'];
    normalized['orderTime'] ??= json['Jam'] ?? json['Time'] ?? '';
    
    if (normalized['status'] == null) {
      final statusStr = (json['Status'] ?? json['status'] ?? '').toString().toLowerCase();
      if (statusStr.contains('selesai')) normalized['status'] = 'selesai';
      else if (statusStr.contains('proses')) normalized['status'] = 'proses';
      else normalized['status'] = 'belum';
    }
    
    normalized['items'] ??= json['Pesanan'] ?? json['Details'] ?? [];

    return OrderEntity.fromJson(normalized);
  }
}

