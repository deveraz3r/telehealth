import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebaseAuth/auth.dart';



class HomePage extends StatelessWidget {
  //HomePage({Key? key}) : super(key: key);
  HomePage({super.key});

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _userUid() {
    return Text(user?.uid ?? 'User email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
        onPressed: signOut,
        child: const Text("SignOut"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("firebase Auth"),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userUid(),
            _signOutButton(),
          ],
        ),
      ),
    );
  }
}

