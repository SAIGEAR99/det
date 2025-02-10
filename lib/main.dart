import 'dart:convert';
import 'dart:io'; // สำหรับ HttpOverrides
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:det/features/auth/providers/auth_provider.dart';
import 'package:det/features/auth/screens/login_screen.dart';
import 'package:det/features/home/screens/home_screen.dart';
import 'package:det/features/auth/screens/register_screen.dart';

// URL สำหรับ Config API
const String apiConfigUrl =
    "https://gist.github.com/SAIGEAR99/0487615042d0a65cc26579f46c45922a/raw/config.json";
const URL_SEC2 = "https://f059-159-192-21-209.ngrok-free.app";

// MyHttpOverrides: ข้ามการตรวจสอบ SSL Certificate
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// main(): จุดเริ่มต้นของแอป
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ตั้งค่า HttpOverrides เพื่อข้าม SSL (สำหรับการพัฒนา)
  HttpOverrides.global = MyHttpOverrides();

  // โหลด API Base URL
  String apiBaseUrl = await fetchApiBaseUrl();
  print("Loaded API_BASE_URL: $apiBaseUrl");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiBaseUrl)),
      ],
      child: MyApp(),
    ),
  );
}

// ฟังก์ชันโหลด API Base URL จาก JSON
Future<String> fetchApiBaseUrl() async {
  try {
    final response = await http.get(Uri.parse(apiConfigUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Config Loaded: $data'); // Debug JSON ที่ได้มา

      // ใช้ "API_URL" แทน "API_BASE_URL"
      if (data.containsKey('API_URL') && data['API_URL'] != null) {
        String apiBaseUrl = data['API_URL'];
        print('API Loaded: $apiBaseUrl'); // Debug
        return apiBaseUrl;
      } else {
        print('API_URL missing in JSON response');
        return URL_SEC2;
      }
    } else {
      print('Failed to load API config. Status Code: ${response.statusCode}');
      return URL_SEC2;
    }
  } catch (e) {
    print('Error fetching API config: $e');
    return URL_SEC2;
  }
}

// MyApp: ตัวหลักของแอป
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
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}

// RootScreen: ตรวจสอบสถานะผู้ใช้และเปลี่ยนหน้าตามสถานะ
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
      authProvider.loadUser(); // โหลดข้อมูลผู้ใช้เมื่อแอปเริ่มต้น
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
