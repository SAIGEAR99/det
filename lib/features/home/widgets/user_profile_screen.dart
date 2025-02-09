import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:det/features/auth/providers/auth_provider.dart';
import 'package:det/features/home/screens/home_content_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;


  const UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isPageLoading = true;
  late String fullName;
  late String profileImg;
  late String bio;
  late int followers;
  late String link;

  bool isUserLoading = true;
  bool isPostLoading = true;
  bool isFollowing = false;
  bool isLoadingFollowStatus = true;

  List<Map<String, dynamic>> userPosts = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isPageLoading = false; // ปิดสถานะการโหลดหลังจาก 1 วินาที
      });
    });

    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String sessionUserId = authProvider.userId ?? '';

      setState(() {
        fullName = widget.user['full_name'] ?? 'ไม่พบชื่อ';
        profileImg = widget.user['profile_img'] ?? '';
        bio = widget.user['bio'] ?? 'ไม่มีข้อมูล';
        followers = widget.user['followers'] ?? 0;
        link = widget.user['link'] ?? '';
      });
      _checkFollowStatus(sessionUserId);
      _fetchUpdatedUserData();
      _fetchUserPosts();
    });
  }


  Future<void> _checkFollowStatus(String sessionUserId) async {
    if (sessionUserId.isEmpty) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String apiUrl =
        '${authProvider.apiBaseUrl}/det/follow/status?follower_id=$sessionUserId&following_id=${widget.user['user_id']}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("🔍 Follow Status Response: $data");

        setState(() {
          isFollowing = data['is_following'] ?? false;
          isLoadingFollowStatus = false;
        });
      } else {
        print("❌ Failed to get follow status: ${response.statusCode}");
        setState(() {
          isLoadingFollowStatus = false;
        });
      }
    } catch (e) {
      print('❌ Error checking follow status: $e');
      setState(() {
        isLoadingFollowStatus = false;
      });
    }
  }


  Future<void> _toggleFollow() async {
    if (isLoadingFollowStatus) return;
    setState(() {
      isLoadingFollowStatus = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String sessionUserId = authProvider.userId ?? '';
    if (sessionUserId.isEmpty) return;

    final String apiUrl = '${authProvider.apiBaseUrl}/det/follow/toggle';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          "follower_id": sessionUserId,
          "following_id": widget.user['user_id']
        }),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          isFollowing = !isFollowing;
          followers += isFollowing ? 1 : -1;
        });
      }
    } catch (e) {
      print('Error toggling follow status: $e');
    } finally {
      _checkFollowStatus(sessionUserId);
    }
  }

  Future<void> _fetchUpdatedUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String sessionUserId = authProvider.userId ?? '';

    final String apiUrl =
        '${authProvider.apiBaseUrl}/det/user/fetch?user_id=${widget.user['user_id']}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          fullName = data['full_name'] ?? fullName;
          bio = data['bio'] ?? bio;
          followers = data['followers'] ?? followers;
          link = data['link'] ?? link;
          profileImg = data['profile_img'] ?? profileImg;
          isUserLoading = false;
        });

        _checkFollowStatus(sessionUserId);
      } else {
        setState(() {
          isUserLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isUserLoading = false;
      });
    }
  }



  Future<void> _fetchUserPosts() async {
    final String userId = widget.user['user_id'].toString();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String apiUrl =
        '${authProvider.apiBaseUrl}/det/post/getAllPosts';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          userPosts = data
              .where((post) => post['user_id'].toString() == userId)
              .toList()
              .cast<Map<String, dynamic>>();
          isPostLoading = false;
        });
      } else {
        print('Failed to load posts: ${response.statusCode}');
        setState(() {
          isPostLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        isPostLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: isUserLoading
            ? Text('Loading...', style: TextStyle(color: Colors.grey))
            : Text(widget.user['username'] ?? 'ไม่พบชื่อผู้ใช้',
            style: TextStyle(color: Colors.white)),
      ),

      body: isUserLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImg.isNotEmpty
                      ? NetworkImage(
                    '${authProvider.apiBaseUrl}/det/img/profile/${widget.user['user_id']}?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                  )
                      : null,
                  onBackgroundImageError: (_, __) {
                    setState(() {
                      profileImg = '';
                    });
                  },
                  child: profileImg.isEmpty
                      ? Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text(bio, style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 5),
                      if (followers > 0 || link.isNotEmpty)
                        Text(
                          'ผู้ติดตาม $followers คน${link.isNotEmpty ? ' • $link' : ''}',
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
              child: Builder(
                builder: (context) {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final String? currentUserId = authProvider.userId;
                  final String profileUserId = widget.user['user_id'].toString(); // แปลง user_id ให้เป็น String

                  // กรณียังไม่ได้เข้าสู่ระบบ
                  if (currentUserId == null) {
                    return ElevatedButton(
                      onPressed: () {
                        // ไปยังหน้า Login
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // สีพื้นหลังของปุ่ม
                        foregroundColor: Colors.white, // สีข้อความ
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'กรุณาเข้าสู่ระบบเพื่อใช้ฟีเจอร์นี้',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  // กรณีดูโปรไฟล์ตัวเอง
                  if (currentUserId == profileUserId) {
                    return OutlinedButton(
                      onPressed: () {
                        // การแชร์โปรไฟล์
                        print('แชร์โปรไฟล์ของฉัน');
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white, width: 1.5), // ขอบสีขาว
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'แชร์โปรไฟล์',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  // กรณีดูโปรไฟล์คนอื่น
                  return isFollowing
                      ? OutlinedButton(
                    onPressed: isLoadingFollowStatus ? null : _toggleFollow,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white, width: 1.5),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'กำลังติดตาม',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  )
                      : ElevatedButton(
                    onPressed: isLoadingFollowStatus ? null : _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'ติดตาม',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),


          SizedBox(height: 10),
          Divider(color: Colors.grey[800]),
          Expanded(
            child: isPostLoading
                ? Center(child: CircularProgressIndicator())
                : userPosts.isEmpty
                ? Center(
              child: Text(
                'ยังไม่มีโพสต์',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: userPosts.length,
              itemBuilder: (context, index) {
                final post = userPosts[index];
                return PostWidget(post: post);
              },
            ),
          ),
        ],
      ),
    );
  }
}
