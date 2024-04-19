import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedReason = 'Sexual Abuse'; // Example initialization

  final TextEditingController _referenceIdController = TextEditingController();
  final TextEditingController _complainController = TextEditingController();

  final List<String> _reasons = [
    'Sexual Abuse',
    'Violence',
    'Harassment',
    'Over-Pricing'
  ];

  Future<void> _sendDataToFirebase() async {
    try {
      // Access the Firebase Firestore instance
      final firestore = FirebaseFirestore.instance;

      // Create a new document in the "report" collection
      await firestore.collection('report').add({
        'referenceId': _referenceIdController.text,
        'complain': _complainController.text,
        'reason': _selectedReason,
      });

      // Reset controllers after sending data
      _referenceIdController.clear();
      _complainController.clear();

      // Optionally, show a success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Report sent successfully'),
        duration: Duration(seconds: 2),
      ));
    } catch (error) {
      // Handle errors here
      print('Error sending report: $error');
      // Optionally, show an error message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to send report'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _referenceIdController,
                      decoration: const InputDecoration(
                        labelText: 'Reference ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _complainController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Complain',
                        hintText: 'Enter your complain...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Reason'),
                      value: _selectedReason,
                      items: _reasons.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedReason = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      onPressed: _sendDataToFirebase, // Call function here
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _referenceIdController.dispose();
    _complainController.dispose();
    super.dispose();
  }
}
