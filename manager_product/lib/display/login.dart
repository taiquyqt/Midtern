import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manager_product/display/register.dart';
import 'package:manager_product/display/list_product.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ListProductScreen()),
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng nhập thất bại'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Nhập'),
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 32, 129, 198), Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            // Thêm SingleChildScrollView để tránh tràn màn hình
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tiêu đề lớn
                const Text(
                  'Đăng nhập tài khoản',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // TextField cho email
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 221, 207, 207),
                          width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255),
                          width: 1.5),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)),
                ),
                const SizedBox(height: 20),
                // TextField cho mật khẩu
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255),
                          width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255),
                          width: 1.5),
                    ),
                  ),
                  obscureText: true,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 223, 213, 213)),
                ),
                const SizedBox(height: 20),
                // Nút đăng nhập
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Màu nền nút
                    foregroundColor: Colors.black, // Màu chữ nút
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Đường viền bo tròn
                    ),
                  ),
                  child:
                      const Text('Đăng Nhập', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
                // Nút điều hướng tới màn hình đăng ký
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegistrationScreen()),
                    );
                  },
                  child: const Text(
                    'Chưa có tài khoản? Đăng ký',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 16,
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
}
