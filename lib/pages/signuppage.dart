// signup_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import 'alumini_connect_page.dart';
import 'chatpage.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _graduationYearController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _currentJobController = TextEditingController();


  void _signUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: _emailController.text,
        displayName: _displayNameController.text,
        graduationYear: _graduationYearController.text,
        currentJob: _currentJobController.text,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': newUser.uid,
        'email': newUser.email,
        'displayName': newUser.displayName,
        'graduationYear': newUser.graduationYear,
        'currentJob': newUser.currentJob,
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlumniConnectPage(currentUserUid: newUser!.uid)
        ),
      );
      // Navigate to the next screen or perform any other action upon successful signup
    } catch (e) {
      print('Error during signup: $e');
      // Handle signup errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),

            TextField(
              controller: _graduationYearController,
              decoration: InputDecoration(labelText: 'Year of graduation'),
            ),
            TextField(
              controller: _currentJobController,
              decoration: InputDecoration(labelText: 'Current Role'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
