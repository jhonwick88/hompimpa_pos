import "../../products/domain/topping.dart";
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
  final String? note; // Added missing field
  final List<Topping>? toppings;
  final String? storeId;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.qty,
    required this.price,
    this.level,
    this.sambal,
    this.note,
    this.toppings,
    this.storeId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{...json};
    normalized['productName'] ??= json['Menu'] ?? json['Item'] ?? '';
    normalized['qty'] ??= json['Qty'] ?? json['Jumlah'] ?? 0;
    normalized['price'] ??= json['Harga'] ?? 0.0;
    normalized['note'] ??= json['Keterangan'] ?? json['Catatan'];
    normalized['storeId'] ??= json['StoreId'] ?? json['store_id'];
    
    return _$OrderItemFromJson(normalized);
  }

  Map<String, dynamic> toJson() {
    final json = _$OrderItemToJson(this);
    if (toppings != null) {
      json['toppings'] = toppings!.map((t) => t.toJson()).toList();
    }
    return json;
  }

  OrderItem copyWith({
    String? productId,
    String? productName,
    int? qty,
    double? price,
    String? level,
    String? sambal,
    String? note,
    List<Topping>? toppings,
    String? storeId,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      level: level ?? this.level,
      sambal: sambal ?? this.sambal,
      note: note ?? this.note,
      toppings: toppings ?? this.toppings,
      storeId: storeId ?? this.storeId,
    );
  }
}
