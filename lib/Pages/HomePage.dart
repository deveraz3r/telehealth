import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Services/firestoreService.dart';
import 'ManageDoctorProfile.dart';
import 'ManagePatientProfile.dart';
import 'DocSpotPage.dart';
import 'HistoryPage.dart';
import 'ManageAppointmentPage.dart';
import 'SupportPage.dart';
import 'NotficationCenterPage.dart';

class HomePage extends StatefulWidget {
  final dynamic bodyPage;

  const HomePage({this.bodyPage, super.key});

  @override
  State<HomePage> createState() => _HomePageState(bodyPage: bodyPage);
}

class _HomePageState extends State<HomePage> {
  final User? user = FirestoreService().currentUser; // get current user
  late String _UserName = 'loading';
  late String _userEmail = 'loading';
  dynamic bodyPage = DocSpot();
  String profile = '';
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  //constructor
  _HomePageState({this.bodyPage});

  void _toggleSearchBar() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });
  }

  void _performSearch() {
    String searchQuery = _searchController.text.trim();
    if (searchQuery.isNotEmpty) {
      // Perform search logic here
      setState(() {
        bodyPage = DocSpot(nameSearch: searchQuery);
      });
      print('Searching for: $searchQuery');
      _toggleSearchBar(); // Collapse the search bar
    }
  }

  //gets email of user
  void _getUserEmail() {
    String email = user?.email ?? 'User email';
    setState(() {
      _userEmail = email;
    });
  }

  //get usertype of user
  void _loadUserType() async{
    String userType = await FirestoreService().getUserType(_userEmail);
    setState((){
      profile = userType;
    });
  }

  Future<void> _loadUsername() async {
    String userName = await FirestoreService().getUsername(_userEmail);
    setState(() {
      _UserName = userName;
    });
  }

  @override
  void initState() {
    _getUserEmail();
    _loadUsername();
    _loadUserType();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TeleHealth'),
          backgroundColor: Colors.deepPurple,
          actions: [

            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationCenter()),
                );
              },
              icon: const Icon(Icons.notifications),
            ),
          ],
        ),
        body: bodyPage,
        drawer: Drawer(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: const CircleAvatar(
                  child: Icon(Icons.account_circle),
                ),
                accountName: Text(_UserName),
                accountEmail: Text(_userEmail),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.account_balance_outlined),
                      title: const Text('DocSpot'),
                      onTap: () {
                        setState(() {
                          bodyPage = DocSpot();
                        });
                      },
                    ),
                    Visibility(
                      visible: profile == 'doctor',
                      child: ListTile(
                        leading: const Icon(Icons.doorbell),
                        title: const Text('Manage Appointments'),
                        onTap: () {
                          setState(() {
                            bodyPage = ManageAppointment(userEmail: _userEmail,);
                          });
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.account_box_sharp),
                      title: const Text('Manage Profile'),
                      onTap: () {
                        setState(() {
                          if (profile == 'doctor') {
                            bodyPage = ManageDoctor(_userEmail);
                          } else {
                            bodyPage = ManagePatient(_userEmail);
                          }
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('History'),
                      onTap: () {
                        setState(() {
                          bodyPage = const History();
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.support_agent),
                      title: const Text('Support'),
                      onTap: () {
                        setState(() {
                          bodyPage = const SupportPage();
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                      },
                      child: const Text('Sign Out'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}