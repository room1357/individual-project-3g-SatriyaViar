import 'package:flutter/material.dart';

// Contoh implementasi messageScreen
class MessageScreen extends StatelessWidget {
  const MessageScreen ({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.message, size: 40),
            ),
            SizedBox(height: 10),
            Text('Nama Pengguna', style: TextStyle(fontSize: 24)),
            Text('user@email.com', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}