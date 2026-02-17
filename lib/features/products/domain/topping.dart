import 'package:freezed_annotation/freezed_annotation.dart';

part 'topping.freezed.dart';
part 'topping.g.dart';

@freezed
abstract class Topping with _$Topping {
  const factory Topping({
    required String id,
    required String name,
    required double price,
    required int stock,
    String? imageUrl,
    @Default(true) bool isActive,
  }) = _Topping;

  factory Topping.fromJson(Map<String, dynamic> json) => _$ToppingFromJson(json);
}
