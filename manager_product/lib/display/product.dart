class Product {
  String id;
  String name;
  double price;
  String category;
  String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
  });

  // Chuyển đổi từ JSON sang Product object
  factory Product.fromJson(Map<dynamic, dynamic> json, String id) {
    return Product(
      id: id, // ID của sản phẩm
      name: json['name'] != null
          ? json['name'] as String
          : '', // Nếu name là null thì mặc định là ''
      price: (json['price'] != null ? json['price'] as num : 0)
          .toDouble(), // Đảm bảo price là double
      category: json['category'] != null
          ? json['category'] as String
          : '', // Nếu category là null thì mặc định là ''
      imageUrl: json['imageUrl'] != null
          ? json['imageUrl'] as String
          : '', // Nếu imageUrl là null thì mặc định là ''
    );
  }

  // Chuyển đổi Product object sang JSON để lưu vào Firebase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}
