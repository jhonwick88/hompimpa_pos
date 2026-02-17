// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topping.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Topping _$ToppingFromJson(Map<String, dynamic> json) => _Topping(
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  stock: (json['stock'] as num).toInt(),
  imageUrl: json['imageUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$ToppingToJson(_Topping instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'stock': instance.stock,
  'imageUrl': instance.imageUrl,
  'isActive': instance.isActive,
};
