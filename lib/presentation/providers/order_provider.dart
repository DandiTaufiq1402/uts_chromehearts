import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/repositories/order_repository.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/models/order_model.dart';

enum OrderStatus { initial, loading, success, error }
enum PaymentCheckStatus { idle, checking, paid, failed }

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository = OrderRepositoryImpl();

  OrderStatus _checkoutStatus = OrderStatus.initial;
  OrderStatus get checkoutStatus => _checkoutStatus;

  PaymentCheckStatus _paymentCheckStatus = PaymentCheckStatus.idle;
  PaymentCheckStatus get paymentCheckStatus => _paymentCheckStatus;

  OrderModel? _lastOrder;
  OrderModel? get lastOrder => _lastOrder;

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  String? _error;
  String? get error => _error;

  Timer? _pollingTimer;

  Future<bool> checkout({
    required String shippingAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    _checkoutStatus = OrderStatus.loading;
    notifyListeners();

    try {
      _lastOrder = await _repository.checkout(
        shippingAddress: shippingAddress,
        notes: notes,
        paymentMethod: paymentMethod,
      );
      _checkoutStatus = OrderStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _checkoutStatus = OrderStatus.error;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMyOrders({int page = 1}) async {
    _checkoutStatus = OrderStatus.loading;
    notifyListeners();
    try {
      _orders = await _repository.getMyOrders(page: page);
      _checkoutStatus = OrderStatus.success;
    } catch (e) {
      _checkoutStatus = OrderStatus.error;
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Dipanggil dari PaymentPendingPage untuk mengecek status pesanan secara manual
  Future<void> checkPaymentStatus(int orderId) async {
    _paymentCheckStatus = PaymentCheckStatus.checking;
    notifyListeners();

    try {
      final updatedOrder = await _repository.getOrderDetail(orderId);
      if (updatedOrder.status == 'processing' || updatedOrder.status == 'paid') {
        _paymentCheckStatus = PaymentCheckStatus.paid;
      } else {
        _paymentCheckStatus = PaymentCheckStatus.idle;
      }
    } catch (_) {
      _paymentCheckStatus = PaymentCheckStatus.failed;
    } finally {
      notifyListeners();
    }
  }

  // Mulai polling otomatis setiap 5 detik
  void startPaymentPolling(int orderId) {
    stopPaymentPolling(); // pastikan tidak ada timer ganda
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final updatedOrder = await _repository.getOrderDetail(orderId);
        if (updatedOrder.status == 'processing' || updatedOrder.status == 'paid') {
          _paymentCheckStatus = PaymentCheckStatus.paid;
          notifyListeners();
          stopPaymentPolling();
        }
      } catch (e) {
        // Abaikan error jaringan saat polling
      }
    });
  }

  void stopPaymentPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    stopPaymentPolling();
    super.dispose();
  }
}
