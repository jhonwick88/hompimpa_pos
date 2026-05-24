import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/products/domain/product.dart';
import 'package:uuid/uuid.dart';

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
  Future<void> cloneProducts(String fromStoreId, String toStoreId);
  Future<void> transferStock(String fromProductId, String toProductId, int qty, {required String username});
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

  @override
  Future<void> cloneProducts(String fromStoreId, String toStoreId) async {
    final snapshot = await _firestore.collection('products').get();
    final batch = _firestore.batch();
    
    final products = snapshot.docs.map((doc) => Product.fromJson({...doc.data(), 'id': doc.id})).toList();
    final fromProducts = products.where((p) => p.storeId == fromStoreId).toList();
    
    for (var product in fromProducts) {
      final newId = const Uuid().v4();
      final newProduct = product.copyWith(
        id: newId,
        storeId: toStoreId,
        stock: 0,
      );
      batch.set(_firestore.collection('products').doc(newId), newProduct.toJson());
    }
    
    await batch.commit();
  }

  @override
  Future<void> transferStock(String fromProductId, String toProductId, int qty, {required String username}) async {
    await _firestore.runTransaction((transaction) async {
      final fromRef = _firestore.collection('products').doc(fromProductId);
      final toRef = _firestore.collection('products').doc(toProductId);
      
      final fromDoc = await transaction.get(fromRef);
      final toDoc = await transaction.get(toRef);
      
      if (!fromDoc.exists || !toDoc.exists) {
        throw Exception("Produk asal atau tujuan tidak ditemukan");
      }
      
      final currentFromStock = (fromDoc.data() as Map<String, dynamic>)['stock'] as int? ?? 0;
      final currentToStock = (toDoc.data() as Map<String, dynamic>)['stock'] as int? ?? 0;
      
      if (currentFromStock < qty) {
        throw Exception("Stok produk asal tidak mencukupi (Stok: $currentFromStock, Mutasi: $qty)");
      }
      
      final newFromStock = currentFromStock - qty;
      final newToStock = currentToStock + qty;
      
      // Update Stocks
      transaction.update(fromRef, {'stock': newFromStock});
      transaction.update(toRef, {'stock': newToStock});
      
      // Create Stock Logs
      final logFromRef = _firestore.collection('stock_logs').doc();
      final logToRef = _firestore.collection('stock_logs').doc();
      
      transaction.set(logFromRef, {
        'id': logFromRef.id,
        'productId': fromProductId,
        'qtyChange': -qty,
        'newStock': newFromStock,
        'reason': 'Mutasi ke Cabang lain',
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      transaction.set(logToRef, {
        'id': logToRef.id,
        'productId': toProductId,
        'qtyChange': qty,
        'newStock': newToStock,
        'reason': 'Mutasi dari Cabang lain',
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
