import 'package:bay_yahe_app/Chat/chat_homepage.dart';
import 'package:bay_yahe_app/screens/History/historyscreen.dart';
import 'package:bay_yahe_app/screens/Activities/activity_screen.dart';
import 'package:bay_yahe_app/screens/home/homescreen.dart';
import 'package:bay_yahe_app/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const HistoryTab(),
    const ActivityScreen(),
    ChatHomepage(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Ensure _currentIndex is within the valid range
    if (_currentIndex < 0 || _currentIndex >= _tabs.length) {
      _currentIndex = 0; // Set a default value if it's out of range
    }

    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          // Ensure the selected index is within the valid range
          if (index >= 0 && index < _tabs.length) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: [
          BottomNavyBarItem(
            icon: const Icon(Icons.home),
            title: const Text('Home'),
            activeColor: Colors.blue,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.history),
            title: const Text('History'),
            activeColor: Colors.blue,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.notifications),
            title: const Text('Activities'),
            activeColor: Colors.blue,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.chat),
            title: const Text('Chat'),
            activeColor: Colors.blue,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.person),
            title: const Text('Profile'),
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
