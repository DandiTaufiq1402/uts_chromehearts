import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/order_model.dart';
import '../providers/order_provider.dart';
import 'payment_pending_page.dart';
import 'order_success_page.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchMyOrders();
    });
  }

  String _formatPrice(double price) {
    final str = price.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp. ${buffer.toString().split('').reversed.join()}';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Menunggu Pembayaran';
      case 'processing': return 'Diproses';
      case 'shipped': return 'Dikirim';
      case 'delivered': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      case 'paid': return 'Dibayar';
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'paid': return Colors.teal;
      default: return Colors.grey;
    }
  }

  void _onOrderTapped(OrderModel order) {
    if (order.status == 'pending') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaymentPendingPage(order: order)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrderSuccessPage(order: order)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: Consumer<OrderProvider>(
        builder: (context, orderProv, _) {
          if (orderProv.checkoutStatus == OrderStatus.loading && orderProv.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProv.checkoutStatus == OrderStatus.error && orderProv.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(orderProv.error ?? 'Terjadi kesalahan'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => orderProv.fetchMyOrders(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final orders = orderProv.orders;
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pesanan',
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderProv.fetchMyOrders(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final order = orders[i];
                final surface = Theme.of(context).colorScheme.surface;
                final onSurface = Theme.of(context).colorScheme.onSurface;

                return InkWell(
                  onTap: () => _onOrderTapped(order),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.id}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(order.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _statusLabel(order.status),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor(order.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        if (order.items.isNotEmpty) ...[
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.items.first.productName,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.items.length > 1
                                          ? '${order.items.first.quantity} barang ( +${order.items.length - 1} lainnya )'
                                          : '${order.items.first.quantity} barang',
                                      style: TextStyle(fontSize: 12, color: onSurface.withValues(alpha: 0.5)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Belanja', style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.7))),
                            Text(
                              _formatPrice(order.totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
