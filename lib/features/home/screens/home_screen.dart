import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _onItemTapped(int index) {
    if (index == 2) {
      // If Add Post icon is tapped, show the bottom sheet
      _showAddPostBottomSheet();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showAddPostBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to expand fully
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20), // Rounded top corners
        ),
      ),
      builder: (BuildContext context) {
        // Request focus for the TextField when the bottom sheet opens
        Future.delayed(Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(_postFocusNode);
        });

        return DraggableScrollableSheet(
          initialChildSize: 0.95, // Starts just below full screen
          maxChildSize: 0.95, // Almost full screen
          minChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Cancel and Post options
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
                        'เธรดใหม่',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.more_vert, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 20),

                  // User Info Section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/profile.jpg'),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'gamucosu',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'มีอะไรมาเล่าสู่กันฟังไหม',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Input Field
                  TextField(
                    controller: _postController,
                    focusNode: _postFocusNode,
                    maxLines: 6,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'เพิ่มไปยังเธรด',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),

                  // Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.image, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Icon(Icons.camera_alt, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Icon(Icons.gif, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Icon(Icons.mic, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Icon(Icons.tag, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Icon(Icons.location_on, color: Colors.white, size: 28),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle post action
                          print('Post: ${_postController.text}');
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
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

  @override
  Widget build(BuildContext context) {
    // Set StatusBar to black
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black, // StatusBar color
      statusBarIconBrightness: Brightness.light, // White icons
      systemNavigationBarColor: Colors.black, // Bottom navigation bar color
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.black, // Background color for Scaffold
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '',
          ),
        ],
      ),
    );
  }
}
