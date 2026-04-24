import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>(); // Pantau data keranjang

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('YOUR CART', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text('Keranjang masih kosong.', style: TextStyle(color: Colors.grey, fontSize: 18)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, i) {
                      var cartItem = cart.items.values.toList()[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            cartItem.product.imageUrl ?? 'https://via.placeholder.com/150',
                          ),
                          backgroundColor: Colors.grey[900],
                        ),
                        title: Text(cartItem.product.name, style: const TextStyle(color: Colors.white)),
                        subtitle: Text('Qty: ${cartItem.quantity} x Rp ${cartItem.product.price}', style: const TextStyle(color: Colors.grey)),
                        trailing: Text(
                          'Rp ${cartItem.product.price * cartItem.quantity}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total:', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          Text(
                            'Rp ${cart.totalAmount}',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        onPressed: cart.items.isEmpty ? null : () {
                          // Pura-pura checkout, lalu bersihkan keranjang
                          cart.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Checkout Berhasil! Terima kasih.')),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('CHECKOUT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}