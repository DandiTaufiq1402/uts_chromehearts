import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_model.dart';
import '../providers/cart_provider.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(product.name, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pasang sabuk pengaman HANYA di imageUrl
            Image.network(
              product.imageUrl ?? 'https://via.placeholder.com/400x400.png?text=No+Image', 
              width: double.infinity, 
              height: 400, 
              fit: BoxFit.cover
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Rp ${product.price}", style: const TextStyle(color: Colors.grey, fontSize: 20)),
                  const SizedBox(height: 20),
                  const Text("Description", style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),
                  // Langsung pakai product.description tanpa ??
                  Text(product.description, style: const TextStyle(color: Colors.grey, height: 1.5)),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () async {
                        final success = await context.read<CartProvider>().addToCart(product.id, 1);
                        if (!context.mounted) return;
                        
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Item added to cart', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
                          );
                        } else {
                          final error = context.read<CartProvider>().error ?? 'Failed to add item';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
                          );
                        }
                      },
                      child: const Text("ADD TO CART", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}