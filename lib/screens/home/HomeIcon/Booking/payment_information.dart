import 'dart:math';
import 'package:bay_yahe_app/screens/Activities/activity_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

class BookingService {
  final user = FirebaseAuth.instance.currentUser!;
  final CollectionReference bookings =
      FirebaseFirestore.instance.collection('booking_details');

  Future<void> addBooking(Map<String, dynamic> bookingData) async {
    await bookings.add(bookingData);
  }
}

class PaymentInformationScreen extends StatefulWidget {
  final LatLng pickupselectedLocation;
  final LatLng destinationselectedLocation;
  final String pickuplandmark;
  final String destinationlandmark;
  final String contactPerson;
  final String contactNumber;
  final String paymentMethod;
  final String fareType;
  final String passengerType;

  const PaymentInformationScreen({
    Key? key,
    required this.pickupselectedLocation,
    required this.destinationselectedLocation,
    required this.pickuplandmark,
    required this.destinationlandmark,
    required this.contactPerson,
    required this.contactNumber,
    required this.paymentMethod,
    required this.fareType,
    required this.passengerType,
  }) : super(key: key);

  @override
  _PaymentInformationScreenState createState() =>
      _PaymentInformationScreenState();
}

class _PaymentInformationScreenState extends State<PaymentInformationScreen> {
  TextEditingController pickUpLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();
  TextEditingController farePriceController = TextEditingController();
  double distance = 0.0;
  double calculatedFare = 0.0;
  double farePrice = 0.0;
  double totalPrice = 0.0;
  void _updateFarePrice() {
    if (widget.fareType == 'Regular') {
      setState(() {
        farePrice = 10.0;
      });
    } else if (widget.fareType == 'Special') {
      setState(() {
        farePrice = 15.0;
      });
    }

    // Calculate total price after updating farePrice
    setState(() {
      _calculateDistance(
        widget.pickupselectedLocation.latitude,
        widget.pickupselectedLocation.longitude,
        widget.destinationselectedLocation.latitude,
        widget.destinationselectedLocation.longitude,
      );

      totalPrice = distance * farePrice;
    });
  }

  @override
  void initState() {
    super.initState();

    // Call _updateFarePrice to calculate and update the farePrice
    _updateFarePrice();
  }

  void _confirmPaymentInformation() async {
    BookingService bookingService = BookingService();
    final String status = "pending";
    String transactionId = _generateTransactionId();

    double distance = _calculateDistance(
      widget.pickupselectedLocation.latitude,
      widget.pickupselectedLocation.longitude,
      widget.destinationselectedLocation.latitude,
      widget.destinationselectedLocation.longitude,
    );

    Map<String, dynamic> bookingData = {
      'pickupLoc': {
        'latitude': widget.pickupselectedLocation.latitude,
        'longitude': widget.pickupselectedLocation.longitude,
      },
      'destinationLoc': {
        'latitude': widget.destinationselectedLocation.latitude,
        'longitude': widget.destinationselectedLocation.longitude,
      },
      'totalPrice': totalPrice,
      'contactPerson': widget.contactPerson,
      'contactNumber': widget.contactNumber,
      'paymentMethod': widget.paymentMethod,
      'fareType': widget.fareType,
      'passengerType': widget.passengerType,
      'pickupLocation': widget.pickuplandmark,
      'destination': widget.destinationlandmark,
      'status': status,
      'transactionID': 'booking_' + transactionId,
      'bookingTime': DateTime.now(),
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'distance': distance,
      'driverId': "",
    };

    bookingService.addBooking(bookingData);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityScreen(),
      ),
    );
  }

  String _generateTransactionId() {
    Random random = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() +
        random.nextInt(999).toString();
  }

  double _calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const R = 6371.0; // Earth radius in kilometers

    double dLat = _degreesToRadians(endLatitude - startLatitude);
    double dLon = _degreesToRadians(endLongitude - startLongitude);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(startLatitude)) *
            math.cos(_degreesToRadians(endLatitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    distance = R * c; // Distance in kilometers
    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Information'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"), // Adjust the path accordingly
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Contact Person',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.contactPerson,
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const Text(
                      'Contact Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.contactNumber,
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.paymentMethod,
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Fare Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.fareType,
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Passenger Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.passengerType,
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pick Up Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.pickuplandmark,
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Destination',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.destinationlandmark,
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Fare Price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      initialValue: farePrice.toString(),
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Map',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            widget.pickupselectedLocation.latitude,
                            widget.pickupselectedLocation.longitude,
                          ),
                          zoom: 14.0,
                        ),
                        markers: Set<Marker>.from([
                          Marker(
                            markerId: MarkerId('pickup_location'),
                            position: LatLng(
                              widget.pickupselectedLocation.latitude,
                              widget.pickupselectedLocation.longitude,
                            ),
                            icon: BitmapDescriptor.defaultMarker,
                            infoWindow: InfoWindow(
                              title: 'Pickup Location',
                            ),
                          ),
                          Marker(
                            markerId: MarkerId('destination_location'),
                            position: LatLng(
                              widget.destinationselectedLocation.latitude,
                              widget.destinationselectedLocation.longitude,
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueGreen),
                            infoWindow: InfoWindow(
                              title: 'Destination Location',
                            ),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('₱ ${totalPrice.toStringAsFixed(0)}'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _confirmPaymentInformation,
                      child: const Text('Book Now'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16),
                      ),
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
}
