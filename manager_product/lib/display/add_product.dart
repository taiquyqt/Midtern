import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manager_product/display/product.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey =
      GlobalKey<FormState>(); // Tạo GlobalKey để quản lý trạng thái của form
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  String? _imageUrl;
  //
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = ['Điện Thoại', 'Thời trang', 'Đồ Ăn'];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _selectedCategory = widget.product!.category;
      _imageUrl = widget.product!.imageUrl;
    }
  }

// chọn ảnh
  Future<void> _selectImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageUrl = image.path; // Lưu đường dẫn hình ảnh
      });
    }
  }

  void _addProduct() {
    // Kiểm tra xem form đã hợp lệ hay chưa
    if (_formKey.currentState!.validate()) {
      // Kiểm tra xem sản phẩm đã có hình ảnh hay chưa
      if (_imageUrl == null || _imageUrl!.isEmpty) {
        _showSnackBar('Sản phẩm này chưa có ảnh!');
        return; // Ngưng thực hiện nếu không có hình ảnh
      }

      final product = Product(
        id: widget.product?.id ?? const Uuid().v4(),
        name: _nameController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        category: _selectedCategory ?? '',
        imageUrl: _imageUrl ?? '',
      );

      if (widget.product != null) {
        FirebaseDatabase.instance
            .ref('products/${widget.product!.id}')
            .set(product.toJson())
            .then((_) {
          _showSnackBar('Cập nhật sản phẩm thành công!');
        }).catchError((error) {
          _showSnackBar('Cập nhật sản phẩm thất bại: $error');
        });
      } else {
        FirebaseDatabase.instance
            .ref('products/${product.id}')
            .set(product.toJson())
            .then((_) {
          _showSnackBar('Thêm sản phẩm thành công!');
        }).catchError((error) {
          _showSnackBar('Thêm sản phẩm thất bại: $error');
        });
      }

      Navigator.pop(context); // Trở về màn hình trước đó
    } else {
      _showSnackBar(
          'Vui lòng điền đầy đủ thông tin!'); // Thông báo lỗi nếu form không hợp lệ
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.product != null ? 'Cập nhật sản phẩm' : 'Thêm sản phẩm'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey, // Gán key form cho Form widget
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin sản phẩm',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // DropdownButtonFormField cho danh mục sản phẩm
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: const Text('Loại sản phẩm'),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn loại sản phẩm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // TextFormField cho tên sản phẩm
                _buildTextFormField(
                  controller: _nameController,
                  labelText: 'Tên sản phẩm',
                  icon: Icons.assignment,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên sản phẩm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // TextFormField cho giá sản phẩm
                _buildTextFormField(
                  controller: _priceController,
                  labelText: 'Giá sản phẩm',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá sản phẩm';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Giá sản phẩm phải là số dương';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Nút chọn hình ảnh
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _selectImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Chọn hình ảnh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 211, 211, 211),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 120),
                    ),
                  ),
                ),
                const SizedBox(height: 0),

                // Hiển thị hình ảnh nếu đã chọn
                if (_imageUrl != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        File(_imageUrl!),
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 30),

                // Nút thêm hoặc cập nhật sản phẩm
                Center(
                  child: ElevatedButton(
                    onPressed: _addProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 225, 211, 211),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 130),
                    ),
                    child: Text(
                      widget.product != null
                          ? 'Cập nhật sản phẩm'
                          : 'Thêm sản phẩm',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Hàm xây dựng widget TextFormField với các tùy chọn
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator, // Thêm validator để kiểm tra đầu vào
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: validator, // Gọi validator để kiểm tra dữ liệu
    );
  }
}
