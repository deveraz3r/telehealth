import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Services/firestoreService.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late Future<List<Map<String, dynamic>?>> _appointmentsHistory;
  TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    getHistory();
    super.initState();
  }

  void getHistory() async {
    _appointmentsHistory = FirestoreService().getAppointmentsHistory();
    setState(() {});
  }

  void _showNotesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Appointment Report'),
          content: Text(
            '${_notesController.text}',
            maxLines: 5,
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>?>>(
        future: _appointmentsHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No appointments found.'));
          } else {
            final appointments = snapshot.data!;
            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                if (appointment == null) return SizedBox.shrink();

                final doctorEmail = appointment['doctorEmail'];
                final patientEmail = appointment['patientEmail'];
                final assignedTime = (appointment['assignedTime'] as Timestamp).toDate();
                final notesId = appointment['notesId'];
                final appointmentId = appointment['appointmentId'];

                final date = '${assignedTime.year}-${assignedTime.month.toString().padLeft(2, '0')}-${assignedTime.day.toString().padLeft(2, '0')}';
                final time = '${assignedTime.hour.toString().padLeft(2, '0')}:${assignedTime.minute.toString().padLeft(2, '0')}';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Appointment conducted by ',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                TextSpan(
                                  text: doctorEmail,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' with ',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                TextSpan(
                                  text: patientEmail,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Date: $date, Time: $time',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 16.0),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () async{
                                // print('Notes ID: $notesId, Appointment ID: $appointmentId');
                                String? _message = await FirestoreService().getNote(noteId: notesId[0]) ?? 'Report is empty';
                                setState(() {
                                  _notesController.text = _message;
                                });
                                _showNotesDialog();
                              },
                              child: Text('View Report'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

