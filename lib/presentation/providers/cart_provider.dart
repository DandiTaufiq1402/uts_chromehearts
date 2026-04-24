import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(ProductModel product) {
    if (_items.containsKey(product.id.toString())) {
      _items.update(
        product.id.toString(),
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id.toString(),
        () => CartItem(product: product),
      );
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}