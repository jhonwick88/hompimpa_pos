import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return FirestoreStockRepository(FirebaseFirestore.instance);
});

abstract class StockRepository {
  Future<QuerySnapshot> getStockLogsPaginated({int limit = 10, QueryDocumentSnapshot? lastDocument});
  Future<void> deleteStockLog(String id);
  Future<void> bulkDeleteStockLogs(List<String> ids);
  Future<void> deleteAllStockLogs();
}

class FirestoreStockRepository implements StockRepository {
  final FirebaseFirestore _firestore;

  FirestoreStockRepository(this._firestore);

  @override
  Future<QuerySnapshot> getStockLogsPaginated({int limit = 10, QueryDocumentSnapshot? lastDocument}) async {
    Query query = _firestore.collection('stock_logs')
        .orderBy('createdAt', descending: false)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return await query.get();
  }

  @override
  Future<void> deleteStockLog(String id) async {
    await _firestore.collection('stock_logs').doc(id).delete();
  }

  @override
  Future<void> bulkDeleteStockLogs(List<String> ids) async {
    final batch = _firestore.batch();
    for (final id in ids) {
      batch.delete(_firestore.collection('stock_logs').doc(id));
    }
    await batch.commit();
  }

  @override
  Future<void> deleteAllStockLogs() async {
    final snapshot = await _firestore.collection('stock_logs').get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
