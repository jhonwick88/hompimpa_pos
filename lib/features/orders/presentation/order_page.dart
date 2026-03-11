import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:hompimpa_pos/features/orders/presentation/phone_order_page.dart';
import 'package:hompimpa_pos/features/orders/presentation/tablet_order_page.dart';
import 'package:hompimpa_pos/features/orders/presentation/tablet_portrait_order_page.dart';
import 'package:hompimpa_pos/features/orders/presentation/cart_controller.dart';
import 'package:hompimpa_pos/features/cashier/presentation/cashier_controller.dart';
import 'package:hompimpa_pos/features/orders/presentation/order_state.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';

class OrderPage extends ConsumerStatefulWidget {
  final bool isQuickOrder;
  final String? existingOrderId;

  const OrderPage({
    Key? key,
    required this.isQuickOrder,
    this.existingOrderId,
  }) : super(key: key);

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage> {
  bool _isInitialized = false;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _tableController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _tableController = TextEditingController(text: '0');
    Future.microtask(() => _initOrder());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(OrderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.existingOrderId != oldWidget.existingOrderId) {
      Future.microtask(() => _initOrder());
    }
  }

  Future<void> _initOrder() async {
    if (!mounted) return;
    
    final metadataNotifier = ref.read(orderMetadataProvider.notifier);
    final cartNotifier = ref.read(cartProvider.notifier);
    
    // Only clear if we are NOT loading an existing order AND the cart isn't already set up
    // This prevents losing items on rotation for new orders
    if (widget.existingOrderId == null) {
      final currentItems = ref.read(cartProvider).items;
      if (currentItems.isEmpty) {
        // Only clear if it's truly empty, to be safe
        cartNotifier.clearCart();
        metadataNotifier.reset();
        
        final name = "Offline - ${const Uuid().v4().substring(0, 4)}";
        _nameController.text = name;
        
        // Use microtask to avoid modifying during build
        Future.microtask(() {
          if (mounted) {
            metadataNotifier.updateCustomerName(name);
          }
        });
      }
    } else {
      // For existing orders, clear and load from repository
      // BUT only if we haven't initialized yet or the ID changed
      cartNotifier.clearCart();
      metadataNotifier.reset();
      
      final repository = ref.read(orderRepositoryProvider);
      final order = await repository.getOrder(widget.existingOrderId!);
      
      if (order != null && mounted) {
        _nameController.text = order.customerName;
        _phoneController.text = order.customerPhone ?? '';
        _tableController.text = order.tableNumber;
        
        Future.microtask(() {
          if (mounted) {
            metadataNotifier.initialize(
              customerName: order.customerName,
              customerPhone: order.customerPhone,
              selectedDate: order.orderDate,
              selectedTime: _parseTime(order.orderTime),
              selectedVia: order.orderSource,
              isDineIn: order.isDineIn,
              tableNumber: order.tableNumber,
              selectedPayment: order.paymentMethod,
            );
            cartNotifier.setCartItems(order.items);
          }
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order not found')),
        );
        context.pop();
        return;
      }
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        final hour = int.tryParse(parts[0].trim());
        final minute = int.tryParse(parts[1].split(' ')[0].trim());
        
        if (hour != null && minute != null) {
          if (timeStr.toLowerCase().contains('pm') && hour < 12) {
            return TimeOfDay(hour: hour + 12, minute: minute);
          }
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
      return TimeOfDay.now();
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Sync controllers with state when state changes from external sources (like updateSelectedVia, initialize, or reset)
    ref.listen<OrderMetadata>(orderMetadataProvider, (previous, next) {
      if (next.customerName != _nameController.text) {
        _nameController.text = next.customerName;
        _nameController.selection = TextSelection.fromPosition(
          TextPosition(offset: _nameController.text.length),
        );
      }
      if (next.customerPhone != _phoneController.text) {
        _phoneController.text = next.customerPhone;
        _phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: _phoneController.text.length),
        );
      }
      if (next.tableNumber != _tableController.text) {
        _tableController.text = next.tableNumber;
        _tableController.selection = TextSelection.fromPosition(
          TextPosition(offset: _tableController.text.length),
        );
      }
    });

    // Eager-load cashier state
    ref.watch(cashierProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.hasBoundedHeight ? constraints.maxHeight : MediaQuery.of(context).size.height;
        final width = constraints.hasBoundedWidth ? constraints.maxWidth : MediaQuery.of(context).size.width;
        debugPrint('height: $height, width: $width');
        return SizedBox(
          height: height,
          width: width,
          child: Builder(
            builder: (context) {
              final size = MediaQuery.of(context).size;
              final shortestSide = size.shortestSide;
              final isPortrait = size.height > size.width;

              bool isPhone = shortestSide < 600;
              bool isTablet = shortestSide >= 600 && shortestSide < 1024;

              if (isPhone) {
                return PhoneOrderPage(
                  isQuickOrder: widget.isQuickOrder,
                  existingOrderId: widget.existingOrderId,
                  nameController: _nameController,
                  phoneController: _phoneController,
                  tableController: _tableController,
                );
              } else if (isTablet) {
                if (isPortrait) {
                  return TabletPortraitOrderPage(
                    isQuickOrder: widget.isQuickOrder,
                    existingOrderId: widget.existingOrderId,
                    nameController: _nameController,
                    phoneController: _phoneController,
                    tableController: _tableController,
                  );
                } else {
                  return TabletOrderPage(
                    isQuickOrder: widget.isQuickOrder,
                    existingOrderId: widget.existingOrderId,
                    nameController: _nameController,
                    phoneController: _phoneController,
                    tableController: _tableController,
                  );
                }
              } else {
                return TabletOrderPage(
                  isQuickOrder: widget.isQuickOrder,
                  existingOrderId: widget.existingOrderId,
                  nameController: _nameController,
                  phoneController: _phoneController,
                  tableController: _tableController,
                );
              }
            },
          ),
        );
      },
    );
  }
}
