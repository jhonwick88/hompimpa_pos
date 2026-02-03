import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../products/data/product_repository.dart';
import '../../products/domain/product.dart';

final productListProvider = StreamProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts();
});
