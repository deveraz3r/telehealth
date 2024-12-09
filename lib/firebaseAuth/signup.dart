import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart' if (dart.library.html) 'package:intl/intl_browser.dart'; //to add date feild
import 'package:date_field/date_field.dart';  //to add date feild

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await findSystemLocale();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}
@override

class _SignupPageState extends State<SignupPage> {
  String? _signupType;

  @override
  void initState() {
    super.initState();
    _signupType = 'patient'; // Set the default value to 'patient'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Wrap the content in a SingleChildScrollView
          child: Column(
            children: [
              // Radio Button Group
              ListTile(
                title: const Text("Select Signup Type"),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Doctor'),
                        value: 'doctor',
                        groupValue: _signupType,
                        onChanged: (String? value) {
                          setState(() {
                            _signupType = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Patient'),
                        value: 'patient',
                        groupValue: _signupType,
                        onChanged: (String? value) {
                          setState(() {
                            _signupType = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Conditional Form Rendering
              if (_signupType == 'doctor')
                const DoctorForm()
              else if (_signupType == 'patient')
                const PatientForm()
            ],
          ),
        ),
      ),
    );
  }
}


//Patient form
class PatientForm extends StatefulWidget {
  const PatientForm({super.key});

  @override
  _PatientFormState createState() => _PatientFormState();
}

class _PatientFormState extends State<PatientForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  DateTime? _dobController;
  final _genderController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    // _dobController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Cannot be empty';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Cannot be empty';
              }
              return null;
            },
          ),
          DateTimeFormField(
            decoration: const InputDecoration(
              labelText: 'Date of birth',
            ),
            firstDate: DateTime.now().add(const Duration(days: 10)),
            lastDate: DateTime.now().add(const Duration(days: 40)),
            initialPickerDateTime: DateTime.now().add(const Duration(days: 20)),
            onChanged: (DateTime? value) {
              _dobController = value;
            },
          ),
          TextFormField(
            controller: _genderController,
            decoration: const InputDecoration(
              labelText: 'Gender',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Cannot be empty';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Implement form submission logic here
                print('Patient form submitted');
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}


//Doctor Form
class DoctorForm extends StatefulWidget {
  const DoctorForm({super.key});

  @override
  _DoctorFormState createState() => _DoctorFormState();
}

class _DoctorFormState extends State<DoctorForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'First Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Last Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Age',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              } else if (int.tryParse(value) == null) {
                return 'Please enter a valid age';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Gender',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your gender';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Qualification',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your qualification';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Specialty',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your specialty';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Perform action on successful validation
                print('Form submitted');
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}