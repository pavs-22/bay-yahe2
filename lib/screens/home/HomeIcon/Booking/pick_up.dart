import 'package:bay_yahe_app/screens/home/HomeIcon/Booking/Destination.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';

class PickUpLocationScreen extends StatefulWidget {
  @override
  _PickUpLocationScreenState createState() => _PickUpLocationScreenState();
}

class _PickUpLocationScreenState extends State<PickUpLocationScreen> {
  late GoogleMapController mapController;
  final LatLng defaultLocation = LatLng(14.159364637067865,
      121.27490814775229); // Default location (Baranggay Puypuy Bay, Laguna)

  TextEditingController landmarkController = TextEditingController();
  TextEditingController contactPersonController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();

  Set<Marker> markers = {};
  bool incompleteInfo = false;
  bool invalidContactNumber = false;

  void _navigateToConfirmationScreen() {
    final LatLng pickupselectedLocation =
        markers.isNotEmpty ? markers.first.position : defaultLocation;
    final String pickuplandmark = landmarkController.text;
    final String contactPerson = contactPersonController.text;
    final String contactNumber = contactNumberController.text;

    if (pickupselectedLocation == defaultLocation ||
        pickuplandmark.isEmpty ||
        contactPerson.isEmpty ||
        contactNumber.isEmpty) {
      // Handle errors, show a message, or prevent navigation
      setState(() {
        incompleteInfo = true;
        invalidContactNumber = false; // Reset invalid contact number message
      });
      return;
    }

    if (contactNumber.length != 11) {
      // Handle the case where the phone number is not exactly 11 digits
      setState(() {
        invalidContactNumber = true;
        incompleteInfo = false; // Reset incomplete information message
      });
      return;
    }

    // Use the Navigator to push a new screen onto the stack
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DestinationLocationScreen(
          pickupselectedLocation: pickupselectedLocation,
          pickuplandmark: pickuplandmark,
          contactPerson: contactPerson,
          contactNumber: contactNumber,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onMapTap(LatLng location) {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId('selected_location'),
          position: location,
          infoWindow: InfoWindow(title: 'Selected Location'),
        ),
      );
      incompleteInfo = false;
      invalidContactNumber = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick-Up'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: defaultLocation,
                        zoom: 14.0,
                      ),
                      onMapCreated: _onMapCreated,
                      onTap: _onMapTap,
                      markers: markers,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Landmark',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: landmarkController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Landmark',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Contact Person',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: contactPersonController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Contact Person',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Contact Number',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: contactNumberController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [LengthLimitingTextInputFormatter(11)],
                    decoration: const InputDecoration(
                      hintText: 'Enter Contact Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (invalidContactNumber)
                    Text(
                      'Please enter a valid 11-digit phone number.',
                      style: TextStyle(color: Colors.red),
                    ),
                  if (incompleteInfo)
                    Text(
                      'Please fill in all required fields and select a location.',
                      style: TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _navigateToConfirmationScreen,
                    child: const Text('Confirm Information'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
