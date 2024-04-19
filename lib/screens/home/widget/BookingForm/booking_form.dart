// BookingForm.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'pickup_destination_page.dart';

enum BookingStatus { asap, scheduled }

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BookingForm(),
    );
  }
}

class BookingForm extends StatefulWidget {
  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  BookingStatus bookingStatus = BookingStatus.asap;
  String pickupLocation = 'Select Pickup Location';
  String destination = 'Select Destination';
  DateTime? selectedDate = DateTime.now();
  TimeOfDay? selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBookingStatusButton(),
            if (bookingStatus == BookingStatus.scheduled) ...[
              SizedBox(height: 16),
              _buildDateTimeDisplay(),
              SizedBox(height: 16),
              _buildDateTimeButtons(),
            ],
            SizedBox(height: 16),
            _buildLocationButton(
              label: 'Pickup Location',
              onPressed: () => _navigateToPickupDestinationPage(true),
            ),
            SizedBox(height: 16),
            _buildLocationButton(
              label: 'Destination',
              onPressed: () => _navigateToPickupDestinationPage(false),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitBooking,
              child: Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingStatusButton() {
    return ElevatedButton(
      onPressed: _showBookingStatusDialog,
      child:
          Text('Booking Status: ${bookingStatus.toString().split('.').last}'),
    );
  }

  Widget _buildDateTimeDisplay() {
    return Column(
      children: [
        Text(
          'Selected Date: ${selectedDate != null ? _formatDate(selectedDate!) : 'Not set'}',
        ),
        SizedBox(height: 8),
        Text(
          'Selected Time: ${selectedTime != null ? _formatTime(selectedTime!) : 'Not set'}',
        ),
      ],
    );
  }

  Widget _buildDateTimeButtons() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => _selectDate(context),
          child: Text('Select Date'),
        ),
        SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => _selectTime(context),
          child: Text('Select Time'),
        ),
      ],
    );
  }

  Widget _buildLocationButton(
      {required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
          '$label: ${label == 'Pickup Location' ? pickupLocation : destination}'),
    );
  }

  Future<void> _showBookingStatusDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Booking Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusButton(BookingStatus.asap),
              _buildStatusButton(BookingStatus.scheduled),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusButton(BookingStatus status) {
    return ElevatedButton(
      onPressed: () {
        _updateBookingStatus(status);
      },
      child: Text(status == BookingStatus.asap ? 'ASAP' : 'Scheduled'),
    );
  }

  void _updateBookingStatus(BookingStatus status) {
    setState(() {
      bookingStatus = status;
      if (status == BookingStatus.asap) {
        selectedDate = null;
        selectedTime = null;
      }
    });
    Navigator.of(context).pop();
  }

  void _navigateToPickupDestinationPage(bool isPickup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickupDestinationPage(
          isPickup: isPickup,
          onLocationSelected: (location) {
            _updateLocation(isPickup, location);
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  void _submitBooking() {
    print('Booking Status: ${bookingStatus.toString().split('.').last}');
    print('Pickup Location: $pickupLocation');
    print('Destination: $destination');

    if (bookingStatus == BookingStatus.scheduled) {
      print(
          'Selected Date: ${selectedDate != null ? _formatDate(selectedDate!) : 'Not set'}');
      print(
          'Selected Time: ${selectedTime != null ? _formatTime(selectedTime!) : 'Not set'}');
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatTime(TimeOfDay time) {
    return time.format(context);
  }

  void _updateLocation(bool isPickup, String location) {
    setState(() {
      if (isPickup) {
        pickupLocation = location;
      } else {
        destination = location;
      }
    });
  }
}
