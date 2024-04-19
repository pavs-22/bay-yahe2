import 'package:bay_yahe_app/screens/home/HomeIcon/Booking/payment_information.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DestinationLocationScreen extends StatefulWidget {
  final LatLng pickupselectedLocation;
  final String pickuplandmark;
  final String contactPerson;
  final String contactNumber;

  const DestinationLocationScreen({
    Key? key,
    required this.pickupselectedLocation,
    required this.pickuplandmark,
    required this.contactPerson,
    required this.contactNumber,
  }) : super(key: key);

  @override
  _DestinationLocationScreenState createState() =>
      _DestinationLocationScreenState();
}

class _DestinationLocationScreenState extends State<DestinationLocationScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  final LatLng defaultLocation = LatLng(14.159364637067865, 121.27490814775229);
  String? selectedPaymentMethod;
  String? selectedRecipient;
  String? selectedFareType;
  String? selectedPassengerType;
  double? farePrice;

  TextEditingController destinationlandmarkController = TextEditingController();

  void _navigateToConfirmationScreen() {
    final LatLng destinationselectedLocation =
        markers.isNotEmpty ? markers.first.position : defaultLocation;
    final String destinationlandmark = destinationlandmarkController.text;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentInformationScreen(
          pickupselectedLocation: widget.pickupselectedLocation,
          destinationselectedLocation: destinationselectedLocation,
          pickuplandmark: widget.pickuplandmark,
          destinationlandmark: destinationlandmark,
          contactPerson: widget.contactPerson,
          contactNumber: widget.contactNumber,
          paymentMethod: selectedPaymentMethod ?? "DefaultPaymentMethod",
          passengerType: selectedRecipient ?? "DefaultPassengerType",
          fareType: selectedFareType ?? "DefaultFareType",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destination Location'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
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
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                      },
                      onTap: (LatLng location) {
                        setState(() {
                          markers = {
                            Marker(markerId: MarkerId('1'), position: location)
                          };
                        });
                      },
                      markers: markers,
                    ),
                  ),
                  const SizedBox(height: 60),
                  const Text(
                    'Landmark',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: destinationlandmarkController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Landmark',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select'),
                    value: selectedPaymentMethod,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPaymentMethod = newValue;
                      });
                    },
                    items: ['Cash', 'E-Cash'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Fare Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select'),
                    value: selectedFareType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFareType = newValue;
                        _updateFarePrice(); // Call the function to update farePrice
                      });
                    },
                    items: ['Regular', 'Special'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Passenger Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select'),
                    value: selectedPassengerType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPassengerType = newValue;
                      });
                    },
                    items: ['Regular', 'Student-PWD-Senior Citizen']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _navigateToConfirmationScreen();
                    },
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

  void _updateFarePrice() {
    // You can implement your dynamic fare calculation logic here
    // For example, based on the selected fareType, you can set the farePrice
    // You might want to fetch data from Firebase or calculate based on some formula

    // Placeholder code:
    if (selectedFareType == 'Regular') {
      setState(() {
        farePrice = 5.0; // Adjust with your actual calculation
      });
    } else if (selectedFareType == 'Special') {
      setState(() {
        farePrice = 10.0; // Adjust with your actual calculation
      });
    }
  }
}
