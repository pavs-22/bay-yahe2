import 'package:bay_yahe_app/screens/profile/Wallet/Wallet.dart';
import 'package:bay_yahe_app/screens/profile/profile_screen/account_screen.dart';
import 'package:bay_yahe_app/screens/profile/profile_screen/help_center/help_center.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'profile_menu.dart';
import 'profile_pic.dart';

class Body extends StatelessWidget {
  Body({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  //sign user out methods

  void signUserOut() {
    googleSignIn.signOut();
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          ProfilePic(),
          const SizedBox(height: 20),
          ProfileMenu(
            text: "My Account",
            icon: "assets/icons8-account-50.png",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
          ),
          ProfileMenu(
            text: "Wallet",
            icon: "assets/logo/mobile.png",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const Wallet()), // Use SettingScreen instead of SettingsList
              );
            },
          ),
          ProfileMenu(
            text: "Help Center",
            icon: "assets/icons8-help-50.png",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const HelpCenterPage()), // Use SettingScreen instead of SettingsList
              );
            },
          ),
          ProfileMenu(
            text: "Log Out",
            icon: "assets/icons8-log-out-30.png",
            press: () {
              signUserOut();
            },
          ),
        ],
      ),
    );
  }
}
