import 'package:flutter/material.dart';

class HomeContentScreen extends StatelessWidget {
  final List<Map<String, dynamic>> posts = List.generate(10, (index) {
    return {
      'username': 'user$index',
      'time': '${index + 1} ชม.',
      'caption': 'โพสต์ที่ $index - นี่คือเนื้อหาตัวอย่าง',
      'image': 'assets/post_${index % 3 + 1}.jpg',
      'likes': (index + 1) * 100,
      'comments': (index + 1) * 10,
      'shares': (index + 1) * 5,
    };
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Container(
          margin: EdgeInsets.only(bottom: 0.5),
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/profile.jpg'),
                ),
                title: Text(
                  post['username'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  post['time'],
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              ),
              Image.asset(post['image'], fit: BoxFit.cover, width: double.infinity, height: 300),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite_border, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Icon(Icons.share, color: Colors.white, size: 28),
                      ],
                    ),
                    Icon(Icons.bookmark_border, color: Colors.white, size: 28),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${post['likes']} ถูกใจ',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${post['username']} ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: post['caption'],
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
