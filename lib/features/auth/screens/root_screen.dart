import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:det/features/auth/providers/auth_provider.dart';
import 'package:det/features/home/screens/home_screen.dart';

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeScreen(), // แสดงหน้า Home เสมอ
    );
  }
}
