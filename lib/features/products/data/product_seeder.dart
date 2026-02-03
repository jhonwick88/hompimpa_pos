
import 'package:uuid/uuid.dart';
import '../../products/domain/product.dart';
import 'product_repository.dart';

class ProductSeeder {
  final ProductRepository _repository;

  ProductSeeder(this._repository);

  Future<void> seed() async {
    final products = [
      // Makanan
      _createProduct('Mie', 7000, 'makanan'),
      _createProduct('Pangsit', 7000, 'makanan'),
      
      // Minuman
      _createProduct('Jus Jambu', 5000, 'minuman'),
      _createProduct('Jus Alpukat', 6000, 'minuman'),
      _createProduct('Jus Sirsat', 5000, 'minuman'),
      _createProduct('Jus Buah Naga', 5000, 'minuman'),
      _createProduct('Jus Nanas', 5000, 'minuman'),
      _createProduct('Jus Nangka', 5000, 'minuman'),
    ];

    for (final product in products) {
      print('DEBUG: Seeding product: ${product.name} (ID: ${product.id})');
      try {
        await _repository.addProduct(product);
        print('DEBUG: Successfully seeded: ${product.name}');
      } catch (e) {
        print('DEBUG ERROR seeding ${product.name}: $e');
        rethrow;
      }
    }
  }

  Product _createProduct(String name, double price, String category) {
    return Product(
      id: const Uuid().v4(),
      name: name,
      category: category,
      price: price,
      stock: 10000,
      isActive: true,
    );
  }
}
