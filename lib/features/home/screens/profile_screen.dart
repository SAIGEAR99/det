import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:det/features/auth/providers/auth_provider.dart';
import 'package:det/services/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:det/features/home/screens/home_content_screen.dart';




class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  late UserService _userService;
  String userId = 'Loading...';
  String username = 'Loading...';
  String email = 'Loading...';
  String fullName = 'Loading...';
  String bio = 'Loading...';
  String createdAt = 'Loading...';
  String link = 'Loading...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _userService = UserService(authProvider.apiBaseUrl); // กำหนด API URL ให้ UserService
      authProvider.loadUser().then((_) {
        _getUserData(); // โหลดข้อมูลเพิ่มเติมเมื่อ provider พร้อม
      });
    });
  }


  void _getUserData() async {
    final response = await _userService.getUserData(context);
    if (!mounted) return; // ป้องกันการอัปเดต State ถ้า Widget ถูกทำลาย

    if (response != null) {
      setState(() {
        userId = response['user_id']?.toString() ?? '';
        username = response['username'] ?? 'ไม่ระบุชื่อผู้ใช้';
        email = response['email'] ?? 'ไม่ระบุอีเมล';
        fullName = response['full_name'] ?? 'ไม่ระบุชื่อเต็ม';
        bio = response['bio'] ?? 'ไม่มีข้อมูล';
        createdAt = response['created_at'] ?? 'ไม่ระบุวันที่';
        link = response['link'] ?? '';
        isLoading = false; // หยุดสถานะ Loading
      });
    } else {
      print('Failed to fetch user data.');
      setState(() {
        userId = '';
        username = 'Error';
        email = 'Error';
        fullName = 'Error';
        bio = 'Error';
        createdAt = 'Error';
        link = 'Error';
        isLoading = false;
      });
    }
  }


  void _logout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // เคลียร์ข้อมูลการเข้าสู่ระบบ
    authProvider.logout();

    // เปลี่ยนหน้าไปที่ LoginScreen และล้าง Stack หน้าทั้งหมด
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }


  Future<void> _pickAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      print('Selected image path: ${image.path}');
      print('User ID: $userId');

      final response = await _userService.uploadProfilePicture(userId, image.path);

      if (!mounted) return; // ป้องกัน State Update ถ้า Widget ถูกทำลาย

      if (response != null) {
        setState(() {
          print('✅ Profile picture updated successfully');
        });
      } else {
        print('❌ Failed to upload profile picture');
      }
    } else {
      print('⚠ No image selected');
    }
  }

  void _showEditProfileBottomSheet(BuildContext context) {

    // TextEditingController สำหรับเก็บค่าที่ผู้ใช้แก้ไข
    final TextEditingController _fullNameController = TextEditingController(text: fullName);
    final TextEditingController _bioController = TextEditingController(text: bio);
    final TextEditingController _linkController = TextEditingController(text: link);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.95,
          maxChildSize: 0.95,
          minChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'ยกเลิก',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      Text(
                        'แก้ไขโปรไฟล์',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          // เมื่อกด "เสร็จ", ส่งข้อมูลที่แก้ไขไปยัง API
                          final response = await _userService.editProfile(
                            _fullNameController.text,
                            _bioController.text,
                            _linkController.text,context
                          );

                          if (response != null) {
                            setState(() {
                              fullName = _fullNameController.text;
                              bio = _bioController.text;
                              link = _linkController.text;
                            });
                            Navigator.pop(context);  // ปิด bottom sheet
                          } else {
                            print("Error updating profile");
                          }
                        },
                        child: Text(
                          'เสร็จ',
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Profile Picture
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                      backgroundImage: NetworkImage(
                        '${authProvider.apiBaseUrl}/det/img/profile/$userId?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                      ),
                    ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: _pickAndUploadImage,
                          child: Text(
                            'เปลี่ยนรูปโปรไฟล์',
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Input Fields
                  _buildEditableField(
                    label: 'ชื่อ',
                    controller: _fullNameController,
                  ),
                  _buildEditableField(
                    label: 'คำอธิบายตัวเอง',
                    controller: _bioController,
                  ),
                  _buildEditableField(
                    label: 'ลิงก์',
                    controller: _linkController,
                  ),
                  SizedBox(height: 20),

                  // Private Profile Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'โปรไฟล์ส่วนตัว',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Switch(
                        value: false,
                        onChanged: (bool value) {
                          // Handle toggle
                        },
                        activeColor: Colors.blue,
                        inactiveThumbColor: Colors.grey,
                      ),
                    ],
                  ),

                  // Description
                  Text(
                    'หากคุณเปลี่ยนไปเป็นแบบส่วนตัว จะมีเฉพาะผู้ติดตามเท่านั้นที่สามารถดูเธรดของคุณได้',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEditableField({required String label, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          TextField(
            controller: controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);


    // รอให้ userId ถูกโหลดจาก AuthProvider
    if (authProvider.userId == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ใช้ userId จาก AuthProvider
    userId = authProvider.userId ?? '';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
            title: Text(
              fullName,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700], // เปลี่ยนสีข้อความเป็นสีขาว
              ),
            ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer(); // เปิด endDrawer
                },
              ),
            ),
          ],
        ),
        endDrawer: Drawer(
          shape: RoundedRectangleBorder(),
          backgroundColor: Colors.black,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        '${authProvider.apiBaseUrl}/det/img/profile/$userId?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      username ,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bookmark, color: Colors.white),
                title: const Text('บันทึกแล้ว', style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Handle "บันทึกแล้ว" action
                },
              ),
              ListTile(
                leading: const Icon(Icons.thumb_up, color: Colors.white),
                title: const Text('การกดถูกใจของฉัน', style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Handle "การกดถูกใจของฉัน" action
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.white),
                title: const Text('ความเป็นส่วนตัว', style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Handle "ความเป็นส่วนตัว" action
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
        body: Container(
          color: Colors.black,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Section
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                    backgroundImage: NetworkImage(
                      '${authProvider.apiBaseUrl}/det/img/profile/$userId?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                    ),
                      ),

                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username ,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              bio ,
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'ผู้ติดตาม 135 คน '+ link,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showEditProfileBottomSheet(context),
                          child: Text(
                            'แก้ไขโปรไฟล์',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: Text(
                            'แชร์โปรไฟล์',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey[800]),

                // Tab Bar
                const TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'เธรด'),
                    Tab(text: 'การตอบกลับ'),
                    Tab(text: 'รีโพสต์'),
                  ],
                ),

                // เนื้อหาในแท็บ
                Container(
                  height: 500,
                  child: TabBarView(
                    children: [
                      _buildThreadTab(),
                      _buildReplyTab(),
                      _buildRepostTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchUserPosts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String apiUrl = '${authProvider.apiBaseUrl}/det/post/getAllPosts?user_id=$userId';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // กรองโพสต์เฉพาะของผู้ใช้
        return data
            .where((post) => post['user_id'].toString() == userId)
            .toList()
            .cast<Map<String, dynamic>>();
      } else {
        print('Failed to load user posts: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching user posts: $e');
      return [];
    }
  }


  Widget _buildThreadTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchUserPosts(), // ดึงโพสต์ของผู้ใช้
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'เกิดข้อผิดพลาดในการโหลดโพสต์',
              style: TextStyle(color: Colors.grey),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'ยังไม่มีโพสต์',
              style: TextStyle(color: Colors.grey),
            ),
          );
        } else {
          final userPosts = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.only(top: 0), // เพิ่ม Padding ด้านบน 10
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10), // เพิ่ม Padding ใน ListView ด้วย
              itemCount: userPosts.length,
              itemBuilder: (context, index) {
                final post = userPosts[index];
                return PostWidget(post: post); // ใช้ PostWidget แสดงโพสต์
              },
            ),
          );
        }
      },
    );
  }


  // ตอบกลับแท็บ
  Widget _buildReplyTab() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'ยังไม่มีการตอบกลับ',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  // รีโพสต์แท็บ
  Widget _buildRepostTab() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'ยังไม่มีรีโพสต์',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
