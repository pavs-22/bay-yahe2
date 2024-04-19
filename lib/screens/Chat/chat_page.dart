import 'package:bay_yahe_app/components/textfield.dart';
import 'package:bay_yahe_app/screens/Chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key? key,
    required senderUserID,
    required receiverUserID,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser!;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('driver_user');

  late String driverId;
  late String driveremail;

  @override
  void initState() {
    super.initState();

    // Initialize driveremail with a default value
    driveremail = "Loading...";
    driverId = "Loading...";

    // Retrieve driver data when the page is initialized
    getUserData().then((userData) {
      setState(() {
        driverId = userData['driverId'];
        driveremail = userData['driveremail'];
      });
    });
  }

  Future<Map<String, dynamic>> getUserData() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await users
        .where('email', isEqualTo: user.email)
        .get() as QuerySnapshot<Map<String, dynamic>>;

    if (querySnapshot.docs.isNotEmpty) {
      Map<String, dynamic> userData = querySnapshot.docs[0].data();
      String driverId = userData['driverId'];
      String driveremail = userData['driveremail'];

      return {'driverId': driverId, 'driveremail': driveremail};
    } else {
      return {}; // Return an empty map if no matching user is found
    }
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(driverId, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $driveremail'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // build message list

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(driverId, firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading....');
        }

        return ListView(
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = (data['senderId'] == firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment:
                (data['senderId'] == firebaseAuth.currentUser!.uid)
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            mainAxisAlignment:
                (data['senderId'] == firebaseAuth.currentUser!.uid)
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              Text(data['senderEmail']),
              const SizedBox(height: 5),
              Text(data['message']),
            ],
          ),
        ));
  }

  // build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: 'Enter Message',
              obscureText: false,
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.arrow_upward,
              size: 40,
            ),
          )
        ],
      ),
    );
  }
}
