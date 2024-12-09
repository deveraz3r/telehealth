import 'package:flutter/material.dart';
import 'package:telehelth/Services/firestoreService.dart';

class ManagePatient extends StatefulWidget {
  final String _userEmail;

  // Constructor
  const ManagePatient(this._userEmail, {super.key});

  @override
  _ManagePatientState createState() => _ManagePatientState(_userEmail);
}

class _ManagePatientState extends State<ManagePatient> {
  final String _userEmail;

  _ManagePatientState(this._userEmail);

  late TextEditingController _controllerFirstName;
  late TextEditingController _controllerLastName;
  late TextEditingController _controllerDob;
  late TextEditingController _controllerGender;
  late TextEditingController _controllerInsuranceId;

  @override
  void initState() {
    super.initState();
    _controllerFirstName = TextEditingController();
    _controllerLastName = TextEditingController();
    _controllerDob = TextEditingController();
    _controllerGender = TextEditingController();
    _controllerInsuranceId = TextEditingController();
  }

  @override
  void dispose() {
    _controllerFirstName.dispose();
    _controllerLastName.dispose();
    _controllerDob.dispose();
    _controllerGender.dispose();
    _controllerInsuranceId.dispose();
    super.dispose();
  }

  Future<void> _editField(TextEditingController controller, String label, {DateTime? dob}) async {
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
                });
                if (label == 'First Name') {
                  FirestoreService().updateFirstName(_userEmail, controller.text);
                } else if (label == 'Last Name') {
                  FirestoreService().updateLastName(_userEmail, controller.text);
                } else if (label == 'Insurance ID') {
                  FirestoreService().updatePatientInsuranceId(_userEmail, int.parse(controller.text));
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
            _buildEditableField(_controllerFirstName, 'First Name'),
            const SizedBox(height: 20),
            _buildEditableField(_controllerLastName, 'Last Name'),
            const SizedBox(height: 20),
            _buildEditableField(_controllerInsuranceId, 'Insurance ID'),
            const SizedBox(height: 20),
            _buildEditableDateField(_controllerDob, 'Date of Birth'),
            const SizedBox(height: 20),
            _buildEditableField(_controllerGender, 'Gender'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(TextEditingController controller, String label, {int? maxLines}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: label,
              border: const OutlineInputBorder(),
            ),
            maxLines: maxLines,
            enabled: false,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            _editField(controller, label);
          },
        ),
      ],
    );
  }

  Widget _buildEditableDateField(TextEditingController controller, String label) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: label,
              border: const OutlineInputBorder(),
            ),
            enabled: false,
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
              });
            }
          },
        ),
      ],
    );
  }
}
