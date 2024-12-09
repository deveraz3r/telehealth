import 'package:flutter/material.dart';
import 'firestoreService.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAVi4DJa03qLYPxnChebdbkg4-p-sPdOW8",
        appId: "1:905452996013:web:c8ab495e82208033c68d24",
        messagingSenderId: "905452996013",
        projectId: "telehealth-b9a5a",
      )
  );
  runApp(const testFirestore());
}

class testFirestore extends StatelessWidget {
  const testFirestore({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showSemanticsDebugger: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Testing firestore service'),),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () async{
                  DateTime date = DateTime(2001, 12, 17);
                  // await FirestoreService().createPatient(email: 'mouaz@gmail.com', password: 'mouazKaPassword', firstName: 'Mouaz', lastName: 'mujeeb', dob: date, gender: 'Oni chan UwU', insuranceId: 221323);
                  await FirestoreService().createDoctor(email: 'abdullah@gmail.com', password: 'abdullahKaPassword', firstName: 'Abdullah', lastName: 'Shakeel', dob: date, gender: 'other', qualification: 'matirc fail', specialty: 'Athelatics');
                },
                child: const Text('upload')
            )
          ],
        ),
      ),
    );
  }
}
