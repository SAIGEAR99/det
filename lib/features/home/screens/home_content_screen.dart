import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:det/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      print('User ID not found.');
      return;
    }

    final String apiUrl =
        '${dotenv.env['API_BASE_URL']}/det/post/getAllPosts?user_id=$userId';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          posts = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        print('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostWidget(post: post);
      },
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

  @override
  void initState() {
    super.initState();
    isLiked = widget.post['isLiked'] ?? false; // Get initial like state from API
    likeCount = widget.post['likeCount'] ?? 0; // Get initial like count from API
  }

  Future<void> _toggleLike(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเข้าสู่ระบบเพื่อกดถูกใจ')),
      );
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
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User and timestamp section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                CircleAvatar(
            backgroundImage: NetworkImage(
              '${dotenv.env['API_BASE_URL']}/det/img/profile/${widget.post['user_id']}?timestamp=${DateTime.now().millisecondsSinceEpoch}',
            ),
                  radius: 20,
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
              padding: const EdgeInsets.symmetric(horizontal: 65.0, vertical: 8.0),
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
                  controller: PageController(viewportFraction: 0.72),
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
            padding: const EdgeInsets.symmetric(horizontal: 65.0, vertical: 8.0),
            child: Row(
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
                Text('$likeCount', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                SizedBox(width: 4),
                Text('0', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 16),
                Icon(Icons.autorenew, color: Colors.grey, size: 20),
                SizedBox(width: 4),
                Text('0', style: TextStyle(color: Colors.grey)),
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


