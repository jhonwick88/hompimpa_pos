// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topping.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ToppingImpl _$$ToppingImplFromJson(Map<String, dynamic> json) =>
    _$ToppingImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$ToppingImplToJson(_$ToppingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'stock': instance.stock,
      'isActive': instance.isActive,
    };
