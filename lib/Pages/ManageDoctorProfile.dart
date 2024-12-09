import 'package:flutter/material.dart';
import 'package:telehelth/Services/firestoreService.dart';

class ManageDoctor extends StatefulWidget {
  final String _userEmail;

  // Constructor
  const ManageDoctor(this._userEmail, {super.key});

  @override
  _ManageDoctorState createState() => _ManageDoctorState(_userEmail);
}

class _ManageDoctorState extends State<ManageDoctor> {
  final String _userEmail;

  _ManageDoctorState(this._userEmail);

  late TextEditingController _controllerFirstName;
  late TextEditingController _controllerLastName;
  late TextEditingController _controllerBio;
  late TextEditingController _controllerQualification;
  late TextEditingController _controllerDob;
  late TextEditingController _controllerGender;
  late TextEditingController _controllerSpecality;

  late ValueNotifier<String> _firstNameNotifier;
  late ValueNotifier<String> _lastNameNotifier;
  late ValueNotifier<String> _bioNotifier;
  late ValueNotifier<String> _qualificationNotifier;
  late ValueNotifier<String> _dobNotifier;
  late ValueNotifier<String> _genderNotifier;
  late ValueNotifier<String> _specalityNotifier;

  @override
  void initState() {
    super.initState();
    _controllerFirstName = TextEditingController();
    _controllerLastName = TextEditingController();
    _controllerBio = TextEditingController();
    _controllerQualification = TextEditingController();
    _controllerDob = TextEditingController();
    _controllerGender = TextEditingController();
    _controllerSpecality = TextEditingController();

    _firstNameNotifier = ValueNotifier(_controllerFirstName.text);
    _lastNameNotifier = ValueNotifier(_controllerLastName.text);
    _bioNotifier = ValueNotifier(_controllerBio.text);
    _qualificationNotifier = ValueNotifier(_controllerQualification.text);
    _dobNotifier = ValueNotifier(_controllerDob.text);
    _genderNotifier = ValueNotifier(_controllerGender.text);
    _specalityNotifier = ValueNotifier(_controllerSpecality.text);
  }

  @override
  void dispose() {
    _controllerFirstName.dispose();
    _controllerLastName.dispose();
    _controllerBio.dispose();
    _controllerQualification.dispose();
    _controllerDob.dispose();
    _controllerGender.dispose();
    _controllerSpecality.dispose();

    _firstNameNotifier.dispose();
    _lastNameNotifier.dispose();
    _bioNotifier.dispose();
    _qualificationNotifier.dispose();
    _dobNotifier.dispose();
    _genderNotifier.dispose();
    _specalityNotifier.dispose();
    super.dispose();
  }

  Future<void> _editField(TextEditingController controller, ValueNotifier<String> notifier, String label, {DateTime? dob}) async {
    final TextEditingController editController = TextEditingController(text: controller.text);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: label),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  controller.text = editController.text;
                  notifier.value = editController.text;
                });
                if (label == 'First Name') {
                  FirestoreService().updateFirstName(_userEmail, controller.text);
                } else if (label == 'Last Name') {
                  FirestoreService().updateLastName(_userEmail, controller.text);
                } else if (label == 'Bio') {
                  FirestoreService().updateDocBio(_userEmail, controller.text);
                } else if (label == 'Qualification') {
                  FirestoreService().updateDocQualification(_userEmail, controller.text);
                } else if (label == 'Specality') {
                  FirestoreService().updateDocSpecialty(_userEmail, controller.text);
                } else if (label == 'Date of Birth') {
                  FirestoreService().updateDob(_userEmail, dob);
                } else if (label == 'Gender') {
                  FirestoreService().updateGender(_userEmail, controller.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
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
        title: const Text('Manage Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildEditableField(_controllerFirstName, _firstNameNotifier, 'First Name'),
            const SizedBox(height: 20),
            _buildEditableField(_controllerLastName, _lastNameNotifier, 'Last Name'),
            const SizedBox(height: 20),
            _buildEditableField(_controllerBio, _bioNotifier, 'Bio', maxLines: null),
            const SizedBox(height: 20),
            _buildEditableField(_controllerQualification, _qualificationNotifier, 'Qualification'),
            const SizedBox(height: 20),
            _buildEditableField(_controllerSpecality, _specalityNotifier, 'Specality'),
            const SizedBox(height: 20),
            _buildEditableDateField(_controllerDob, _dobNotifier, 'Date of Birth'),
            const SizedBox(height: 20),
            _buildEditableField(_controllerGender, _genderNotifier, 'Gender'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(TextEditingController controller, ValueNotifier<String> notifier, String label, {int? maxLines}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ValueListenableBuilder<String>(
            valueListenable: notifier,
            builder: (context, value, child) {
              return TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: label,
                  border: const OutlineInputBorder(),
                ),
                maxLines: maxLines,
                enabled: false,
              );
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            _editField(controller, notifier, label);
          },
        ),
      ],
    );
  }

  Widget _buildEditableDateField(TextEditingController controller, ValueNotifier<String> notifier, String label) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ValueListenableBuilder<String>(
            valueListenable: notifier,
            builder: (context, value, child) {
              return TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: label,
                  border: const OutlineInputBorder(),
                ),
                enabled: false,
              );
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                controller.text = pickedDate.toString();
                notifier.value = pickedDate.toString();
              });
            }
          },
        ),
      ],
    );
  }
}
