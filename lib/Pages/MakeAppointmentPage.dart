import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telehelth/Pages/HomePage.dart';
import 'DocSpotPage.dart';
import '../Services/firestoreService.dart';

class MakeAppointment extends StatefulWidget {
  final String doctorEmail;
  MakeAppointment({super.key, required this.doctorEmail});

  @override
  State<MakeAppointment> createState() => _MakeAppointmentState(doctorEmail: doctorEmail);
}

class _MakeAppointmentState extends State<MakeAppointment> {
  final FirestoreService _firestoreService = FirestoreService();
  late String doctorEmail;
  Timestamp? _selectedAppointment;

  _MakeAppointmentState({required this.doctorEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Appointment'),
      ),
      body: FutureBuilder<List<Timestamp>>(
        future: _firestoreService.getAvilableAppointments(doctorEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No available appointments'));
          } else {
            final availableAppointments = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: availableAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = availableAppointments[index];
                      final date = appointment.toDate();
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            title: Text(
                              'Appointment available at Date: ${date.day}/${date.month}/${date.year} on Time: ${date.hour}:${date.minute}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Radio<Timestamp?>(
                              value: appointment,
                              groupValue: _selectedAppointment,
                              onChanged: (value) {
                                setState(() {
                                  _selectedAppointment = value;
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _selectedAppointment != null ? () async {
                      bool success = await _firestoreService.createAppointment(doctorEmail: doctorEmail, assignedTime: _selectedAppointment);
                      _showResultDialog(success);
                    } : null,
                    child: const Text('Make Appointment'),
                  ),
                ),
                if (_selectedAppointment == null)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Please choose an appointment before making one.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  void _showResultDialog(bool success) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(success ? 'Success' : 'Failure'),
          content: Text(success ? 'Your appointment was successfully created. \nYou will be reminded 24 hours before your appointment ' : 'There was an error creating your appointment.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (success) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage(bodyPage: DocSpot(),))
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}