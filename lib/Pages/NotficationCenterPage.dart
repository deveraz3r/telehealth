import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telehelth/Services/firestoreService.dart';
import 'appointmentStartedPage.dart';

class NotificationCenter extends StatefulWidget {
  @override
  _NotificationCenterState createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> notifications = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      fetchNotifications();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchNotifications() async {
    QuerySnapshot querySnapshot = await _firestore.collection('notfication').get();
    List<Map<String, dynamic>> tempNotifications = [];
    DateTime now = DateTime.now();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> notification = doc.data() as Map<String, dynamic>;
      Timestamp displayAfter = notification['displayAfter'];
      Timestamp endTime = notification['endTime'];

      if (now.isAfter(displayAfter.toDate()) && now.isBefore(endTime.toDate())) {
        tempNotifications.add(notification);
      }
    }

    setState(() {
      notifications = tempNotifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return NotificationTile(notification: notifications[index]);
        },
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;

  NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    Timestamp assignedTime = notification['assignedTime'];
    Timestamp displayAfter = notification['displayAfter'];
    Timestamp recallTime = notification['recallTime'];
    Timestamp endTime = notification['endTime'];

    DateTime now = DateTime.now();
    String message = '';
    Widget? actionButton;
    DateTime date = assignedTime.toDate();
    String formattedDate = "${date.day}/${date.month}/${date.year}";
    String formattedTime = "${date.hour}:${date.minute}";

    if (now.isAfter(displayAfter.toDate()) && now.isBefore(recallTime.toDate())) {
      message = 'Your appointment is scheduled at Date: $formattedDate Time: $formattedTime';
    } else if (now.isAfter(recallTime.toDate()) && now.isBefore(assignedTime.toDate())) {
      message = 'Your appointment is starting soon.';
    } else if (now.isAfter(assignedTime.toDate()) && now.isBefore(endTime.toDate())) {
      message = 'Your appointment is now. Please start.';
      actionButton = ElevatedButton(
        onPressed: () {
          String currentUserEmail = FirestoreService().currentUserEmail;
          print(currentUserEmail);
          if(currentUserEmail == notification['doctorEmail']){
            Navigator.push(
                context,
                MaterialPageRoute( builder: (context) => AppointmentDoctor(appointmentId: notification['appId'],) )
            );
          }
          else{
            Navigator.push(
                context,
                MaterialPageRoute( builder: (context) => AppointmentPatient(appointmentId: notification['appId'],) )
            );
          }


        },
        child: Text('Start Appointment'),
      );
    } else if (now.isAfter(endTime.toDate())) {
      message = 'Your appointment has ended or was canceled.';
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          title: Text('Appointment ${notification['appId']}'),
          subtitle: message.contains('scheduled at Date')
              ? RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(text: 'Your appointment is scheduled at Date: '),
                TextSpan(
                  text: formattedDate,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' Time: '),
                TextSpan(
                  text: formattedTime,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
              : Text(message),
          trailing: actionButton,
        ),
      ),
    );
  }
}
