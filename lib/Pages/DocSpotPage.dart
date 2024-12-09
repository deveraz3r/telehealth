import 'package:flutter/material.dart';
import 'package:telehelth/Services/firestoreService.dart';
import 'DoctorDetailsPage.dart';
import 'HomePage.dart';

class DocSpot extends StatefulWidget {
  String? nameSearch;
  DocSpot({Key? key, this.nameSearch}) : super(key: key);

  @override
  State<DocSpot> createState() => _DocSpotState(nameSearch: nameSearch);
}

class _DocSpotState extends State<DocSpot> {
  List<Map<String, dynamic>?> _allDoctors = [];
  int? _selectedDoctorIndex;
  late String? nameSearch;

  _DocSpotState({required this.nameSearch});

  @override
  void initState() {
    print(nameSearch);
    getDoctor();
    super.initState();
  }

  void getDoctor() async {
    List<Map<String, dynamic>?> doc = await FirestoreService().getAllDoctors();
    setState(() {
      _allDoctors = doc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _allDoctors.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (MediaQuery.of(context).orientation == Orientation.portrait) ? 2 : 3,
          childAspectRatio: 0.8, // Adjust the aspect ratio to increase the size of the cards
        ),
        itemBuilder: (context, index) {
          final doctor = _allDoctors[index];
          if (doctor != null && doctor.containsKey('firstName') && doctor.containsKey('lastName') && doctor.containsKey('specialty')) {
            if (nameSearch != null) {
              if (nameSearch == doctor['firstName'] || nameSearch == doctor['lastName']) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDoctorIndex = index;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage(bodyPage: DocDetails(doctor: doctor))),
                    );
                  },
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // Align elements vertically in the center
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 35, // Increase the size of the avatar
                          child: Text(
                            '${doctor['firstName'][0]}${doctor['lastName'][0]}',
                            style: const TextStyle(color: Colors.white, fontSize: 24), // Increase the font size of the initials
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          '${doctor['firstName']} ${doctor['lastName']}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Increase the font size of the name
                          textAlign: TextAlign.center, // Center the name
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          doctor['specialty'],
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]), // Increase the font size of the specialty
                          textAlign: TextAlign.center, // Center the specialty
                        ),
                      ],
                    ),
                  ),
                );
              }
            } else {
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDoctorIndex = index;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage(bodyPage: DocDetails(doctor: doctor))),
                  );
                },
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Align elements vertically in the center
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        radius: 45,
                        child: Text(
                          '${doctor['firstName'][0].toString().toUpperCase()}${doctor['lastName'][0].toString().toUpperCase()}',
                          style: const TextStyle(color: Colors.white, fontSize: 24), // Increase the font size of the initials
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${doctor['firstName']} ${doctor['lastName']}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Increase the font size of the name
                        textAlign: TextAlign.center, // Center the name
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        doctor['specialty'],
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]), // Increase the font size of the specialty
                        textAlign: TextAlign.center, // Center the specialty
                      ),
                    ],
                  ),
                ),
              );
            }
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}