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
          notifications = data.map((item) {
            return Map<String, dynamic>.from(item);
          }).toList();
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
          final String type = notification['type'] ?? 'other';
          final String senderUsername =
              notification['sender']?['username'] ?? 'ไม่ทราบชื่อ';
          final String message = _getMessage(notification);
          final bool isFollowNotification = type == 'follow';

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                  '${dotenv.env['API_BASE_URL']}/det/img/profile/${notification['sender_id']}?timestamp=${DateTime.now().millisecondsSinceEpoch}'
              ),
            ),
            title: Row(
              children: [
                Text(
                  '$senderUsername ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    message,
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
          );
        },
      ),
      backgroundColor: Colors.black,
    );
  }

  // ✅ กำหนดข้อความแจ้งเตือนให้เหมาะกับประเภทของแจ้งเตือน
  String _getMessage(Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'follow':
        return 'ติดตามคุณ';
      case 'like':
        return 'ถูกใจโพสต์ของคุณ';
      case 'comment':
        return 'แสดงความคิดเห็นในโพสต์ของคุณ';
      default:
        return notification['message'] ?? 'มีการแจ้งเตือนใหม่';
    }
  }



  // ✅ แปลงเวลาจาก ISO ให้เป็นข้อความอ่านง่าย
  String _formatTime(String isoTime) {
    final DateTime time = DateTime.parse(isoTime);
    final Duration diff = DateTime.now().difference(time);

    if (diff.inSeconds < 60) return '${diff.inSeconds} วินาทีที่แล้ว';
    if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
    if (diff.inHours < 24) return '${diff.inHours} ชั่วโมงที่แล้ว';
    return '${diff.inDays} วันที่แล้ว';
  }
}
