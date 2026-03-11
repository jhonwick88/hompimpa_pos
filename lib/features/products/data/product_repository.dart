import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/products/domain/product.dart';

// Provider definition
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirestoreProductRepository(FirebaseFirestore.instance);
});

abstract class ProductRepository {
  Stream<List<Product>> getProducts();
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<void> updateStock(String productId, int newStock, {String? reason, String? username});
}

class FirestoreProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore;

  FirestoreProductRepository(this._firestore);

  @override
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  @override
  Future<void> addProduct(Product product) async {
    // We explicitly exclude ID because Firestore generates it or we provided it. 
    // If wrapping validation generally, better to let Firestore gen ID if 'id' is empty.
    // But entities usually require ID. Let's assume ID is generated before passing here or use .doc().set()
    await _firestore.collection('products').doc(product.id).set(product.toJson());
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).update(product.toJson());
  }
  
  @override
  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  @override
  Future<void> updateStock(String productId, int newStock, {String? reason, String? username}) async {
    await _firestore.runTransaction((transaction) async {
      final productRef = _firestore.collection('products').doc(productId);
      final productDoc = await transaction.get(productRef);
      
      if (!productDoc.exists) {
        throw Exception("Product not found");
      }

      final currentStock = (productDoc.data() as Map<String, dynamic>)['stock'] as int? ?? 0;
      final qtyChange = newStock - currentStock;

      // 1. Update Product Stock
      transaction.update(productRef, {'stock': newStock});

      // 2. Create Stock Log
      final logRef = _firestore.collection('stock_logs').doc();
      transaction.set(logRef, {
        'id': logRef.id,
        'productId': productId,
        'qtyChange': qtyChange,
        'newStock': newStock,
        'reason': reason ?? 'Manual Update',
        'username': username ?? 'Unknown',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
