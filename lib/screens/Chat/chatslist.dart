import 'package:flutter/material.dart';
import 'chatscreen.dart';

class ChatTab extends StatelessWidget {
  final List<String> recentChats = [
    'John Doe',
    'Jane Doe',
    'Alice',
    'Bob',
    // Add more recent chats as needed
  ];

  ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Contacts'),
        backgroundColor: const Color(0xFF33c072),
      ),
      body: Expanded(
        child: ListView.builder(
          itemCount: recentChats.length,
          itemBuilder: (context, index) {
            final chatName = recentChats[index];
            return ListTile(
              leading: const CircleAvatar(
                // Add your circle account icon or profile image here
                child: Icon(Icons.account_circle),
              ),
              title: Row(
                children: [
                  Text(chatName),
                  const SizedBox(width: 8),
                  // Add online/offline indicator based on your logic
                  // For simplicity, it's not implemented here
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(chatName: chatName),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
