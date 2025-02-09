import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:det/features/auth/providers/auth_provider.dart';
import 'package:det/services/post_service.dart';
import 'home_content_screen.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeContentScreen(),
    SearchScreen(),
    Container(), // Placeholder for Add Post (handled by bottom sheet)
    NotificationsScreen(),
    ProfileScreen(),
  ];

  final TextEditingController _postController = TextEditingController();
  final FocusNode _postFocusNode = FocusNode();
  final List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // เรียกใช้ AuthProvider เพื่อโหลดข้อมูล User
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.loadUser().then((_) {
      });
    });
  }

  void _onItemTapped(int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (index == 2 || index == 3 || index == 4) { // ตรวจสอบเฉพาะปุ่มโพสต์, แจ้งเตือน, โปรไฟล์
      if (userId == null) {
        _showLoginAlert(context); // แสดงข้อความแจ้งเตือนให้เข้าสู่ระบบ
        return;
      }
    }

    if (index == 2) { // กดที่ปุ่มโพสต์
      _showAddPostBottomSheet();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // กดนอกป็อปอัปเพื่อปิด
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, // พื้นหลังโปร่งใสของ Dialog
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1C1C1C), // เปลี่ยนพื้นหลังเป็นสีเทาเข้ม
            borderRadius: BorderRadius.circular(20), // มุมโค้งมน
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline, // ไอคอนบัญชีผู้ใช้
                size: 48,
                color: Colors.white, // สีไอคอนเป็นสีขาว
              ),
              SizedBox(height: 16),
              Text(
                'ยังไม่ได้เข้าสู่ระบบ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // ตัวหนังสือสีขาว
                ),
              ),
              SizedBox(height: 8),
              Text(
                'กรุณาเข้าสู่ระบบเพื่อดำเนินการต่อ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400], // ตัวหนังสือสีเทาอ่อน
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // จัดให้อยู่กึ่งกลางและเว้นระยะห่างเท่ากัน
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white, // ตัวหนังสือสีขาว
                        side: BorderSide(color: Colors.white, width: 1.5), // ขอบสีขาว
                        padding: EdgeInsets.symmetric(vertical: 16), // เพิ่มความสูงของปุ่ม
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'ยกเลิก',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16), // ระยะห่างระหว่างปุ่ม
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/login'); // ไปหน้า Login
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // พื้นหลังสีขาว
                        foregroundColor: Colors.black, // ตัวหนังสือสีดำ
                        padding: EdgeInsets.symmetric(vertical: 16), // เพิ่มความสูงของปุ่ม
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddPostBottomSheet() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        Future.delayed(Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(_postFocusNode);
        });

        return DraggableScrollableSheet(
          initialChildSize: 0.95,
          maxChildSize: 0.95,
          minChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // ยกเลิก (ซ้าย)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'ยกเลิก',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      // ข้อความตรงกลาง
                      Text(
                        'โพสต์ใหม่',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // ไอคอน (ขวา)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Text Field
                  TextField(
                    controller: _postController,
                    focusNode: _postFocusNode,
                    maxLines: 6,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'เขียนข้อความของคุณ...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Images Preview
                  if (_selectedImages.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _selectedImages.map((image) {
                        return Stack(
                          children: [
                            Image.file(
                              image,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.remove(image);
                                  });
                                },
                                child: Icon(Icons.close, color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),

                  SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.image, color: Colors.white),
                        onPressed: _pickImages,
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          if (_postController.text.isNotEmpty ||
                              _selectedImages.isNotEmpty) {
                            await PostService(authProvider.apiBaseUrl).createPost(
                              userId: authProvider.userId ?? '',
                              text: _postController.text,
                              images: _selectedImages,
                            );
                            Navigator.pop(context);
                            await authProvider.reloadUser();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'โพสต์',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: ''),
        ],
      ),
    );
  }
}
