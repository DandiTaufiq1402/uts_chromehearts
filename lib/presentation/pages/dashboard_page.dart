import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../../core/constants/app_colors.dart';
import 'product_detail_page.dart';
import 'cart_page.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    // Tarik data saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  // Fungsi format Rupiah
  String formatRupiah(int price) {
    return 'Rp ${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'CHROME HEARTS',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontFamily: 'Serif',
          ),
        ),
        actions: [
          // ✅ Tombol Keranjang
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),

          // ✅ Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await Provider.of<AuthProvider>(
                context,
                listen: false,
              ).logout();

              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),

      body: productProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.black),
            )
          : productProvider.errorMessage != null
              ? Center(child: Text(productProvider.errorMessage!))
              : RefreshIndicator(
                  color: Colors.black,
                  onRefresh: () => productProvider.fetchProducts(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.products[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailPage(product: product),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: product.imageUrl != null &&
                                        product.imageUrl!.isNotEmpty
                                    ? Image.network(
                                        product.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) =>
                                            const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.inventory_2_outlined,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              product.name.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatRupiah(product.price),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}