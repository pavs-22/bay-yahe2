import 'package:bay_yahe_app/screens/Home/Ads/ads_box.dart';
import 'package:bay_yahe_app/screens/Home/Box/HomeIcon.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, Key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/icons/logo-icon.png',
                width: 50,
                height: 50,
              ),
            ),
            const Text('Welcome!'),
          ],
        ),
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeIcon(),
            SizedBox(height: 10),
            Divider(
              thickness: 2,
              indent: 3,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
              child: Text(
                'For More Inquiry',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
              ),
            ),
            ImageScroll(),
            Divider(
              thickness: 2,
              indent: 3,
            ),
          ],
        ),
      ),
    );
  }
}
