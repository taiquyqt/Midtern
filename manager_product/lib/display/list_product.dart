import 'dart:io'; // Thêm thư viện này để sử dụng Image.file
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:manager_product/display/add_product.dart';
import 'package:manager_product/display/product.dart';

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({super.key});

  @override
  _ListProductScreenState createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  final DatabaseReference _productRef =
      FirebaseDatabase.instance.ref('products');
  List<Product> _products = []; // Danh sách sản phẩm

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Hàm lấy sản phẩm từ Firebase và cập nhật vào danh sách
  Future<void> _fetchProducts() async {
    _productRef.onValue.listen((event) {
      final List<Product> products = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          products.add(Product.fromJson(value, key));
        });
      }

      setState(() {
        _products = products; // Cập nhật danh sách sản phẩm
      });

      print(
          "Products fetched: ${_products.length}"); // Kiểm tra số lượng sản phẩm
    });
  }

  // Hàm hiển thị hộp thoại xác nhận khi xóa sản phẩm
  void _showDeleteConfirmationDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
              'Bạn có chắc chắn muốn xóa sản phẩm "${product.name}" không?'),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteProduct(product.id); // Xóa sản phẩm nếu nhấn "Xóa"
                Navigator.of(context).pop(); // Đóng hộp thoại sau khi xóa
              },
            ),
          ],
        );
      },
    );
  }

  // Hàm xóa sản phẩm
  void _deleteProduct(String productId) {
    _productRef.child(productId).remove().then((_) {
      _fetchProducts(); // Cập nhật lại danh sách sản phẩm sau khi xóa
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddProductScreen()),
              ).then((_) {
                _fetchProducts(); // Cập nhật lại danh sách sản phẩm khi quay lại
              });
            },
          ),
        ],
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) =>
            const Divider(), // Thêm dòng phân cách giữa các sản phẩm
        itemCount: _products.length, // Sử dụng danh sách sản phẩm gốc
        itemBuilder: (context, index) {
          final product = _products[index]; // Lấy sản phẩm từ danh sách
          return ListTile(
            title: Text(product.name),
            subtitle: Text(
                'Giá: ${product.price} VND\nLoại sản phẩm: ${product.category}'),
            leading: product.imageUrl.isNotEmpty
                ? _buildProductImage(product.imageUrl)
                : const Icon(Icons.image,
                    size: 50), // Hiển thị biểu tượng nếu không có hình ảnh
            trailing: Row(
              mainAxisSize:
                  MainAxisSize.min, // Đảm bảo kích thước nhỏ gọn của Row
              children: [
                IconButton(
                  icon: const Icon(Icons.edit,
                      color: Colors.blue), // Biểu tượng chỉnh sửa
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddProductScreen(product: product),
                      ),
                    ).then((_) {
                      _fetchProducts(); // Cập nhật lại danh sách sản phẩm khi quay lại
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete,
                      color: Colors.red), // Biểu tượng xóa
                  onPressed: () {
                    _showDeleteConfirmationDialog(
                        product); // Hiển thị hộp thoại xác nhận
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(product: product),
                ),
              ).then((_) {
                _fetchProducts(); // Cập nhật lại danh sách sản phẩm khi quay lại
              });
            },
          );
        },
      ),
    );
  }

  // Hàm xây dựng widget hiển thị hình ảnh sản phẩm
  Widget _buildProductImage(String imageUrl) {
    // Nếu URL là từ Firebase Storage
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image,
              size: 50); // Biểu tượng nếu không tải được hình ảnh
        },
      );
    } else {
      // Nếu URL là đường dẫn cục bộ, sử dụng Image.file
      return Image.file(
        File(imageUrl),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }
  }
}
