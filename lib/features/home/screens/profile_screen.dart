import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:det/features/auth/providers/auth_provider.dart';
import 'package:det/services/user.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  String userId = 'Loading...';
  String username = 'Loading...';
  String email = 'Loading...';
  String fullName = 'Loading...';
  String profilePicture = 'Loading...';
  String bio = 'Loading...';
  String createdAt = 'Loading...';
  String link = 'Loading...';

  @override
  void initState() {
    super.initState();
    Provider.of<AuthProvider>(context, listen: false).loadUser().then((_) {
      _getUserData();
    });
  }

  // ฟังก์ชันเรียกข้อมูลจาก API
  void _getUserData() async {
    final response = await _userService.getUserData(context);  // ส่ง context ไปให้ getUserData
    if (response != null) {
      setState(() {
        userId = response['user_id'].toString();  // ดึง user_id
        username = response['username'];  // ดึง username
        email = response['email'];  // ดึง email
        fullName = response['full_name'];  // ดึง full_name
        profilePicture = response['profile_picture'] ?? 'No picture';  // ดึง profile_picture
        bio = response['bio'] ?? 'No bio';  // ดึง bio
        createdAt = response['created_at'];
        link = response['link'];// ดึง created_at
      });
    } else {
      setState(() {
        userId = 'Error fetching data';
        username = 'Error fetching data';
        email = 'Error fetching data';
        fullName = 'Error fetching data';
        profilePicture = 'Error fetching data';
        bio = 'Error fetching data';
        createdAt = 'Error fetching data';
        link = 'Error fetching data';
      });
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _pickAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final response = await _userService.uploadProfilePicture(
        userId, // ส่ง user_id ที่เก็บไว้
        image.path,
      );

      if (response != null) {
        setState(() {
          profilePicture = response['profile_picture'];
        });
        print('Profile picture updated successfully');
      } else {
        print('Error uploading profile picture');
      }
    }
  }


  void _showEditProfileBottomSheet(BuildContext context) {
    // TextEditingController สำหรับเก็บค่าที่ผู้ใช้แก้ไข
    final TextEditingController _fullNameController = TextEditingController(text: fullName);
    final TextEditingController _bioController = TextEditingController(text: bio);
    final TextEditingController _linkController = TextEditingController(text: link);

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
                          backgroundImage: AssetImage('assets/profile.jpg'),
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            fullName ,
            style: TextStyle(fontSize: 18),
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
                      backgroundImage: AssetImage('assets/profile.jpg'),
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
                leading: const Icon(Icons.history , color: Colors.white),
                title: const Text('จัดเก็บ', style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Handle "จัดเก็บ" action
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
                        backgroundImage: AssetImage('assets/profile.jpg'),
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

  // เธรดแท็บ
  Widget _buildThreadTab() {
    return Container(
      color: Colors.black,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            title: Text(
              'gamucosu',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'มีอะไรมาเล่าสู่กันฟังไหม',
              style: TextStyle(color: Colors.white70),
            ),
          );
        },
      ),
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
