import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:det/features/auth/providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  // ดึงข้อมูลการแจ้งเตือนจาก API
  Future<void> _fetchNotifications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId; // ดึง userId จาก AuthProvider

    if (userId == null) {
      print('User ID not found.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final String apiUrl =
        '${dotenv.env['API_BASE_URL']}/det/notifications?user_id=$userId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          notifications = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        print('Failed to fetch notifications: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'กิจกรรม',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? Center(
        child: Text(
          'ไม่มีการแจ้งเตือน',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                '${dotenv.env['API_BASE_URL']}/det/img/profile/${notification['sender_id']}?timestamp=${DateTime.now().millisecondsSinceEpoch}',
              ),
            ),
            title: Row(
              children: [
                Text(
                  '${notification['users_notifications_sender_idTousers']['username']} ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    notification['message'] ?? 'ไม่มีข้อความ',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              _formatTime(notification['created_at']),
              style: TextStyle(color: Colors.grey),
            ),
            trailing: SizedBox(
              width: 90,
              height: 35,
              child: OutlinedButton(
                onPressed: () {
                  // กำหนดฟังก์ชันเพิ่มเติมเมื่อกดปุ่ม
                },
                child: Text(
                  'ติดตามกลับ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(70, 35),
                  padding:
                  EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.black,
    );
  }

  String _formatTime(String isoTime) {
    final DateTime time = DateTime.parse(isoTime);
    final Duration diff = DateTime.now().difference(time);

    if (diff.inSeconds < 60) return '${diff.inSeconds} วินาทีที่แล้ว';
    if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
    if (diff.inHours < 24) return '${diff.inHours} ชั่วโมงที่แล้ว';
    return '${diff.inDays} วันที่แล้ว';
  }
}
