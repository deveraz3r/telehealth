import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telehelth/Services/firestoreService.dart';

class ManageAppointment extends StatefulWidget {
  final String userEmail;

  ManageAppointment({required this.userEmail, Key? key}) : super(key: key);

  @override
  State<ManageAppointment> createState() => _ManageAppointmentState(userEmail: userEmail);
}

class _ManageAppointmentState extends State<ManageAppointment> {
  final List<String> _types = ['Available Appointments', 'Assigned Appointments'];
  String? _selectedType;
  final String userEmail;
  bool _isAvailableView = true;

  _ManageAppointmentState({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Appointment'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _types.map((type) {
                return RadioListTile<String>(
                  title: Text(type),
                  value: type,
                  groupValue: _selectedType,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedType = value;
                      _isAvailableView = value == 'Available Appointments';
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isAvailableView
                ? AvailableAppointments(userEmail: userEmail)
                : AssignedAppointments(userEmail: userEmail),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAvailableTimeDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddAvailableTimeDialog(BuildContext context) async {
    final _dateController = TextEditingController();
    DateTime selectedDate = DateTime(2000);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Available Time'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    hintText: 'Select Date and Time',
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                          _dateController.text = selectedDate.toString();
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                setState(() async {
                  bool flag = await FirestoreService().addNewAvilableAppointment(userEmail: userEmail, newDate: selectedDate);
                  if (flag) {
                    Navigator.of(context).pop();
                  } else {
                    print('Some error while adding new appointment');
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
}

class AvailableAppointments extends StatefulWidget {
  final String userEmail;

  AvailableAppointments({required this.userEmail, Key? key}) : super(key: key);

  @override
  _AvailableAppointmentsState createState() => _AvailableAppointmentsState(userEmail: userEmail);
}

class _AvailableAppointmentsState extends State<AvailableAppointments> {
  List<Timestamp> _availableAppointments = [];
  final String userEmail;

  _AvailableAppointmentsState({required this.userEmail});

  @override
  void initState() {
    super.initState();
    _getAvailableAppointments();
  }

  Future<void> _getAvailableAppointments() async {
    try {
      List<Timestamp> appointments = await FirestoreService().getAvilableAppointments(userEmail);
      setState(() {
        _availableAppointments = appointments;
      });
    } catch (e) {
      print('Error getting available appointments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _availableAppointments.isEmpty
        ? const Center(
      child: Text('No available appointments'),
    )
        : ListView.builder(
      itemCount: _availableAppointments.length,
      itemBuilder: (context, index) {
        Timestamp timestamp = _availableAppointments[index];
        DateTime dateTime = timestamp.toDate();
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: ListTile(
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  FirestoreService().removeAvilableTime(doctorEmail: userEmail, assignedTime: timestamp);
                });
              },
            ),
            title: Text(
              'Appointment available at Date: ${dateTime.day}/${dateTime.month}/${dateTime.year} on time: ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(),
            ),
          ),
        );
      },
    );
  }
}

class AssignedAppointments extends StatefulWidget {
  final String userEmail;

  AssignedAppointments({required this.userEmail, Key? key}) : super(key: key);

  @override
  State<AssignedAppointments> createState() => _AssignedAppointmentsState(userEmail: userEmail);
}

class _AssignedAppointmentsState extends State<AssignedAppointments> {
  final String userEmail;
  List<Map<String, dynamic>> _assignedAppointments = [];

  _AssignedAppointmentsState({required this.userEmail});

  @override
  void initState() {
    super.initState();
    _getAssignedAppointments();
  }

  Future<void> _getAssignedAppointments() async {
    try {
      List<Map<String, dynamic>> appointments = await FirestoreService().getOpenAppointmentsByDoctorEmail(userEmail);
      setState(() {
        _assignedAppointments = appointments;
      });
    } catch (e) {
      print('Error getting assigned appointments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _assignedAppointments.isEmpty
        ? const Center(
      child: Text('No assigned appointments'),
    )
        : ListView.builder(
      itemCount: _assignedAppointments.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> appointment = _assignedAppointments[index];
        DateTime? dateTime;
        if (appointment['assignedTime'] != null) {
          dateTime = (appointment['assignedTime'] as Timestamp).toDate();
        }
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: ListTile(
            title: dateTime != null
                ? Text(
              'You have an appointment with ${appointment['patientEmail']} on Date: ${dateTime.day}/${dateTime.month}/${dateTime.year} on time ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.purple),
            )
                : Text(
              'You have an appointment with ${appointment['patientEmail']}, but the date is missing.',
              style: const TextStyle(color: Colors.purple),
            ),
          ),
        );
      },
    );
  }
}
