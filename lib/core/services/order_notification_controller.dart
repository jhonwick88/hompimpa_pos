import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import '../../features/products/data/product_repository.dart'; // Just needed import? No.
import 'notification_service.dart';

// Provider that manages the subscription
final orderNotificationControllerProvider = Provider<OrderNotificationController>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final orderRepository = ref.watch(orderRepositoryProvider);
  return OrderNotificationController(notificationService, orderRepository);
});

class OrderNotificationController {
  final NotificationService _notificationService;
  final OrderRepository _orderRepository;
  
  DateTime _lastCheckTime = DateTime.now();

  OrderNotificationController(this._notificationService, this._orderRepository);

  void startMonitoring() {
    // Listen to orders stream (all recent orders, or specifically 'Belum' status?)
    // Assuming getOrdersStream returns recent orders sorted by date descending usually
    // But we need to listen continuously.
    // Let's listen to all orders for "today" to be safe and filter by time.
    
    _orderRepository.getOrdersStream(date: DateTime.now()).listen((orders) {
      final newOrders = orders.where((order) {
        // Check if order is newly created since last check
        final createdAt = order.createdAt ?? order.orderDate;
        return createdAt.isAfter(_lastCheckTime);
      }).toList();

      if (newOrders.isNotEmpty) {
        // Update last check time to avoiding duplicate notifications for same batch
        // We use the MAX created time of the new batch to advance cursor.
        // Wait, if multiple updates come, we might miss if timestamps are identical to last check?
        // Using > strict.
        
        DateTime maxTime = _lastCheckTime;
        for (final order in newOrders) {
           final validTime = order.createdAt ?? order.orderDate;
           if (validTime.isAfter(maxTime)) {
             maxTime = validTime;
           }
           
           // Notify for each new order
           // Only notify if status is 'Belum' (New Order)?
           if (order.status == OrderStatus.belum) {
             _notificationService.showOrderNotification(
                order.id, 
                order.customerName, 
                order.total
             );
           }
        }
        _lastCheckTime = maxTime;
      }
    });
  }
}
