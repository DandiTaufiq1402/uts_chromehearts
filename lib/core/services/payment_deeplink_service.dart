import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class PaymentCallbackData {
  final String status; // 'success', 'failed', 'cancelled'
  final String? reference; // INV-123
  final String? transactionId;

  const PaymentCallbackData({
    required this.status,
    this.reference,
    this.transactionId,
  });

  bool get isSuccess => status == 'success';
}

class PaymentDeeplinkService {
  // 1. Singleton instance
  static final PaymentDeeplinkService _instance = PaymentDeeplinkService._();

  // 2. Factory constructor
  factory PaymentDeeplinkService() => _instance;

  // 3. Private constructor
  PaymentDeeplinkService._();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  // Broadcast stream for callback
  final _callbackController = StreamController<PaymentCallbackData>.broadcast();
  Stream<PaymentCallbackData> get onCallback => _callbackController.stream;

  // Pending callback for cold start
  PaymentCallbackData? _pendingCallback;

  PaymentCallbackData? consumePendingCallback() {
    final data = _pendingCallback;
    _pendingCallback = null;
    return data;
  }

  Future<void> init() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleUri(uri, isColdStart: true);
      }
    } catch (_) {
      // Tolerate error if no initial link
    }

    _subscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri, {bool isColdStart = false}) {
    debugPrint('[PaymentDeeplinkService] URI received: $uri');
    debugPrint('[PaymentDeeplinkService] Cold start: $isColdStart');

    if (uri.scheme == 'pasarmalam' && uri.host == 'payment-callback') {
      debugPrint('[PaymentDeeplinkService] Callback params: ${uri.queryParameters}');
      final data = PaymentCallbackData(
        status: uri.queryParameters['status'] ?? 'unknown',
        reference: uri.queryParameters['reference'],
        transactionId: uri.queryParameters['transaction_id'],
      );

      if (isColdStart) {
        _pendingCallback = data;
      }

      _callbackController.add(data);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _callbackController.close();
  }

  static String buildDeeplinkUrl({
    required String orderId,
    required double amount,
    String? description,
  }) {
    final uri = Uri(
      scheme: 'dompetkampus',
      host: 'pay',
      queryParameters: {
        'merchant_id': 'MCH_PASAR_MALAM',
        'merchant_name': 'Pasar Malam',
        'amount': amount.toInt().toString(),
        'description': (description != null && description.isNotEmpty)
            ? description
            : 'Order #$orderId',
        'reference': 'INV-$orderId',
        'callback': 'pasarmalam://payment-callback',
      },
    );
    return uri.toString();
  }
}
