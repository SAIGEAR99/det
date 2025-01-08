import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> users = [
    {'name': 'akatsukibxx', 'bio': 'บออนอ', 'followers': '56'},
    {'name': 'ijae.__.young', 'bio': 'Луму', 'followers': '11'},
    {'name': 'pang_gzz', 'bio': 'Pang Jiko', 'followers': '137'},
    {'name': 'rule34sigmahacker', 'bio': 'M_NAX', 'followers': '60'},
    {'name': 'kagayaku.hoshi.th', 'bio': 'Kagayaku Hoshi', 'followers': '37'},
    {'name': 'ultrakungg', 'bio': '⸸⸸ NONGTA • . ⸸⸸', 'followers': '26'},
    {'name': 'khing_ne', 'bio': 'KhingNe.', 'followers': '69'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'ค้นหา',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,  // ทำให้ "ค้นหา" เป็นสีขาว
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'ค้นหา',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  dense: true,  // ลดความสูงของ ListTile
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/profile.jpg'),
                    radius: 20,  // ลดขนาดภาพโปรไฟล์เล็กน้อย
                  ),
                  title: Text(
                    user['name']!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${user['bio']}\nผู้ติดตาม ${user['followers']} คน',
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'ติดตาม',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),  // ลด vertical padding
                );
                ;
              },
            ),
          ),
        ],
      ),
    );
  }
}
