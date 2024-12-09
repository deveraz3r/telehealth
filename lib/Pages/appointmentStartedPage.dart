import 'package:flutter/material.dart';
import 'package:telehelth/Pages/DocSpotPage.dart';
import 'HomePage.dart';
import '../Services/firestoreService.dart';

class AppointmentDoctor extends StatefulWidget {
  int appointmentId;
  AppointmentDoctor({super.key, required this.appointmentId});

  @override
  State<AppointmentDoctor> createState() => _AppointmentDoctorState(appointmentId: appointmentId);
}

class _AppointmentDoctorState extends State<AppointmentDoctor> {
  int appointmentId;
  TextEditingController _notesController = TextEditingController();
  late Map<String, dynamic> appDoc;

  _AppointmentDoctorState({required this.appointmentId});

  @override
  void initState() {
    getAppointmentDetails();
    super.initState();
  }

  void getAppointmentDetails() async {
    //get appointment document

  }

  void _showNotesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Write Notes'),
          content: TextField(
            controller: _notesController,
            maxLines: 5,
            decoration: const InputDecoration(hintText: 'Enter notes here'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Appointment - Doctor'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(
          child: Text('Chat here', style: TextStyle(fontSize: 24)),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'end_appointment',
              onPressed: () async{
                await FirestoreService().closeAppointment(appointmentId: appointmentId, noteMessage: _notesController.text);
                await FirestoreService().deleteNotfication(appointmentId: appointmentId);
                
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage(bodyPage: DocSpot(),))
                );
              },
              child: const Icon(Icons.call_end),
              tooltip: 'End Appointment',
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'notes',
              onPressed: _showNotesDialog,
              child: const Icon(Icons.note),
              tooltip: 'Write Notes',
            ),
          ],
        ),
      ),
    );
  }
}



//patient page
class AppointmentPatient extends StatefulWidget {
  int appointmentId;
  AppointmentPatient({super.key, required this.appointmentId});

  @override
  State<AppointmentPatient> createState() => _AppointmentPatientState(appointmentId: appointmentId);
}

class _AppointmentPatientState extends State<AppointmentPatient> {
  int appointmentId;

  _AppointmentPatientState({required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Appointment - Patient'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Text('Chat here', style: TextStyle(fontSize: 24)),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // moves patient to home page
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(bodyPage: DocSpot(),))
            );
          },
          child: const Icon(Icons.call_end),
          tooltip: 'End Appointment',
        ),
      ),
    );
  }
}

