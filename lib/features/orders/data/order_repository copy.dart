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
}

class FirestoreOrderRepository implements OrderRepository {
  final FirebaseFirestore _firestore;

  FirestoreOrderRepository(this._firestore);

  @override
  Stream<List<OrderEntity>> getOrdersStream({
    DateTime? date, 
    OrderStatus? status, 
    String? searchQuery,
    AppUser? currentUser,
  }) {
    // 1. Fetch active stores first to handle isActive logic
    // For simplicity, we'll fetch all stores and filter in memory.
    // In a large system, we'd use a more reactive approach.
    final storesStream = _firestore.collection('stores').snapshots();

    return _firestore.collection('orders').snapshots().asyncMap((orderSnapshot) async {
      // Get all stores to check isActive
      final storeDocs = await _firestore.collection('stores').get();
      final activeStoreIds = storeDocs.docs
          .where((doc) => doc.data()['isActive'] == true)
          .map((doc) => doc.id)
          .toSet();

      final baseOrders = <OrderEntity>[];
      for (final doc in orderSnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          var order = OrderEntity.fromJsonRobust({...data, 'id': doc.id});
          
          // Role-based Isolation Logic
          if (currentUser != null && currentUser.role != UserRole.dev) {
            // Filter items: must match user.storeId AND store must be active
            final filteredItems = order.items.where((item) {
              final itemStoreId = item.storeId ?? order.storeId; // Fallback to order-level storeId
              return itemStoreId == currentUser.storeId && activeStoreIds.contains(itemStoreId);
            }).toList();

            if (filteredItems.isEmpty) continue; // Hide orders with no visible items

            // Re-calculate total based on filtered items
            final newTotal = filteredItems.fold<double>(0, (sum, item) => sum + (item.price * item.qty));
            order = order.copyWith(items: filteredItems, total: newTotal);
          } else if (currentUser != null && currentUser.role == UserRole.dev) {
             // DEV sees everything, but we still want to label them? 
             // No specific instruction for labeling, just "can see all".
          }

          baseOrders.add(order);
        } catch (e) {
          print("DEBUG: Failed to parse order ${doc.id}: $e");
        }
      }

      var filtered = List<OrderEntity>.from(baseOrders);
      // Client-side filtering
      if (date != null) {
        filtered = filtered.where((o) {
          final localDate = o.orderDate.toLocal();
          return localDate.year == date.year &&
                 localDate.month == date.month &&
                 localDate.day == date.day;
        }).toList();
      }

      if (status != null) {
        filtered = filtered.where((o) => o.status == status).toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        filtered = filtered.where((o) => 
          o.customerName.toLowerCase().contains(q) ||
          (o.customerPhone != null && o.customerPhone!.contains(q)) ||
          o.id.toLowerCase().contains(q)
        ).toList();
      }

      // Client-side sorting
      filtered.sort((a, b) {
        final dateA = a.createdAt ?? a.orderDate;
        final dateB = b.createdAt ?? b.orderDate;
        return dateA.compareTo(dateB);
      });

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
}
