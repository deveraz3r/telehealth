import 'package:flutter/material.dart';
import 'package:telehelth/Services/firestoreService.dart';
import 'SignupPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Login Page'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding( // Add padding here
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/TeleHealth logo.png'),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      enabledBorder: OutlineInputBorder(),
                      filled: true, // Keep the border visible
                    ),
                    controller: _controllerEmail,
                  ),
                  Container(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Password',
                      enabledBorder: OutlineInputBorder(),
                      filled: true, // Keep the border visible
                    ),
                    obscureText: true,
                    controller: _controllerPassword,
                  ),
                  Container(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        FirestoreService().signInWithEmailAndPassword(
                            email: _controllerEmail.text,
                            password: _controllerPassword.text
                        );
                      },
                      child: const Text('Login')
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to signup screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupPage()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
