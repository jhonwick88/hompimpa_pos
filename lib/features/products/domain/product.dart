class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String? imageUrl;
  final bool isActive;
  final String? storeId;
  final bool hasSambal;
  final bool hasLevel;
  final bool hasTopping;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.isActive = true,
    this.storeId,
    this.hasSambal = false,
    this.hasLevel = false,
    this.hasTopping = false,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? imageUrl,
    bool? isActive,
    String? storeId,
    bool? hasSambal,
    bool? hasLevel,
    bool? hasTopping,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      storeId: storeId ?? this.storeId,
      hasSambal: hasSambal ?? this.hasSambal,
      hasLevel: hasLevel ?? this.hasLevel,
      hasTopping: hasTopping ?? this.hasTopping,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      storeId: json['storeId'] as String?,
      hasSambal: json['hasSambal'] as bool? ?? false,
      hasLevel: json['hasLevel'] as bool? ?? false,
      hasTopping: json['hasTopping'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'storeId': storeId,
      'hasSambal': hasSambal,
      'hasLevel': hasLevel,
      'hasTopping': hasTopping,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Product &&
      other.id == id &&
      other.name == name &&
      other.category == category &&
      other.price == price &&
      other.stock == stock &&
      other.imageUrl == imageUrl &&
      other.isActive == isActive &&
      other.storeId == storeId &&
      other.hasSambal == hasSambal &&
      other.hasLevel == hasLevel &&
      other.hasTopping == hasTopping;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      category.hashCode ^
      price.hashCode ^
      stock.hashCode ^
      imageUrl.hashCode ^
      isActive.hashCode ^
      storeId.hashCode ^
      hasSambal.hashCode ^
      hasLevel.hashCode ^
      hasTopping.hashCode;
  }
}
