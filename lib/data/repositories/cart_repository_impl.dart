import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../domain/repositories/cart_repository.dart';
import '../models/cart_model.dart';

class CartRepositoryImpl implements CartRepository {
  
  @override
  Future<CartModel> getCart() async {
    try {
      final response = await DioClient.instance.get('/carts');
      
      // Asumsi response backend: { data: { id, user_id, items: [...] } }
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return CartModel.fromJson(data);
      }
      return CartModel(items: [], total: 0, itemCount: 0);
    } catch (e) {
      // Jika belum ada keranjang, kembalikan keranjang kosong
      if (e is DioException && e.response?.statusCode == 404) {
        return CartModel(items: [], total: 0, itemCount: 0);
      }
      rethrow;
    }
  }

  @override
  Future<void> addToCart(int productId, int quantity) async {
    try {
      await DioClient.instance.post('/carts', data: {
        'product_id': productId,
        'quantity': quantity,
      });
    } catch (e) {
      if (e is DioException) {
        final backendError = e.response?.data?['error'];
        final message = e.response?.data?['message'] ?? 'Gagal menambahkan ke keranjang';
        throw Exception('$message${backendError != null ? ': $backendError' : ''}');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateCartItem(int cartItemId, int quantity) async {
    try {
      await DioClient.instance.put('/carts/$cartItemId', data: {
        'quantity': quantity,
      });
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? 'Gagal memperbarui keranjang');
      }
      rethrow;
    }
  }

  @override
  Future<void> removeCartItem(int cartItemId) async {
    try {
      await DioClient.instance.delete('/carts/$cartItemId');
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? 'Gagal menghapus item dari keranjang');
      }
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      // Asumsi endpoint untuk menghapus semua item dari keranjang
      await DioClient.instance.delete('/carts');
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? 'Gagal mengosongkan keranjang');
      }
      rethrow;
    }
  }
}
