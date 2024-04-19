import 'package:bay_yahe_app/screens/profile/report_screen.dart';
import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Help Center'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color(0xFF33c072),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(
              -0.3,
              -0.3,
            ),
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.green],
          ),
        ),
        child: Center(
          child: ListView(
            children: <Widget>[
              SizedBox(height: 30.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportScreen(),
                      ),
                    );
                  },
                  child: Column(
                    children: const [
                      SizedBox(height: 8.0),
                      Text(
                        'Report Something',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Did you encounter some issue? \nLet us know.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
              // Add more HelpTopicCard widgets for different topics.
            ],
          ),
        ),
      ),
    );
  }
}
