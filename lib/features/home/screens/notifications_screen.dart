import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'กิจกรรม',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            title: Row(
              children: [
                Text(
                  'gamucosu ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    'ชอบโพสต์ของคุณ',
                    overflow: TextOverflow.ellipsis,  // ตัดข้อความที่เกิน
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '4 ชั่วโมงที่แล้ว',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: SizedBox(
              width: 90,  // ปรับขนาดความกว้างให้เหมาะสม
              height: 35, // กำหนดความสูงของปุ่ม
              child: OutlinedButton(
                onPressed: () {},
                child: Text(
                  'ติดตามกลับ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,  // ลดขนาดตัวอักษร
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(70, 35),  // ขนาดขั้นต่ำ
                  padding: EdgeInsets.symmetric(horizontal: 10),  // ลด padding ด้านข้าง
                ),
              ),
            )
            ,
          );
        },
      ),
      backgroundColor: Colors.black,
    );
  }
}
