import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:det/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:det/features/home/widgets/user_profile_screen.dart';

class HomeContentScreen extends StatefulWidget {
  @override
  _HomeContentScreenState createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // เรียกใช้ AuthProvider เพื่อโหลดข้อมูล User
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.loadUser().then((_) {
      });
    });
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      isLoading = true; // เริ่มโหลดข้อมูล
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    final String apiUrl = userId != null
        ? '${dotenv.env['API_BASE_URL']}/det/post/getAllPosts?user_id=$userId'
        : '${dotenv.env['API_BASE_URL']}/det/post/getAllPosts';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          posts = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      setState(() {
        isLoading = false; // หยุดโหลดข้อมูล
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchPosts, // ใช้ฟังก์ชันรีเฟรช
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostWidget(post: post);
        },
      ),
    );
  }
}

class PostWidget extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostWidget({required this.post});

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late bool isLiked;
  late int likeCount;
  late TextEditingController _commentController;
  late int commentCount;
  List<Map<String, dynamic>> comments = [];


  @override
  void initState() {
    super.initState();
    _fetchComments(widget.post['post_id']);
    _commentController = TextEditingController(); // สร้าง TextEditingController
    isLiked = widget.post['isLiked'] ?? false;
    likeCount = widget.post['likeCount'] ?? 0;
    commentCount = widget.post['commentCount'] ?? 0;

  }

  @override
  void dispose() {
    _commentController.dispose(); // ล้าง TextEditingController
    super.dispose();
  }



  void _showLoginDialog(BuildContext context) {
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

  Future<void> _addComment(String postId, String content) async {
    if (content.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      _showLoginDialog(context);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/det/comment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'post_id': postId,
          'user_id': userId,
          'content': content,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _commentController.clear();

        // โหลดคอมเมนต์ใหม่
        final newComments = await _fetchComments(postId);

        setState(() {
          comments = newComments; // อัปเดต State ทันที
          commentCount = comments.length; // อัปเดตจำนวนคอมเมนต์
        });

        print('Comment added successfully');
      } else {
        print('Failed to add comment: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถเพิ่มคอมเมนต์ได้')),
        );
      }
    } catch (e) {
      print('Error adding comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการเพิ่มคอมเมนต์')),
      );
    }
  }


  Future<List<Map<String, dynamic>>> _fetchComments(String postId) async {
    final url = '${dotenv.env['API_BASE_URL']}/det/comment/fetch?post_id=$postId';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> fetchedComments = List<Map<String, dynamic>>.from(jsonDecode(response.body));

        setState(() {
          comments = fetchedComments;
          commentCount = comments.length; // อัปเดตจำนวนคอมเมนต์
        });

        return fetchedComments;
      } else {
        print('Failed to fetch comments: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }




  void _showCommentsBottomSheet(BuildContext context) {
    _fetchComments(widget.post['post_id']); // โหลดคอมเมนต์ก่อนแสดง
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7, // 60% ของหน้าจอ
          maxChildSize: 0.95,    // เลื่อนขึ้นสูงสุด 90% ของหน้าจอ
          minChildSize: 0.7,    // ต่ำสุด 60%
          expand: false,
          builder: (context, scrollController) {
            return _buildCommentsSection(scrollController);
          },
        );
      },
    );
  }

  Widget _buildCommentsSection(ScrollController scrollController) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ความคิดเห็น',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(color: Colors.grey[700]),

          // แสดงรายการคอมเมนต์
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      '${dotenv.env['API_BASE_URL']}/det/img/profile/${comment['user_id'] ?? 'default'}',
                    ),
                  ),
                  title: Text(
                    comment['username'] ?? 'ไม่ทราบชื่อ',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    comment['content'] ?? '',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
          ),

          // ช่องป้อนข้อความคอมเมนต์
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'เพิ่มความคิดเห็น...',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  _addComment(widget.post['post_id'].toString(), _commentController.text);
                },
                child: Icon(Icons.send, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      _showLoginDialog(context); // ถ้ายังไม่ได้ล็อกอิน ให้เด้งแจ้งเตือน
      return;
    }

    final String apiUrl = '${dotenv.env['API_BASE_URL']}/det/post/like';
    final isLikeAction = !isLiked; // Determine the new like state

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          'user_id': userId,
          'post_id': widget.post['post_id'],
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          isLiked = responseData['isLiked'];
          likeCount = responseData['likeCount'];
        });
      } else {
        print('Failed to update like: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถอัพเดตการถูกใจได้')),
        );
      }
    } catch (e) {
      print('Error updating like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการอัพเดตการถูกใจ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwner = authProvider.userId == widget.post['user_id'].toString();

    return Container(
      margin: EdgeInsets.only(
        left: 0,
        right: 0,
      ),

      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User and timestamp section
          // User and timestamp section
          Padding(
            padding: const EdgeInsets.only(
              left: 26,
              right: 5,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);

                    // ถ้าล็อกอินแล้วให้ไปที่หน้าโปรไฟล์
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          user: {
                            'user_id': widget.post['user_id'],
                            'username': widget.post['username'],
                            'profile_img': '${dotenv.env['API_BASE_URL']}/det/img/profile/${widget.post['user_id']}?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                            'bio': widget.post['bio'] ?? '',
                            'followers': widget.post['followers'] ?? 0,
                          },
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      '${dotenv.env['API_BASE_URL']}/det/img/profile/${widget.post['user_id']}?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                    ),
                    radius: 20,
                  ),
                ),

                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post['username'],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTime(widget.post['created_at']),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deletePost(context, widget.post['post_id']);
                    } else if (value == 'report') {
                      _reportPost(context, widget.post['post_id']);
                    }
                  },
                  itemBuilder: (context) => [
                    if (isOwner)
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('ลบโพสต์'),
                      ),
                    PopupMenuItem(
                      value: 'report',
                      child: Text('รายงาน'),
                    ),
                  ],
                  icon: Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
            ),
          ),

          // Post content
          if (widget.post['content'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 76.0, vertical: 8.0),
              child: Text(
                widget.post['content'],
                style: TextStyle(color: Colors.white),
              ),
            ),
          // Post images
          if (widget.post['images'] != null && widget.post['images'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: SizedBox(
                height: MediaQuery.of(context).size.width - 128,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.65),
                  physics: ClampingScrollPhysics(),
                  itemCount: widget.post['images'].length,
                  itemBuilder: (context, imageIndex) {
                    final imageUrl = widget.post['images'][imageIndex]['url'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: Center(
                                child: Icon(Icons.broken_image, color: Colors.white),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          // Post likes, comments, shares
          Padding(
            padding: const EdgeInsets.only(left: 76.0, right: 76.0, top: 16.0 , bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
            GestureDetector(
            onTap: () => _toggleLike(context),
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey,
            size: 20,
          ),
            ),
                    SizedBox(width: 4),
                    Text(
                      '$likeCount',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(width: 16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showCommentsBottomSheet(context); // เรียกฟังก์ชันเปิดช่องคอมเมนต์
                      },
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showCommentsBottomSheet(context); // เปิด Bottom Sheet แสดงความคิดเห็น
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '$commentCount', // ใช้ commentCount แทนค่า 0
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),


                    ),

                  ],
                ),
                SizedBox(width: 16),
                Row(
                  children: [
                    Icon(
                      Icons.autorenew,
                      color: Colors.grey,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '0',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),


          Divider(color: Colors.grey[800]),
        ],
      ),
    );
  }

  void _deletePost(BuildContext context, String postId) async {
    final String apiUrl = '${dotenv.env['API_BASE_URL']}/det/post/delete';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({'post_id': postId}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('โพสต์ถูกลบเรียบร้อยแล้ว')),
        );
        final homeContentScreenState =
        context.findAncestorStateOfType<_HomeContentScreenState>();
        homeContentScreenState?._fetchPosts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบโพสต์ไม่สำเร็จ')),
        );
      }
    } catch (e) {
      print('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการลบโพสต์')),
      );
    }
  }

  void _reportPost(BuildContext context, String postId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('รายงานโพสต์สำเร็จ')),
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


