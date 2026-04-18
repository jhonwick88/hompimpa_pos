import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/features/orders/domain/order_item.dart';
import 'package:hompimpa_pos/features/auth/domain/user_model.dart';
import 'package:hompimpa_pos/core/enums/user_role.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return FirestoreOrderRepository(FirebaseFirestore.instance);
});

abstract class OrderRepository {
  Stream<List<OrderEntity>> getOrdersStream({
    DateTime? date, 
    OrderStatus? status, 
    String? searchQuery,
    AppUser? currentUser,
  });
  Future<void> addOrder(OrderEntity order);
  Future<void> updateOrder(OrderEntity order);
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus, List<OrderItem> items, {String? executorName, String? executorId});
  Future<void> updateOrderItems(String orderId, List<OrderItem> items);
  Future<void> deleteOrder(String orderId);
  Future<void> voidOrder(String orderId, String reason, String voidBy);
  Future<void> bulkDeleteOrders(List<String> orderIds);
  Future<OrderEntity?> getOrder(String orderId);
  Future<List<OrderEntity>> getOrdersForShift(String shiftId);
  Future<List<OrderEntity>> getOrdersByTimeRange(DateTime start, DateTime end);
  Future<QuerySnapshot> getOrdersPaginated({int limit = 10, QueryDocumentSnapshot? lastDocument});
  Future<void> deleteAllOrders();
  Future<List<OrderEntity>> getAllOrders();
}

class FirestoreOrderRepository implements OrderRepository {
  final FirebaseFirestore _firestore;

  FirestoreOrderRepository(this._firestore);

 /// ✅ ambil active store sekali saja
  Future<Set<String>> _getActiveStoreIds() async {
    final snapshot = await _firestore.collection('stores').get();
    return snapshot.docs
        .where((doc) => doc.data()['isActive'] == true)
        .map((doc) => doc.id)
        .toSet();
  }

