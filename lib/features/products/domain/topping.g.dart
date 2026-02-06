// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topping.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Topping _$$_ToppingFromJson(Map<String, dynamic> json) => _$_Topping(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$_ToppingToJson(_$_Topping instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'stock': instance.stock,
      'isActive': instance.isActive,
    };
