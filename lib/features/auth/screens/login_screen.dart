import 'package:flutter/material.dart';
import 'package:det/services/auth_service.dart';
import 'package:det/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _authService.login(
          _emailController.text,
          _passwordController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Successful!')),
        );

        // โหลดข้อมูลผู้ใช้ใหม่ผ่าน AuthProvider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.loadUser();

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลังสีดำ
          Container(
            color: Colors.black,
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // โลโก้หรือชื่อแอป
                  Text(
                    '@ Det',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),

                  // ฟอร์มล็อกอิน
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // ช่องกรอกอีเมล
                          TextFormField(
                            controller: _emailController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'อีเมล',
                              labelStyle: TextStyle(color: Colors.white70),
                              prefixIcon: Icon(Icons.person, color: Colors.white70),
                              filled: true,
                              fillColor: Colors.grey[900],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณาใส่อีเมลของคุณ';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),

                          // ช่องกรอกรหัสผ่าน
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'รหัสผ่าน',
                              labelStyle: TextStyle(color: Colors.white70),
                              prefixIcon: Icon(Icons.lock, color: Colors.white70),
                              filled: true,
                              fillColor: Colors.grey[900],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณาใส่รหัสผ่าน';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 35),

                          // ปุ่มล็อกอิน
                          _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : ElevatedButton(
                            onPressed: _login,
                            child: Text(
                              'เข้าสู่ระบบ',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black, // กำหนดตัวหนังสือเป็นสีดำ
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // พื้นหลังของปุ่มเป็นสีขาว
                              padding: EdgeInsets.symmetric(vertical: 16), // เพิ่ม Padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // มุมโค้งมน
                              ),
                              minimumSize: Size(double.infinity, 50), // ปรับปุ่มให้เต็มความกว้าง
                            ),
                          )
                          ,
                          SizedBox(height: 20),

                          // ลิงก์ลืมรหัสผ่าน
                          GestureDetector(
                            onTap: () {
                              // ลิงก์ไปหน้าลืมรหัสผ่าน
                            },
                            child: Text(
                              'ลืมรหัสผ่านใช่ไหม',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          SizedBox(height: 80),

                          // สมัครสมาชิก
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ยังไม่มีบัญชีใช่ไหม ',
                                style: TextStyle(color: Colors.white70),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text(
                                  'สมัครใช้งาน',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10), // เพิ่มระยะห่าง

// ปุ่มเข้าสู่แอปโดยไม่ต้องล็อกอิน
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/home'); // ไปหน้า HomeScreen
                            },
                            child: Text(
                              '[ เข้าสู่ระบบภายหลัง ]',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                decoration: TextDecoration.underline, // ขีดเส้นใต้ให้ดูเหมือนลิงก์
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
