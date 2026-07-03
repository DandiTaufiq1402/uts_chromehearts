import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  @override
  Future<OrderModel> checkout({
    required String shippingAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    try {
      final response = await DioClient.instance.post(
        '/orders/checkout',
        data: {
          'shipping_address': shippingAddress,
          'notes': notes ?? '',
          'payment_method': paymentMethod,
        },
      );

      // Asumsi backend mengembalikan data order lengkap setelah sukses
      // Contoh { data: { id: 1, total_amount: ..., items: [...] } }
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        
        // Membersihkan cart lokal secara manual, tapi bisa juga jika backend yang membersihkan DB
        // Namun kita bisa panggil clearCart juga jika perlu.
        // Di sini kita anggap backend sudah mengosongkan cart,
        // jadi tidak perlu memanggil clearCart secara explisit, atau panggil untuk sinkronisasi state.

        return OrderModel.fromJson(data);
      }
      throw Exception('Format response tidak sesuai');
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? 'Gagal melakukan checkout');
      }
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> getMyOrders({int page = 1, int limit = 10}) async {
    try {
      final response = await DioClient.instance.get(
        '/orders',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data['data'] ?? response.data;
        return dataList.map((e) => OrderModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? 'Gagal memuat daftar pesanan');
      }
      rethrow;
    }
  }

  @override
  Future<OrderModel> getOrderDetail(int orderId) async {
    try {
      final response = await DioClient.instance.get('/orders/$orderId');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return OrderModel.fromJson(data);
      }
      throw Exception('Format response tidak sesuai');
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? 'Gagal memuat detail pesanan');
      }
      rethrow;
    }
  }
}
