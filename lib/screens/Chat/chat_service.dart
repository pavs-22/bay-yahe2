import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'message.dart';

class ChatService extends ChangeNotifier {
// get instance of auth and firestore

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
// SEND MESSAGE

  Future<void> sendMessage(String driverId, String message) async {
// get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();
// create a new message

    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      driverId: driverId,
      timestamp: timestamp,
      message: message,
    );
// construct chat room id from current user id and receiver id (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, driverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // add new message to database

    await fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

// GET MESSAGES

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");
    return fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('Timestamp', descending: false)
        .snapshots();
  }
}
