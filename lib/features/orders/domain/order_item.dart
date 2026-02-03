import 'package:json_annotation/json_annotation.dart';

part 'order_item.g.dart';

@JsonSerializable()
class OrderItem {
  final String productId;
  final String productName;
  final int qty;
  final double price;
  final String? level;
  final String? sambal;
  final String? note;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.qty,
    required this.price,
    this.level,
    this.sambal,
    this.note,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{...json};
    normalized['productName'] ??= json['Menu'] ?? json['Item'] ?? '';
    normalized['qty'] ??= json['Qty'] ?? json['Jumlah'] ?? 0;
    normalized['price'] ??= json['Harga'] ?? 0.0;
    normalized['note'] ??= json['Keterangan'] ?? json['Catatan'];
    
    return _$OrderItemFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  OrderItem copyWith({
    String? productId,
    String? productName,
    int? qty,
    double? price,
    String? level,
    String? sambal,
    String? note,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      level: level ?? this.level,
      sambal: sambal ?? this.sambal,
      note: note ?? this.note,
    );
  }
}
