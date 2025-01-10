import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class HomeContentScreen extends StatelessWidget {
  final List<Map<String, dynamic>> posts = [
    {
      'username': 'justina.xiecl0624',
      'time': '4 ชม.',
      'content': 'โพสต์ข้อความพร้อมรูปภาพที่เลื่อนได้',
      'images': ['assets/post_1.jpg', 'assets/post_2.jpg'],
      'likes': 246,
      'comments': 3,
      'shares': 3,
    },
    {
      'username': 'comi1.4',
      'time': '6 ชม.',
      'content': 'อะไรอะ 😟😟 SOS SOS',
      'audio': 'assets/audio_3.mp3', // ไฟล์เสียง
      'likes': 63,
      'comments': 8,
      'shares': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ส่วนแสดง User และเวลาที่โพสต์
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/profile.jpg'),
                      radius: 20,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['username'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          post['time'],
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.more_vert, color: Colors.white),
                  ],
                ),
              ),
              // ข้อความโพสต์
              if (post.containsKey('content'))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 65.0, vertical: 8.0),
                  child: Text(
                    post['content'],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              // เล่นไฟล์เสียงพร้อม waveform
              if (post.containsKey('audio'))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 65.0, vertical: 8.0),
                  child: AudioPlayerWidget(audioPath: post['audio']),
                ),
              // รูปภาพโพสต์
              if (post.containsKey('images'))
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width - 128,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.72),
                      physics: ClampingScrollPhysics(),
                      itemCount: post['images'].length,
                      itemBuilder: (context, imageIndex) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              post['images'][imageIndex],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              // แสดงจำนวนถูกใจ คอมเมนต์ แชร์
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 65.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                    SizedBox(width: 4),
                    Text('${post['likes']}', style: TextStyle(color: Colors.grey)),
                    SizedBox(width: 16),
                    Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                    SizedBox(width: 4),
                    Text('${post['comments']}', style: TextStyle(color: Colors.grey)),
                    SizedBox(width: 16),
                    Icon(Icons.share, color: Colors.grey, size: 20),
                    SizedBox(width: 4),
                    Text('${post['shares']}', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Divider(color: Colors.grey[800]),
            ],
          ),
        );
      },
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;

  const AudioPlayerWidget({required this.audioPath});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late PlayerController _playerController;

  @override
  void initState() {
    super.initState();

    // Initialize PlayerController
    _playerController = PlayerController();

    // Prepare the audio file and waveform
    _playerController.preparePlayer(
      path: widget.audioPath,
      shouldExtractWaveform: true, // Generates the waveform
    );
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.play_arrow, color: Colors.white),
          onPressed: () {
            _playerController.startPlayer();
          },
        ),
        IconButton(
          icon: Icon(Icons.pause, color: Colors.white),
          onPressed: () {
            _playerController.pausePlayer();
          },
        ),
        Expanded(
          child: AudioFileWaveforms(
            playerController: _playerController,
            size: Size(MediaQuery.of(context).size.width * 0.7, 50),
            waveformType: WaveformType.long,
            playerWaveStyle: const PlayerWaveStyle(
              fixedWaveColor: Colors.grey,
              liveWaveColor: Colors.blue,
              waveCap: StrokeCap.round,
            ),
          ),
        ),
      ],
    );
  }
}
