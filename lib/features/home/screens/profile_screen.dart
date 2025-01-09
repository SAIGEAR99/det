import 'package:flutter/material.dart';
import 'package:det/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  void _logout(BuildContext context) async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'เกียร์ที่แปลว่าเก (⊙_⊙)',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
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
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/profile.jpg'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'gamucosu',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
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
                // Section โปรไฟล์
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
                              'gamucosu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '名: Gear | ギヤ | เกียร์',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.people_alt, color: Colors.white, size: 16),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    'ผู้ติดตาม 135 คน · tiktok.com/@gamucosu',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis, // ตัดข้อความเกินจอ
                                    maxLines: 1, // จำกัด 1 บรรทัด
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ปุ่มแก้ไขโปรไฟล์ และแชร์โปรไฟล์
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
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
