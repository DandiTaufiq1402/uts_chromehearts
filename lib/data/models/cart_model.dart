class CartProductModel {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  CartProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) =>
      CartProductModel(
        id: json['id'] as int? ?? json['ID'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: json['image_url'] as String? ?? '',
        category: json['category'] as String? ?? '',
      );
}

class CartItemModel {
  final int id;
  final int cartId;
  final int productId;
  final int quantity;
  final double subtotal;
  final CartProductModel product;

  CartItemModel({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.subtotal,
    required this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = CartProductModel.fromJson(
      json['product'] as Map<String, dynamic>? ?? {},
    );
    final quantity = json['quantity'] as int? ?? 0;
    
    // Supabase mungkin tidak mengembalikan subtotal, jadi kita hitung ulang
    final apiSubtotal = (json['subtotal'] as num?)?.toDouble() ?? 0.0;
    final calculatedSubtotal = apiSubtotal > 0 ? apiSubtotal : product.price * quantity;

    return CartItemModel(
      id: json['id'] as int? ?? json['ID'] as int? ?? 0,
      cartId: json['cart_id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      quantity: quantity,
      subtotal: calculatedSubtotal,
      product: product,
    );
  }
}

class CartModel {
  final int id;
  final String userId;
  final List<CartItemModel> items;
  final double total;
  final int itemCount;

  CartModel({
    this.id = 0,
    this.userId = '',
    this.items = const [],
    this.total = 0.0,
    this.itemCount = 0,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>? ?? [])
        .map((e) => CartItemModel.fromJson(e))
        .toList();

    // Hitung ulang total secara lokal agar akurat
    final totalCalculated = itemsList.fold<double>(0.0, (sum, i) => sum + i.subtotal);
    final countCalculated = itemsList.fold<int>(0, (sum, i) => sum + i.quantity);

    return CartModel(
      id: json['id'] as int? ?? json['ID'] as int? ?? 0,
      userId: json['user_id']?.toString() ?? '',
      items: itemsList,
      total: totalCalculated,
      itemCount: countCalculated,
    );
  }
}
