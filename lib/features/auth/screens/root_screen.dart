import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:det/features/auth/providers/auth_provider.dart';
import 'package:det/features/auth/screens/login_screen.dart';
import 'package:det/features/home/screens/home_screen.dart';

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.loadUser(); // โหลดสถานะการล็อกอิน
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // ถ้ากำลังโหลดข้อมูล
    if (authProvider.isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // แสดงหน้ารอโหลด
      );
    }

    // ถ้าผู้ใช้ล็อกอินแล้ว
    if (authProvider.isLoggedIn) {
      return HomeScreen(); // ไปหน้า Home
    }

    // ถ้าผู้ใช้ยังไม่ได้ล็อกอิน
    return LoginScreen(); // ไปหน้า Login
  }
}
