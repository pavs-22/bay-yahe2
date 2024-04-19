import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bay_yahe_app/Chat/chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatHomepage extends StatefulWidget {
  const ChatHomepage({Key? key});

  @override
  State<ChatHomepage> createState() => _ChatHomepageState();
}

class _ChatHomepageState extends State<ChatHomepage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    String currentUid = _auth.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('senderId', isEqualTo: currentUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Previous Chat.'));
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

    if (data != null &&
        _auth.currentUser != null &&
        data['receiverId'] != null &&
        _auth.currentUser!.uid != (data['receiverId'] as String)) {
      print("Fetching driver user for ${data['receiverId']}");

      return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('driver_user')
            .where('uid', isEqualTo: data['receiverId'])
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListTile(
              title: Text('Loading...'),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            print("Driver data not found");
            return ListTile(
              title: Text('Driver not found'),
            );
          }

          var driverUsers =
              snapshot.data!.docs.map((doc) => doc.data()).toList();

          if (driverUsers.isEmpty) {
            print("Driver list is empty");
            return ListTile(
              title: Text('Driver not found'),
            );
          }

          // Assuming there's only one matching driver user, you can use the first one
          var driverUser = driverUsers.first;

          if (driverUser is Map<String, dynamic>) {
            print(
                "Driver user found: ${driverUser['firstname']} ${driverUser['lastname']}");

            return ListTile(
              title: Text(
                '${driverUser['firstname']} ${driverUser['lastname']}',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      driverUserID: data['receiverId'] as String,
                    ),
                  ),
                );
              },
            );
          } else {
            print("Invalid data format for driver user");
            return ListTile(
              title: Text('Invalid data format for driver user'),
            );
          }
        },
      );
    } else {
      print("Invalid data or currentUser is null");
      return Container();
    }
  }
}
