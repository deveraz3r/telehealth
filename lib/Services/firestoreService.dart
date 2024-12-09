import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; //to reference firebaseAuth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; //to reference firestore
  User? get currentUser => _firebaseAuth.currentUser;
  late String currentUserEmail;

  FirestoreService(){
    currentUserEmail = _firebaseAuth.currentUser?.email ?? 'userEmail';
  }

  //TODO: why did i add this????????
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  //signOut user with firebaseAuth
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  //========================================== Functions ================================================================|
  Future<int> _getMaxId({required String collection, required String key}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collection).get();

      int maxNumber = 0; // Initialize maxNumber with a default value

      for (var doc in querySnapshot.docs) {
        // Access the field containing the number, adjust the field name accordingly
        int number = doc[key];
        if (number > maxNumber) {
          maxNumber = number;
        }
      }

      // print('Max number in the collection: $maxNumber');
      return maxNumber;
    } on FirebaseException catch (e) {
      print('Error: $e');
      return -1;
    }
  }

  //========================================== CREATE DOCS ================================================================|
  //create user with email and password
  Future<bool> _createUser({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    required DateTime? dob,
    required String? gender,
  }) async {
    //create user with firebaseAuth
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      print('User created sucessfully');
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      return false;
    }

    //save data in map before sending it to firestore Database
    Map<String, dynamic> data = {
      'userEmail': email.toLowerCase(),
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dob': dob,
    };

    try {
      await _firestore.collection('users').add(data);
      print('user added sucessfully!');
      return true;
    } on FirebaseException catch (e) {
      print('Error: ${e.message}');
      return false;
    }
  }

  //create patient
  Future<bool> createPatient({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    required DateTime? dob,
    required String gender,
    required int insuranceId
  }) async {
    if (!(await _createUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        dob: dob,
        gender: gender))) {
      return false; //return false if user was not created
    }

    //get max id from docs
    int maxId = await _getMaxId(collection: 'patients', key: 'patientId');

    Map<String, dynamic> data = {
      'patientId': maxId + 1,
      'userEmail': email.toLowerCase(),
      'insuranceId': insuranceId,
      'medicalHistory': <String>[], //medical history is empty at time of creation TODO: create a table for notes and add its id here
    };

    //TODO: check insurance id before adding data after making insurance table

    try {
      await _firestore.collection('patients').add(data);
      print('patient added sucessfully!');
      return true;
    } on FirebaseException catch (e) {
      print('Error: ${e.message}');
      return false;
    }
  }

  //create doctor
  Future<bool> createDoctor({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    required DateTime? dob,
    required String? gender,
    required String qualification,
    required String specialty
  }) async {
    if (!(await _createUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        dob: dob,
        gender: gender))) {
      return false; //return false if user was not created
    }

    //get max id from docs
    int maxId = await _getMaxId(collection: 'doctors', key: 'doctorId');

    Map<String, dynamic> data = {
      'doctorId': maxId + 1,
      'userEmail': email.toLowerCase(),
      'qualification': qualification,
      'specialty': specialty,
      'bio': '',
      'availability': true,
    };

    try {
      await _firestore.collection('doctors').add(data);
      print('doctor added sucessfully!');
      return true;
    } on FirebaseException catch (e) {
      print('Error: ${e.message}');
      return false;
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  //creates new appointment of currently logged in user
  Future<bool> createAppointment({
    required String doctorEmail,
    required Timestamp? assignedTime,
  }) async {

    //remove avilable time before assigning it to patient
    removeAvilableTime(doctorEmail: doctorEmail, assignedTime: assignedTime);

    int appointmentId = await _getMaxId(collection: 'appointments', key: 'appointmentId') + 1;

    //create new appointment Document
    Map<String, dynamic> newAppointment = {
      'createdAt': Timestamp.now(),
      'patientEmail': currentUserEmail,
      'assignedTime': assignedTime,
      'status': 'open',
      'appointmentId': appointmentId,
      'notesId': [],
      'nextAppointmentDate': null,
      'doctorEmail': doctorEmail,
    };
    
    try{
      await _firestore.collection('appointments').add(newAppointment);  //add document to firestore

      bool flag = await createNewAppointmentNotfication(appId: appointmentId);
      if(!flag){
        return false;
      }

      return true;
    } on FirebaseException catch(e){
      print(e.message);
      return false;
    }
  }



  //add new avilable time to doctor
  Future<bool> addNewAvilableAppointment({
    required String userEmail,
    required DateTime newDate,
  }) async {
    try {

      QuerySnapshot querySnapshot = await _firestore.collection('doctors').where('userEmail', isEqualTo: userEmail).get();

      if (querySnapshot.docs.isNotEmpty) {
        var docId = querySnapshot.docs.first.id;
        Map<String, dynamic>? data = querySnapshot.docs.first.data() as Map<String, dynamic>?;
        // print(data);

        if (data != null && data.containsKey('avilableAppointments')) {
          // Get the avilableAppointments list, add the new date, and update it

          List<Timestamp> avilableAppointments = List<Timestamp>.from(data['avilableAppointments']);
          avilableAppointments.add(Timestamp.fromDate(newDate));

          await _firestore.collection('doctors').doc(docId).update({'avilableAppointments': avilableAppointments}); // Update the avilableAppointments list with the updated list
        } else {
          List<Timestamp> avilableAppointments = [Timestamp.fromDate(newDate)];
          await _firestore.collection('doctors').doc(docId).update({'avilableAppointments': avilableAppointments}); // Add the avilableAppointments list
        }

        return true;
      } else {
        return false;
      }
    } on FirebaseException catch (e) {
      print(e.message);
      return false;
    }
  }
  
  //create new notfication
  Future<bool> createNewAppointmentNotfication({
    required int appId,
  }) async {
    try{
      //get appointment doc here
      Map<String, dynamic>? appDoc = await getAppointment(appointmentId: appId);

      Timestamp? assignedTime = appDoc?['assignedTime'] ?? Timestamp.now();
      print(assignedTime);

      // Subtract 1 day from assigned time and assign it to displayAfter
      DateTime displayAfterDateTime = assignedTime!.toDate().subtract(Duration(days: 1));
      Timestamp? displayAfter = Timestamp.fromDate(displayAfterDateTime);

      // Subtract 10 minutes from assigned time and assign it to recallTime
      DateTime recallTimeDateTime = assignedTime!.toDate().subtract(Duration(minutes: 10));
      Timestamp? recallTime = Timestamp.fromDate(recallTimeDateTime);

      // Add 1 hour to assigned time and assign it to endTime
      DateTime endTimeDateTime = assignedTime!.toDate().add(Duration(hours: 1));
      Timestamp? endTime = Timestamp.fromDate(endTimeDateTime);

      //TODO: on assigned time display start appointment btn
      //TODO: display 1 day before
      //TODO: 10 mins before, display starting soon
      //TODO: cancel appointment after 1 hour if patient has not joined

      Map<String, dynamic>? newNotfication = {
        'appId': appId,
        'displayAfter': displayAfter,
        'recallTime': recallTime,
        'assignedTime': assignedTime,
        'endTime': endTime,
        'type': 'appointment',
        'patientEmail':  appDoc?['patientEmail'],
        'doctorEmail': appDoc?['doctorEmail'],
      };
      
      await _firestore.collection('notfication').add(newNotfication);
      return true;
    } on FirebaseException catch (e) {
      print(e.message);
      return false;
    }
  }

  //not used
  Future<Timestamp?> getAssignedTimeOfAssignedAppointment({required int appointmentId}) async{
    try{
      QuerySnapshot querySnapshot = await _firestore.collection('appointments').where('appointmentId', isEqualTo: appointmentId ).get();
      Map<String, dynamic>? appDoc = querySnapshot.docs.first.data() as Map<String, dynamic>?;

      if(appDoc!.containsKey('assignedTime')){
        Timestamp assignedTime = appDoc['assignedTime'];
        return assignedTime;
      }
      else{
        print('key assigned id does not exist');
        return null;
      }

    } on FirebaseException catch (e) {
      print(e.message);
      return null;
    }
  }

  //========================================== READ DOCS ================================================================
  //get username
  Future<String> getUsername(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').where('userEmail', isEqualTo: email).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        String userName = '${doc['firstName']} ${doc['lastName']}';
        return userName;
      } else {
        return 'User not found!';
      }
    } on FirebaseException catch (e) {
      print(e.message);
      return 'Unable to get username!';
    } catch (e) {
      print(e.toString());
      return 'An unexpected error occurred!';
    }
  }

  //TODO: wtf is this funciton
  //read all doctors
  Future<List<Map<String, dynamic>?>> getAllDoctors() async {
    QuerySnapshot allDoctorsSnapshot = await _firestore.collection('doctors').get();

    // Create a list of futures
    List<Future<Map<String, dynamic>?>> futures = allDoctorsSnapshot.docs.map((doc) async {
      return await getDoctor(doc['userEmail']);
    }).toList();

    // Wait for all futures to complete
    List<Map<String, dynamic>?> results = await Future.wait(futures);

    // Filter out any null results
    List<Map<String, dynamic>?> allDoctors = results.where((doc) => doc != null).toList();

    return allDoctors;
  }


  //get every thing related to one doctor
  Future<Map<String, dynamic>?> getDoctor(String userEmail) async{
    try{
      QuerySnapshot usersnapshot = await _firestore.collection('users').where('userEmail', isEqualTo: userEmail).limit(1).get();
      QuerySnapshot docSnapshot = await _firestore.collection('doctors').where('userEmail', isEqualTo: userEmail).limit(1).get();

      if(usersnapshot.docs.isEmpty || docSnapshot.docs.isEmpty){
        throw 'Document is not found!';
      }

      var userdoc = usersnapshot.docs.first;
      var doctordoc = docSnapshot.docs.first;

      var doctor = {
        'userEmail': userdoc['userEmail'],
        'firstName': userdoc['firstName'],
        'lastName': userdoc['lastName'],
        'gender': userdoc['gender'],
        'dob': userdoc['dob'],
        'doctorId': doctordoc['doctorId'],
        'qualification': doctordoc['qualification'],
        'specialty': doctordoc['specialty'],
        'bio': doctordoc['bio'],
        'availability': doctordoc['availability'],
      };
      return doctor;
    } on FirebaseException catch (e){
      print(e.message);
      return null;
    }
  }

  //get user type
  Future<String> getUserType(String userEmail) async{
    try{
      QuerySnapshot querySnapshot;

      //check if email exsists in doctors collection
      querySnapshot = await _firestore.collection('doctors').where('userEmail', isEqualTo: userEmail).limit(1).get();
      if(querySnapshot.docs.isNotEmpty){
        return 'doctor';
      }

      //check if email exist in patients collection
      querySnapshot = await _firestore.collection('patients').where('userEmail', isEqualTo: userEmail).limit(1).get();
      if(querySnapshot.docs.isNotEmpty){
        return 'patient';
      }

    } on FirebaseException catch (e) {
      print(e.message);
    }

    return 'none';
  }

  //get Assigned appointments of doctor
  Future<Map<String, dynamic>?> getAppointment({
    required int appointmentId
  }) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('appointments').where('appointmentId', isEqualTo: appointmentId).get();
      Map<String, dynamic>? appDoc = querySnapshot.docs.first.data() as Map<String, dynamic>?;

      print(appDoc);

      return appDoc;

    } on FirebaseException catch(e) {
      print(e.message);
      return null;
    }
  }

  //get Assigned appointments of doctor
  Future<List<Map<String, dynamic>?>> getAssignedAppointments({
    required String doctorEmail
  }) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('appointments').where('doctorEmail', isEqualTo: doctorEmail).get();

      // Initialize an empty list to store the document data
      List<Map<String, dynamic>?> assignments = [];

      // Iterate over each document in the QuerySnapshot
      for (var doc in querySnapshot.docs) {
        // Extract the document data and add it to the list
        assignments.add(doc.data() as Map<String, dynamic>?);
      }

      // Optionally, print the list to verify
      print(assignments);

      return assignments;

    } on FirebaseException catch(e) {
      print(e.message);
      // Return an empty list in case of error
      return [];
    }
  }

  //get list of avilable time
  Future<List<Timestamp>> getAvilableAppointments(String userEmail) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('doctors').where('userEmail', isEqualTo: userEmail).get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic>? data = querySnapshot.docs.first.data() as Map<String, dynamic>?;  //gets document as map

        if (data != null && data.containsKey('avilableAppointments')) { //check if doctor has avilable appointments?
          return List<Timestamp>.from(data['avilableAppointments']);
        }
        else{
          print('there are no available appointments');
          return [];  //return empty list if doctor has no avilable time
        }
      }
      else{
        print('doctor email does not exist!');
      }
      return [];
    } on FirebaseException catch (e) {
      print(e.message);
      return [];
    }
  }
  
  //get appointment history
  Future<List<Map<String, dynamic>?>> getAppointmentsHistory() async{
    late String emailType;

    //find out if user is doctor or patient
    String? usertype = await getUserType(currentUserEmail);
    emailType = usertype == 'doctor'? 'doctorEmail' : 'patientEmail';

    try{
      QuerySnapshot querySnapshot = await _firestore.collection('appointments').where(emailType, isEqualTo: currentUserEmail).where('status', isEqualTo: 'close').get();

      List<Map<String, dynamic>?> appointmentHistory = [];

      for(var doc in querySnapshot.docs){
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        appointmentHistory.add(data);
      }

      return appointmentHistory;
    } on FirebaseException catch (e) {
      print(e.message);
      return [];  //return empty list in case of error
    }
  }

  Future<List<Map<String, dynamic>>> getUserAppointments({
    required String userEmail,
  }) async {
    try {
      QuerySnapshot patientQuerySnapshot = await _firestore
          .collection('appointments')
          .where('patientEmail', isEqualTo: userEmail)
          .get();

      QuerySnapshot doctorQuerySnapshot = await _firestore
          .collection('appointments')
          .where('doctorEmail', isEqualTo: userEmail)
          .get();

      List<Map<String, dynamic>> appointments = [];

      // Adding patient appointments to the list
      for (var doc in patientQuerySnapshot.docs) {
        appointments.add(doc.data() as Map<String, dynamic>);
      }

      // Adding doctor appointments to the list
      for (var doc in doctorQuerySnapshot.docs) {
        appointments.add(doc.data() as Map<String, dynamic>);
      }

      return appointments;
    } on FirebaseException catch (e) {
      print(e.message);
      return [];
    }
  }

  //get notes message
  Future<String?> getNote({required int noteId}) async{
    try{
      QuerySnapshot querySnapshot = await _firestore.collection('notes').where('noteId', isEqualTo: noteId).get();
      Map<String, dynamic>? noteDoc = querySnapshot.docs.first.data() as Map<String, dynamic>?;
      // print(noteDoc);

      String? note = noteDoc?['note'];

      return note;
    } on FirebaseException catch (e) {
      print(e.message);
      return null;
    }
  }

  //========================================== UPDATE DOCS ================================================================

  // Update user firstName
  Future<bool> updateFirstName(String userEmail, String newFirstName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userEmail', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        await _firestore
            .collection('users')
            .doc(doc.id)
            .update({'firstName': newFirstName});
        return true;
      } else {
        return false; // User not found
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Update user lastName
  Future<bool> updateLastName(String userEmail, String newLastName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userEmail', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        await _firestore
            .collection('users')
            .doc(doc.id)
            .update({'lastName': newLastName});
        return true;
      } else {
        return false; // User not found
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Update user DOB
  Future<bool> updateDob(String userEmail, DateTime? newDob) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userEmail', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        await _firestore
            .collection('users')
            .doc(doc.id)
            .update({'dob': newDob});
        return true;
      } else {
        return false; // User not found
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Update user gender
  Future<bool> updateGender(String userEmail, String newGender) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userEmail', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        await _firestore
            .collection('users')
            .doc(doc.id)
            .update({'gender': newGender});
        return true;
      } else {
        return false; // User not found
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Update doc bio
  Future<bool> updateDocBio(String userEmail, String newBio) async {
    print('inhere as well');
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('doctors')
          .where('userEmail', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        print(doc.id);
        await _firestore.collection('doctors').doc(doc.id).update({'bio': newBio});
        return true;
      } else {
        return false; // Doc not found
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Update doc qualification
  Future<bool> updateDocQualification(String userEmail, String newQualification) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('doctors')
          .where('userEmail', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        await _firestore
            .collection('doctors')
            .doc(doc.id)
            .update({'qualification': newQualification});
        return true;
      } else {
        return false; // Doc not found
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Update doc specialty
  Future<bool> updateDocSpecialty(String userEmail, String newSpecialty) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('doctors')
          .where('userEmail', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        await _firestore
            .collection('doctors')
            .doc(doc.id)
            .update({'specialty': newSpecialty});
        return true;
      } else {
        return false; // Doc not found
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Update patient insurance ID
  Future<bool> updatePatientInsuranceId(String userEmail, int newInsuranceId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('patients')
          .where('userEmail', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        await _firestore
            .collection('patients')
            .doc(doc.id)
            .update({'insuranceId': newInsuranceId});
        return true;
      } else {
        return false; // Patient not found
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  //get assigned appointments of doctor
  Future<List<Map<String, dynamic>>> getOpenAppointmentsByDoctorEmail(String doctorEmail) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('appointments')
          .where('status', isEqualTo: 'open')
          .where('doctorEmail', isEqualTo: doctorEmail)
          .get();

      List<Map<String, dynamic>> openAppointments = [];

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        openAppointments.add(data);
      }

      return openAppointments;
    } catch (e) {
      print('Error getting open appointments by doctor email: $e');
      return [];  //returns empty list in case of error
    }
  }

  //========================================== DELETE DOCS ================================================================

  //remove available appointment from doctors document
  Future<bool> removeAvilableTime({required String doctorEmail, required Timestamp? assignedTime}) async{
    try{
      QuerySnapshot querySnapshot = await _firestore.collection('doctors').where('userEmail', isEqualTo: doctorEmail).get();
      var _docSnapshot = querySnapshot.docs.first;

      Map<String, dynamic>? doc = _docSnapshot.data() as Map<String, dynamic>?;
      print(doc);

      if(doc!.containsKey('avilableAppointments')){
        //get avilableAppointments and remove the assignedTime
        List<Timestamp> avilableAppointments = doc['avilableAppointments']?.cast<Timestamp>() ?? [];
        print(avilableAppointments);
        avilableAppointments.remove(assignedTime);

        print(avilableAppointments);

        //now upload the updated avilableAppointments
        await _firestore.collection('doctors').doc(_docSnapshot.id).update({'avilableAppointments': avilableAppointments});
        print('uploaded!');
      }
      else{
        print('Doctor has no avilable appointments');
        return false;
      }
      return true;

    } on FirebaseException catch (e) {
      print(e.message);
      return false;
    }
  }

  Future<bool> closeAppointment({required int appointmentId, required String noteMessage}) async{

    //create note
    int newNoteId = await _getMaxId(collection: 'notes', key: 'noteId') + 1;

    try{
      Map<String, dynamic>? newNoteData = {
        'note': noteMessage,
        'noteId': newNoteId,
      };

      await _firestore.collection('notes').add(newNoteData);
      // print("22");

    } on FirebaseException catch(e) {
      print(e.message);
      return false;
    }


    try{
      QuerySnapshot querySnapshot = await _firestore.collection('appointments').where('appointmentId', isEqualTo: appointmentId).get();
      var appDocId = querySnapshot.docs.first.id;
      // print('1');
      Map<String, dynamic>? appDoc = querySnapshot.docs.first.data() as Map<String, dynamic>?;
      // print('2');

      List<dynamic> notesId = appDoc?['notesId'] ?? [];
      notesId.add(newNoteId);

      // print(3);

      await _firestore.collection('appointments').doc(appDocId).update({'status' : 'close', 'notesId' : notesId});
      return true;
    } on FirebaseException catch (e) {
      print(e.message);
      return false;
    }
  }

  Future<bool> deleteNotfication({required int appointmentId}) async{
    try{
      print(appointmentId);
      QuerySnapshot querySnapshot = await _firestore.collection('notfication').where('appId', isEqualTo: appointmentId).get();

      var docId;
      if(querySnapshot.docs.isNotEmpty){
        docId = querySnapshot.docs.first.id;
      }

      await _firestore.collection('notfication').doc(docId).delete();

      return true;
    } on FirebaseException catch (e) {
      print(e.message);
      return false;
    }
  }

}
