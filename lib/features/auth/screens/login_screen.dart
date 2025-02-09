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

  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final authService = AuthService(authProvider.apiBaseUrl); // รับ API URL จาก AuthProvider

        final result = await authService.login(
          _emailController.text,
          _passwordController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Successful!')),
        );

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
          Container(
            color: Colors.black,
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '@ Det',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
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

                          _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : ElevatedButton(
                            onPressed: _login,
                            child: Text(
                              'เข้าสู่ระบบ',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                          SizedBox(height: 20),

                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'ลืมรหัสผ่านใช่ไหม',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          SizedBox(height: 80),

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
                          SizedBox(height: 10),

                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                            child: Text(
                              '[ เข้าสู่ระบบภายหลัง ]',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
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
