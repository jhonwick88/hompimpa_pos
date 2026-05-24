import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../products/data/product_repository.dart';
import '../../products/domain/product.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/enums/user_role.dart';

final selectedStoreFilterProvider = StateProvider<String?>((ref) => null);

final productListProvider = StreamProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  final user = ref.watch(authStateChangesProvider).value;
  final filterStoreId = ref.watch(selectedStoreFilterProvider);

  return repository.getProducts().map((products) {
    if (user != null && user.role != UserRole.dev && user.role != UserRole.admin) {
      return products.where((p) => p.storeId == user.storeId).toList();
    }
    
    if (filterStoreId != null) {
      return products.where((p) => p.storeId == filterStoreId).toList();
    }
    return products;
  });
});

final unfilteredProductListProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getProducts();
});
