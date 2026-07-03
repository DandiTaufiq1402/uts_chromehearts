import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';
// import '../../core/constants/app_colors.dart'; // Bisa dihapus jika tidak dipakai langsung di sini
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
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    // Simpan warna dinamis ke variabel agar kode lebih rapi
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text('CHROME HEARTS', style: TextStyle(color: onSurfaceColor)),
        actions: [
          // ✅ Toggle Dark Mode
          Switch(
            value: context.watch<ThemeProvider>().isDark,
            onChanged: (value) {
              context.read<ThemeProvider>().toggle();
            },
          ),

          // ✅ Tombol Keranjang (Warna Dinamis)
          IconButton(
            icon: Icon(Icons.shopping_bag_outlined, color: onSurfaceColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),

          // ✅ Tombol Logout (Warna Dinamis)
          IconButton(
            icon: Icon(Icons.logout, color: onSurfaceColor),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();

              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),

      body: productProvider.isLoading
          ? Center(
              // ✅ Loading dinamis
              child: CircularProgressIndicator(color: primaryColor),
            )
          : productProvider.errorMessage != null
          ? Center(
              child: Text(
                productProvider.errorMessage!,
                style: TextStyle(color: onSurfaceColor),
              ),
            )
          : RefreshIndicator(
              color: primaryColor,
              onRefresh: () => productProvider.fetchProducts(),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                              // ✅ Background foto dinamis (abu terang di light, abu gelap di dark)
                              color: onSurfaceColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child:
                                product.imageUrl != null &&
                                    product.imageUrl!.isNotEmpty
                                ? Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Icon(
                                      Icons.image_not_supported,
                                      color: onSurfaceColor.withOpacity(0.5),
                                    ),
                                  )
                                : Icon(
                                    Icons.inventory_2_outlined,
                                    size: 50,
                                    color: onSurfaceColor.withOpacity(0.5),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          product.name.toUpperCase(),
                          style: TextStyle(
                            color: onSurfaceColor, // ✅ Teks judul dinamis
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatRupiah(product.price),
                          style: TextStyle(
                            // ✅ Teks harga dinamis (sedikit lebih redup)
                            color: onSurfaceColor.withOpacity(0.6),
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