  @override
  Stream<List<OrderEntity>> getOrdersStream({
    DateTime? date,
    OrderStatus? status,
    String? searchQuery,
    AppUser? currentUser,
  }) async* {
    // ✅ ambil store sekali (bukan di stream)
    final activeStoreIds = await _getActiveStoreIds();

    Query query = _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(50); // 🔥 WAJIB biar hemat

    // ✅ filter server-side kalau bisa
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));

      query = query
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThan: end);
    }

    yield* query.snapshots().map((snapshot) {
      final result = <OrderEntity>[];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          var order = OrderEntity.fromJsonRobust({
            ...data,
            'id': doc.id,
          });

          /// ✅ ROLE FILTER
          if (currentUser != null && currentUser.role != UserRole.dev) {
            final filteredItems = order.items.where((item) {
              final itemStoreId = item.storeId ?? order.storeId;
              return itemStoreId == currentUser.storeId &&
                  activeStoreIds.contains(itemStoreId);
            }).toList();

            if (filteredItems.isEmpty) continue;

            final newTotal = filteredItems.fold<double>(
              0,
              (sum, item) => sum + (item.price * item.qty),
            );

            order = order.copyWith(
              items: filteredItems,
              total: newTotal,
            );
          }

          result.add(order);
        } catch (e) {
          print("DEBUG: parse error ${doc.id}: $e");
        }
      }

      /// ✅ FILTER CLIENT (yang gak bisa di server)
      var filtered = result;

      if (date != null) {
        filtered = filtered.where((o) {
          final d = o.orderDate.toLocal();
          return d.year == date.year &&
              d.month == date.month &&
              d.day == date.day;
        }).toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        filtered = filtered.where((o) =>
            o.customerName.toLowerCase().contains(q) ||
            (o.customerPhone != null &&
                o.customerPhone!.contains(q)) ||
            o.id.toLowerCase().contains(q)).toList();
      }

      return filtered;
    });
  }

  @override
  Future<void> addOrder(OrderEntity order) async {
    // Using explicit toJson from the generated part if it's missing on the class
    await _firestore.collection('orders').doc(order.id).set(order.toJson());
  }

  @override
  Future<void> updateOrder(OrderEntity order) async {
    await _firestore.collection('orders')
        .doc(order.id)
        .update(order.toJson());
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus, List<OrderItem> items, {String? executorName, String? executorId}) async {
    final orderRef = _firestore.collection('orders').doc(orderId);
    final statusValue = newStatus.name;
    final statusDisplay = statusValue[0].toUpperCase() + statusValue.substring(1);

    print('DEBUG: Updating order $orderId to status $statusValue ($statusDisplay)');

    final updateData = <String, dynamic>{
      'status': statusValue,
      'Status': statusDisplay,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (executorName != null) updateData['executorName'] = executorName;
    if (executorId != null) updateData['executorId'] = executorId;

    try {
      if (newStatus == OrderStatus.selesai) {
        await _firestore.runTransaction((transaction) async {
          // 1. COLLECT ALL READS
          final productSnapshots = <String, DocumentSnapshot>{};
          for (final item in items) {
            final productRef = _firestore.collection('products').doc(item.productId);
            productSnapshots[item.productId] = await transaction.get(productRef);
          }

          // 2. WRITES
          transaction.update(orderRef, updateData); // Use common updateData

          // Update Stocks and Logs
          for (final item in items) {
            final snapshot = productSnapshots[item.productId];
            if (snapshot != null && snapshot.exists) {
              final currentStock = (snapshot.data() as Map<String, dynamic>?)?['stock'] as int? ?? 0;
              transaction.update(snapshot.reference, {'stock': currentStock - item.qty});
              
              // Log Stock Change
              final logRef = _firestore.collection('stock_logs').doc();
              transaction.set(logRef, {
                 'id': logRef.id,
                 'productId': item.productId,
                 'qtyChange': -item.qty,
                 'reason': 'Order: $orderId',
                 'createdAt': FieldValue.serverTimestamp(),
              });
            }
          }
        });
      } else {
        // Just update status
        await orderRef.update(updateData);
      }
      print('DEBUG: Successfully updated order $orderId');
    } catch (e) {
      print('DEBUG: Error updating order $orderId: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateOrderItems(String orderId, List<OrderItem> items) async {
    final orderRef = _firestore.collection('orders').doc(orderId);
    final total = items.fold<double>(0.0, (sum, item) => sum + (item.price * item.qty));
    
    await orderRef.update({
      'items': items.map((i) => i.toJson()).toList(),
      'Pesanan': items.map((i) => i.toJson()).toList(), // For AppSheet
      'total': total,
      'Total': total, // For AppSheet
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).delete();
  }

  @override
  Future<void> voidOrder(String orderId, String reason, String voidBy) async {
    final orderRef = _firestore.collection('orders').doc(orderId);
    await orderRef.update({
      'status': 'batal',
      'Status': 'Batal',
      'voidReason': reason,
      'voidBy': voidBy,
      'voidAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  @override
  Future<void> bulkDeleteOrders(List<String> orderIds) async {
    final batch = _firestore.batch();
    for (final id in orderIds) {
      batch.delete(_firestore.collection('orders').doc(id));
    }
    await batch.commit();
  }

  @override
  Future<OrderEntity?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (!doc.exists) return null;
      return OrderEntity.fromJsonRobust({...doc.data() as Map<String, dynamic>, 'id': doc.id});
    } catch (e) {
      print('Error fetching order $orderId: $e');
      return null;
    }
  }

  @override
  Future<List<OrderEntity>> getOrdersForShift(String shiftId) async {
     try {
      final snapshot = await _firestore.collection('orders')
          .where('shiftId', isEqualTo: shiftId)
          .get();

      return snapshot.docs.map((doc) {
        return OrderEntity.fromJsonRobust({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error fetching orders for shift $shiftId: $e');
      return [];
    }
  }

  @override
  Future<List<OrderEntity>> getOrdersByTimeRange(DateTime start, DateTime end) async {
    try {
      // Query by createdAt range
      // Note: This requires 'createdAt' field to be indexed for complex queries if we add more filters.
      // For simple range, it should be fine.
      final snapshot = await _firestore.collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThanOrEqualTo: end)
          .get();

      return snapshot.docs.map((doc) {
        return OrderEntity.fromJsonRobust({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error fetching orders by time range: $e');
      return [];
    }
  }

  @override
  Future<QuerySnapshot> getOrdersPaginated({int limit = 10, QueryDocumentSnapshot? lastDocument}) async {
    Query query = _firestore.collection('orders')
        .orderBy('createdAt', descending: false)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return await query.get();
  }

  @override
  Future<void> deleteAllOrders() async {
    final snapshot = await _firestore.collection('orders').get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<List<OrderEntity>> getAllOrders() async {
    final snapshot = await _firestore.collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
        
    return snapshot.docs.map((doc) {
      return OrderEntity.fromJsonRobust({
        ...doc.data(),
        'id': doc.id,
      });
    }).toList();
  }
}
