import 'package:flutter/material.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/models/cart_model.dart';

enum CartStatus { initial, loading, loaded, error }

class CartProvider with ChangeNotifier {
  final CartRepository _repository = CartRepositoryImpl();
  
  CartStatus _status = CartStatus.initial;
  CartStatus get status => _status;

  CartModel? _cart;
  CartModel? get cart => _cart;

  String? _error;
  String? get error => _error;

  bool _isAdding = false;
  bool get isAdding => _isAdding;

  int get itemCount => _cart?.itemCount ?? 0;

  Future<void> fetchCart() async {
    _status = CartStatus.loading;
    notifyListeners();
    
    try {
      _cart = await _repository.getCart();
      _status = CartStatus.loaded;
    } catch (e) {
      _status = CartStatus.error;
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<bool> addToCart(int productId, int quantity) async {
    _isAdding = true;
    notifyListeners();
    
    try {
      await _repository.addToCart(productId, quantity);
      await fetchCart();
      _isAdding = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isAdding = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateItem(int cartItemId, int quantity) async {
    try {
      await _repository.updateCartItem(cartItemId, quantity);
      await fetchCart();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      await _repository.removeCartItem(cartItemId);
      await fetchCart();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      await _repository.clearCart();
      // Langsung set state ke kosong tanpa fetch ulang — lebih cepat
      _cart = CartModel(items: [], total: 0, itemCount: 0);
      _status = CartStatus.loaded;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}