import 'package:flutter/material.dart';
import 'DocSpotPage.dart';
import 'HomePage.dart';
import 'MakeAppointmentPage.dart';

class DocDetails extends StatefulWidget {
  Map<String, dynamic>? doctor;

  DocDetails({required this.doctor, Key? key}) : super(key: key);

  @override
  State<DocDetails> createState() => _DocDetailsState(doctor: doctor,);
}

class _DocDetailsState extends State<DocDetails> {
  Map<String, dynamic>? doctor;

  _DocDetailsState({required this.doctor,});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp),
          onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(bodyPage: DocSpot(),) ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          // elevation: 5,
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                  height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                  child: Image.asset('assets/images/doctor.png', fit: BoxFit.contain),
                ),
                Container(height: 10,),
                Text(
                  '${doctor?['firstName']} ${doctor?['lastName']}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Specality: ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ' ${doctor?['specialty']}',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Qualification: ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ' ${doctor?['qualification']}',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: [
                    Text(
                      'Bio: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.5),
                    ),
                    Text(
                      '${doctor?['bio']}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MakeAppointment(doctorEmail: doctor?['userEmail'])),
                      );
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple)
                    ),
                    child: const Text('Make Appointment', style: TextStyle(color: Colors.white),),
                  ),
                )


              ],
            ),
          ),
        ),
      ),
    );
  }
}
