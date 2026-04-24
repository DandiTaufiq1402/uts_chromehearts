class ProductModel {
  final int id;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String category;
  final String? size;
  final String? material;
  final String? imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.size,
    this.material,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      stock: json['stock'] ?? 0,
      category: json['category'] ?? '',
      size: json['size'],
      material: json['material'],
      imageUrl: json['image_url'],
    );
  }
}