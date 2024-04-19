import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePic extends StatelessWidget {
  ProfilePic({super.key});

  final User user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference clientUsers =
      FirebaseFirestore.instance.collection('client_user');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: clientUsers.where('email', isEqualTo: user.email).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoDataState();
        } else {
          var data = snapshot.data!.docs[0].data() as Map<String, dynamic>;
          return _buildProfileWidget(data);
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return _buildContainer(
        child: const Center(child: CircularProgressIndicator()));
  }

  Widget _buildErrorState(String error) {
    return _buildContainer(child: Center(child: Text('Error: $error')));
  }

  Widget _buildNoDataState() {
    return _buildContainer(child: const Center(child: Text('No data found.')));
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 118, 230, 168),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 25,
      ),
      child: child,
    );
  }

  Widget _buildProfileWidget(Map<String, dynamic> data) {
    String? profileImageUrl = data['profile_image'];
    String fullName =
        (data['firstname'] ?? '') + ' ' + (data['lastname'] ?? '');
    String userEmail = data['email'] ?? '';

    return _buildContainer(
      child: Row(
        children: [
          if (profileImageUrl != null)
            ClipOval(
              child: Image.network(
                profileImageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            )
          else
            const CircleAvatar(
              radius: 50.0,
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.person,
                size: 50.0,
                color: Colors.white,
              ),
            ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                userEmail,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
