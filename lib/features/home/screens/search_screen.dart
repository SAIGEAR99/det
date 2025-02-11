import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:det/features/home/widgets/user_profile_screen.dart';
import 'package:det/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String apiUrl = '${authProvider.apiBaseUrl}/det/search?query=$query&user_id=${authProvider.userId}';

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          searchResults = data.map((item) {
            return {
              ...Map<String, dynamic>.from(item),
              'is_following': item['is_following'] ?? false,
            };
          }).toList();
        });

        print("Search results: $searchResults"); // Debug log
      } else {
        print('Error fetching search results: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching users: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  Future<void> _toggleFollow(int targetUserId, bool isFollowing) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String apiUrl = '${authProvider.apiBaseUrl}/det/follow/toggle';

    final requestPayload = jsonEncode({
      'follower_id': authProvider.userId,
      'following_id': targetUserId,
    });

    print('🔍 Sending request: $requestPayload');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: requestPayload,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          for (var user in searchResults) {
            if (user['user_id'] == targetUserId) {
              user['is_following'] = responseData['is_following']; // ✅ อัปเดตค่าตาม API
            }
          }
        });

        print('Toggle follow success: ${responseData['message']}');
      } else {
        print('Failed to toggle follow: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error toggling follow: $e');
    }
  }


  void _navigateToUserProfile(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(user: user),
      ),
    );
  }

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
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.93,
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchUsers,
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'ค้นหา',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final user = searchResults[index];
                final bool isFollowing = user['is_following'] ?? false;

                return ListTile(
                  onTap: () => _navigateToUserProfile(user),
                  leading: CircleAvatar(
                    backgroundImage: user['profile_img'] != null
                        ? NetworkImage('${user['profile_img']}?timestamp=${DateTime.now().millisecondsSinceEpoch}')
                        : AssetImage('assets/profile_placeholder.png') as ImageProvider,
                    radius: 25,
                  ),
                  title: Text(
                    user['username'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${user['bio']}\nผู้ติดตาม ${user['followers']} คน',
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: SizedBox(
                    width: 110,
                    child: OutlinedButton(
                      onPressed: () {
                        _toggleFollow(user['user_id'], user['is_following'] ?? false);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white),
                        backgroundColor: Colors.white, // ✅ ปุ่มเป็นสีขาวทั้งคู่
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        (user['is_following'] ?? false) ? 'กำลังติดตาม' : 'ติดตาม',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),





                  contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 18),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
