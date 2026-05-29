import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';

class OrderCardModern extends StatefulWidget {
  final OrderEntity order;
  final int queueNumber;
  final Color statusColor;
  final IconData statusIcon;
  final Function(dynamic order, int itemIndex)? onEditItem;
  final Widget actionSection;
  final VoidCallback? onStatusTap;

  const OrderCardModern({
    super.key,
    required this.order,
    required this.queueNumber,
    required this.statusColor,
    required this.statusIcon,
    required this.actionSection,
    this.onEditItem,
    this.onStatusTap,
  });

  @override
  State<OrderCardModern> createState() => _OrderCardModernState();
}

class _OrderCardModernState extends State<OrderCardModern> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // 🔥 STATUS STRIP
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: widget.statusColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
          ),

          // 🔥 HEADER
          InkWell(
            onTap: () => setState(() => expanded = !expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  InkWell(
                    onTap: widget.onStatusTap,
                    borderRadius: BorderRadius.circular(20),
                    child: CircleAvatar(
                      backgroundColor: widget.statusColor.withOpacity(0.15),
                      child: Icon(widget.statusIcon, color: widget.statusColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                              Text(
                          order.customerName,
                          style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                       
                        
                          ],
                        ),
                        Row(
                          children:[
                        if (order.executorName != null)
                          Text(
                            'Koki: ${order.executorName?.split(' ').first ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          if(order.customerPhone != null && order.customerPhone!.isNotEmpty)...[
                          const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'WA ${order.customerPhone}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        ]
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'Rp ',
                                      decimalDigits: 0,
                                    ).format(order.total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' • ${order.orderTime} • ',
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: order.paymentMethod == 'QRIS' ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.paymentMethod,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  //start column
                  Column(
                    children: [
                      Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '#${widget.queueNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                    ],
                  ),
                  //end column
                ],
              ),
            ),
          ),

          // 🔥 EXPAND BODY
          AnimatedCrossFade(
            firstChild: const SizedBox(),
            secondChild: _buildExpandedContent(),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    final order = widget.order;

    return Column(
      children: [
        // List item order
        Container(
          width: double.infinity,
          color: Colors.grey.shade50,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: order.items.asMap().entries.map<Widget>((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama + Level + Sambal + Qty
                          Text(
                            item.level != null
                                ? '${item.productName} - Lvl ${item.level} (${item.sambal}) - ${item.qty}x'
                                : '${item.productName} - ${item.qty}x',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          // Note jika ada
                          if (item.note != null && item.note!.isNotEmpty)
                            Text(
                              '(${item.note})',
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          // Toppings jika ada
                          if (item.toppings != null && item.toppings!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Toppings: ${item.toppings!.map((t) => t.name).join(", ")}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[900],
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Harga total item
                    Text(
                      'Rp ${(item.price * item.qty).toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    // Tombol edit hanya untuk status 'belum'
                    if (order.status == OrderStatus.belum &&
                        widget.onEditItem != null)
                      IconButton(
                        icon: const Icon(Icons.edit,
                            size: 18, color: Colors.blue),
                        onPressed: () => widget.onEditItem!(order, idx),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        const Divider(height: 1),

        // Action Section (tombol aksi saja)
Padding(
  padding: const EdgeInsets.all(12),
  child: Align(
    alignment: Alignment.centerLeft,
    child: widget.actionSection,
  ),
),

      ],
    );
  }
}
