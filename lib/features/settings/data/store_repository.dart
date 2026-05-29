import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/settings/domain/store.dart';

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepository(FirebaseFirestore.instance);
});

final activeStoresProvider = StreamProvider.autoDispose<List<Store>>((ref) {
  return ref.watch(storeRepositoryProvider).watchActiveStores();
});

final storesProvider = StreamProvider.autoDispose<List<Store>>((ref) {
  return ref.watch(storeRepositoryProvider).watchAllStores();
});

class StoreRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'stores';

  StoreRepository(this._firestore);

  Stream<List<Store>> watchActiveStores() {
    return _firestore.collection(_collection)
        .where('isActive', isEqualTo: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Store.fromJson({...doc.data(), 'id': doc.id})).toList();
    });
  }

  Stream<List<Store>> watchAllStores() {
    return _firestore.collection(_collection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Store.fromJson({...doc.data(), 'id': doc.id})).toList();
    });
  }

  Future<Store?> getStore(String storeId) async {
    final doc = await _firestore.collection(_collection).doc(storeId).get();
    if (doc.exists && doc.data() != null) {
      return Store.fromJson({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  Future<List<Store>> getAllStores() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) => Store.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  Future<void> addStore(Store store) async {
    await _firestore.collection(_collection).doc(store.id).set(store.toJson());
  }

  Future<void> updateStore(Store store) async {
    await _firestore.collection(_collection).doc(store.id).update(store.toJson());
  }

  Future<void> deleteStore(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
