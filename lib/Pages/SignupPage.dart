import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart' if (dart.library.html) 'package:intl/intl_browser.dart'; //to add date field
import 'package:date_field/date_field.dart';  //to add date field
import '../Services/firestoreService.dart';

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
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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


// Patient form
class PatientForm extends StatefulWidget {
  const PatientForm({super.key});

  @override
  _PatientFormState createState() => _PatientFormState();
}

class _PatientFormState extends State<PatientForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reEnterPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _insuranceIdController = TextEditingController();
  DateTime? _dobController;
  String? _genderValue;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(
              hintText: 'First Name',
              enabledBorder: OutlineInputBorder(),
              filled: true, // Keep the border visible
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'First name cannot be empty';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(
              hintText: 'Last Name',
              enabledBorder: OutlineInputBorder(),
              filled: true, // Keep the border visible
            ),
            validator: (value) {
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          DateTimeFormField(
            decoration: InputDecoration(
              hintText: 'Date of birth',
              enabledBorder: OutlineInputBorder(),
              filled: true, // Keep the border visible
            ),
            initialValue: _dobController,
            onChanged: (DateTime? value) {
              _dobController = value;
            },
            validator: (value) {
              if (value == null) {
                return 'Date of birth is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Gender',
              enabledBorder: OutlineInputBorder(),
              filled: true, // Keep the border visible
            ),
            value: _genderValue,
            items: ['Male', 'Female', 'Other'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _genderValue = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Gender cannot be empty';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _insuranceIdController,
            decoration: InputDecoration(
              hintText: 'Insurance ID',
              enabledBorder: OutlineInputBorder(),
              filled: true, // Keep the border visible
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Insurance ID cannot be empty';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Enter Email',
              enabledBorder: OutlineInputBorder(),
              filled: true, // Keep the border visible
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: 'Enter Password',
              enabledBorder: OutlineInputBorder(),
              filled: true, // Keep the border visible
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _reEnterPasswordController,
            decoration: InputDecoration(
              hintText: 'Re-enter Password',
              enabledBorder: OutlineInputBorder(),
              filled: true, // Keep the border visible
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please re-enter your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                FirestoreService().createPatient(
                  email: _emailController.text,
                  password: _passwordController.text,
                  firstName: _firstNameController.text,
                  lastName: _lastNameController.text,
                  dob: _dobController,
                  gender: _genderValue ?? '',
                  insuranceId: int.parse(_insuranceIdController.text),
                );
                Navigator.pop(context);
                print('Patient form submitted');
              }
            },
            child: const Text('Signup as patient'),
          ),
        ],
      ),
    );
  }
}




// Doctor Form
class DoctorForm extends StatefulWidget {
  const DoctorForm({super.key});

  @override
  _DoctorFormState createState() => _DoctorFormState();
}

class _DoctorFormState extends State<DoctorForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reEnterPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  DateTime? _dobController;
  String? _genderValue;
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(
              hintText: 'First Name',
              enabledBorder: OutlineInputBorder(),
              filled: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'First name cannot be empty';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(
              hintText: 'Last Name',
              enabledBorder: OutlineInputBorder(),
              filled: true,
            ),
            validator: (value) {
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          DateTimeFormField(
            decoration: InputDecoration(
              hintText: 'Date of birth',
              enabledBorder: OutlineInputBorder(),
              filled: true,
            ),
            initialValue: _dobController,
            onChanged: (DateTime? value) {
              _dobController = value;
            },
            validator: (value) {
              if (value == null) {
                return 'Date of birth is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Gender',
              enabledBorder: OutlineInputBorder(),
              filled: true,
            ),
            value: _genderValue,
            items: ['Male', 'Female', 'Other'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _genderValue = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Gender cannot be empty';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _qualificationController,
            decoration: InputDecoration(
              hintText: 'Qualification',
              enabledBorder: OutlineInputBorder(),
              filled: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Qualification cannot be empty';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _specialtyController,
            decoration: InputDecoration(
              hintText: 'Specialty',
              enabledBorder: OutlineInputBorder(),
              filled: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Specialty cannot be empty';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Enter Email',
              enabledBorder: OutlineInputBorder(),
              filled: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: 'Enter Password',
              enabledBorder: OutlineInputBorder(),
              filled: true,
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _reEnterPasswordController,
            decoration: InputDecoration(
              hintText: 'Re-enter Password',
              enabledBorder: OutlineInputBorder(),
              filled: true,
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please re-enter your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                FirestoreService().createDoctor(
                  email: _emailController.text,
                  password: _passwordController.text,
                  firstName: _firstNameController.text,
                  lastName: _lastNameController.text,
                  dob: _dobController,
                  gender: _genderValue ?? '',
                  qualification: _qualificationController.text,
                  specialty: _specialtyController.text,
                );
                Navigator.pop(context);
                print('Doctor form submitted');
              }
            },
            child: const Text('Signup as doctor'),
          ),
        ],
      ),
    );
  }
}
