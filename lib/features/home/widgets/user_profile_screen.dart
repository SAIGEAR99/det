import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late String username;
  late String profileImg;
  late String bio;
  late int followers;
  late String link;
  bool isLoading = true; // เพิ่มตัวแปรเพื่อแสดงสถานะโหลดข้อมูล

  @override
  void initState() {
    super.initState();
    // ใช้ค่าที่รับมาแสดงก่อน
    username = widget.user['username'] ?? 'ไม่พบชื่อผู้ใช้';
    profileImg = widget.user['profile_img'] ?? '';
    bio = widget.user['bio'] ?? 'ไม่มีข้อมูล';
    followers = widget.user['followers'] ?? 0;
    link = widget.user['link'] ?? 'ไม่มีลิงก์';

    // ดึงข้อมูลอัปเดตจาก API
    _fetchUpdatedUserData();
  }

  Future<void> _fetchUpdatedUserData() async {
    final String apiUrl =
        '${dotenv.env['API_BASE_URL']}/det/user/fetch?user_id=${widget.user['user_id']}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          bio = data['bio'] ?? bio;
          followers = data['followers'] ?? followers;
          link = data['link'] ?? link;
          isLoading = false; // โหลดข้อมูลเสร็จแล้ว
        });
      } else {
        print('Error fetching user data: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: isLoading
            ? Text('Loading...', style: TextStyle(color: Colors.grey)) // แสดง Loading...
            : Text(username, style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // แสดง Indicator ระหว่างโหลดข้อมูล
          : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImg.isNotEmpty
                        ? NetworkImage('$profileImg?timestamp=${DateTime.now().millisecondsSinceEpoch}')
                        : AssetImage('assets/profile_placeholder.png') as ImageProvider,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(username, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text(bio, style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 5),
                        Text(
                          'ผู้ติดตาม $followers คน' + (link.isNotEmpty ? '\n$link' : ''),
                          style: TextStyle(color: Colors.grey),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Add follow functionality here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('ติดตาม', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            SizedBox(height: 10),
            Divider(color: Colors.grey[800]),
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'เธรด'),
                      Tab(text: 'การตอบกลับ'),
                      Tab(text: 'รีโพสต์'),
                    ],
                  ),
                  Container(
                    height: 400,
                    child: TabBarView(
                      children: [
                        Center(child: Text('ไม่มีเธรด', style: TextStyle(color: Colors.grey))),
                        Center(child: Text('ไม่มีการตอบกลับ', style: TextStyle(color: Colors.grey))),
                        Center(child: Text('ไม่มีรีโพสต์', style: TextStyle(color: Colors.grey))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
