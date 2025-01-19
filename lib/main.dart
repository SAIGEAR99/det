import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:det/features/auth/providers/auth_provider.dart';
import 'package:det/features/auth/screens/login_screen.dart';
import 'package:det/features/home/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // โหลดไฟล์ .env ก่อนเริ่มต้นแอป
  try {
    await dotenv.load(fileName: ".env");
    print('Environment variables loaded successfully.');

    print("Loaded API_BASE_URL: ${dotenv.env['API_BASE_URL']}");
  } catch (e) {
    print('Error loading .env file: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'det',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RootScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

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
      authProvider.loadUser(); // เรียก loadUser เมื่อแอปเริ่มต้น
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (authProvider.isLoggedIn) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}


