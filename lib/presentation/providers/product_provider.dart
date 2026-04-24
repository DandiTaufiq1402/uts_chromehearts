import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Nembak API Golang kita
      final response = await DioClient.instance.get('/products');

      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> data = response.data['data'];
        _products = data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        _errorMessage = response.data['message'] ?? 'Gagal memuat produk';
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _errorMessage = 'Sesi habis, silakan login kembali.';
      } else {
        _errorMessage = 'Gagal terhubung ke server backend';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}