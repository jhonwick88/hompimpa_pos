import 'package:flutter/material.dart';
import 'phone_order_page.dart';
import 'tablet_order_page.dart';
import 'tablet_portrait_order_page.dart';

class OrderPage extends StatelessWidget {
  final bool isQuickOrder;
  final String? existingOrderId;

  const OrderPage({
    Key? key,
    required this.isQuickOrder,
    this.existingOrderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Safe to use MediaQuery here as it is inside build and LayoutBuilder
        // ensures we rebuild on layout changes.
        final size = MediaQuery.of(context).size;
        final shortestSide = size.shortestSide;
        final isPortrait = size.height > size.width;

        // Device Type Detection Logic
        bool isPhone = shortestSide < 600;
        bool isTablet = shortestSide >= 600 && shortestSide < 1024;
        bool isDesktop = shortestSide >= 1024;

        if (isPhone) {
          return PhoneOrderPage(
            isQuickOrder: isQuickOrder,
            existingOrderId: existingOrderId,
          );
        } else if (isTablet) {
          if (isPortrait) {
            return TabletPortraitOrderPage(
              isQuickOrder: isQuickOrder,
              existingOrderId: existingOrderId,
            );
          } else {
            return TabletOrderPage(
              isQuickOrder: isQuickOrder,
              existingOrderId: existingOrderId,
            );
          }
        } else {
          // Desktop (>= 1024) - Default to Tablet Landscape (Wide) UI
          // If a specific Desktop UI exists in future, it goes here.
          return TabletOrderPage(
            isQuickOrder: isQuickOrder,
            existingOrderId: existingOrderId,
          );
        }
      },
    );
  }
}
