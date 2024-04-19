import 'package:bay_yahe_app/Chat/chat_page.dart';
import 'package:bay_yahe_app/screens/History/historyscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final User? user = FirebaseAuth.instance.currentUser;
final FirebaseFirestore firestore = FirebaseFirestore.instance;
final CollectionReference bookingDetails =
    FirebaseFirestore.instance.collection('booking_details');
const String status1 = "pending";
const String status2 = "accepted";
const String cancel = "cancelled";

class Passenger {
  final String name;
  final String? avatarAsset;

  Passenger({required this.name, required this.avatarAsset});
}

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late List<Map<String, dynamic>> bookingHistory;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookingHistory();
  }

  void fetchBookingHistory() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await bookingDetails
              .where('userId', isEqualTo: user?.uid)
              .where('status', whereIn: [status1, status2]).get()
          as QuerySnapshot<Map<String, dynamic>>;

      if (querySnapshot.size > 0) {
        setState(() {
          bookingHistory = querySnapshot.docs.map((doc) => doc.data()).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching data: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Booking'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.3, -0.3),
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.green],
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : bookingHistory.isEmpty
                ? Center(child: Text('No Recent Booking available'))
                : ListView.builder(
                    itemCount: bookingHistory.length,
                    itemBuilder: (context, index) {
                      final data = bookingHistory[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: ListTile(
                          title: Text(
                            'Travel: ${data['pickupLocation'] ?? 'N/A'} - ${data['destination'] ?? 'N/A'}',
                          ),
                          subtitle: Text(formatTimestamp(data['bookingTime'])),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetailsScreen(
                                  bookingData: data,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    final philippinesTime = timestamp.toDate().add(const Duration(hours: 8));
    final formatter = DateFormat.yMMMMd().add_jm();
    return formatter.format(philippinesTime);
  }
}

class BookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingDetailsScreen({Key? key, required this.bookingData})
      : super(key: key);

  Future<Map<String, dynamic>> fetchDriverData(String driverId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('driver_user')
              .where('uid', isEqualTo: driverId)
              .get() as QuerySnapshot<Map<String, dynamic>>;

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
    } catch (error) {
      print("Error fetching driver data: $error");
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF33c072),
        title: const Text('On-going'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.3, -0.3),
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.green],
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookingDetailItem(
                      label: 'Your Ride Details',
                      value: 'Travel Preview',
                    ),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            bookingData['pickupLoc']['latitude'],
                            bookingData['pickupLoc']['longitude'],
                          ),
                          zoom: 12.0,
                        ),
                        markers: Set<Marker>.from([
                          Marker(
                            markerId: MarkerId('pickup_location'),
                            position: LatLng(
                              bookingData['pickupLoc']['latitude'],
                              bookingData['pickupLoc']['longitude'],
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRed),
                            infoWindow: InfoWindow(
                              title: 'Pickup Location',
                            ),
                          ),
                          Marker(
                            markerId: MarkerId('destination_location'),
                            position: LatLng(
                              bookingData['destinationLoc']['latitude'],
                              bookingData['destinationLoc']['longitude'],
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
                    BookingDetailItem(
                      label: 'Status',
                      value: bookingData['status'],
                    ),
                    BookingDetailItem(
                      label: 'Date & Time',
                      value: formatTimestamp(bookingData['bookingTime']),
                    ),
                    BookingDetailItem(
                      label: 'Travel Cost',
                      value:
                          '₱ ${bookingData['totalPrice'].toStringAsFixed(0)}',
                    ),
                    BookingDetailItem(
                      label: 'Distance',
                      value: '${bookingData['distance'].toStringAsFixed(1)} km',
                    ),
                    BookingDetailItem(
                      label: 'Passenger',
                      value: bookingData['contactPerson'],
                    ),
                    BookingDetailItem(
                      label: 'Contact',
                      value: bookingData['contactNumber'],
                    ),
                    BookingDetailItem(
                      label: 'Travel',
                      value:
                          'from: ${bookingData['pickupLocation']}     to: ${bookingData['destination']}',
                    ),
                    BookingDetailItem(
                      label: 'Fare',
                      value: bookingData['fareType'],
                    ),
                    BookingDetailItem(
                      label: 'Type',
                      value: '${bookingData['passengerType']}',
                    ),
                    BookingDetailItem(
                      label: 'Mode of Payment',
                      value: bookingData['paymentMethod'],
                    ),
                    BookingDetailItem(
                      label: 'Reference Number',
                      value: bookingData['transactionID'],
                    ),
                    Row(
                      children: [
                        if (bookingData['status'] == status2)
                          FutureBuilder<Map<String, dynamic>>(
                            future: fetchDriverData(bookingData['driverId']),
                            builder: (context, driverSnapshot) {
                              if (driverSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (driverSnapshot.hasError) {
                                return Center(
                                    child: Text('Error loading driver data'));
                              } else if (!driverSnapshot.hasData ||
                                  driverSnapshot.data!.isEmpty) {
                                return Center(
                                    child: Text('Driver data not found'));
                              }
                              Map<String, dynamic> driverData =
                                  driverSnapshot.data!;
                              return Column(
                                children: [
                                  BookingDetailItem(
                                    label: 'Driver Profile',
                                    value: Image.network(
                                      driverData['profilePic'],
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 100,
                                    ),
                                  ),
                                  BookingDetailItem(
                                    label: 'Name',
                                    value:
                                        '${driverData['firstname']} ${driverData['lastname']}',
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatPage(
                                              driverUserID:
                                                  bookingData['driverId'] ?? '',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text('Chat Driver'),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        Spacer(),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: ElevatedButton(
                            onPressed: () async {
                              await bookingDetails
                                  .where("userId", isEqualTo: user?.uid)
                                  .get()
                                  .then(
                                (querySnapshot) {
                                  for (var doc in querySnapshot.docs) {
                                    doc.reference.update({
                                      'status': cancel,
                                    });
                                  }
                                },
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryTab(),
                                ),
                              );
                            },
                            child: Text('Cancel'),
                          ),
                        ),
                      ],
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

  String formatTimestamp(Timestamp timestamp) {
    final philippinesTime = timestamp.toDate().add(const Duration(hours: 8));
    final formatter = DateFormat.yMMMMd().add_jm();
    return formatter.format(philippinesTime);
  }
}

class BookingDetailItem extends StatelessWidget {
  final String label;
  final dynamic value;

  const BookingDetailItem({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          // Use a conditional check to display either text or handle null value
          value is String
              ? Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              : value == null
                  ? Text('N/A') // or any default text you want to display
                  : value is Widget
                      ? value // Display the image widget directly
                      : Text('Invalid value type'),
        ],
      ),
    );
  }
}
