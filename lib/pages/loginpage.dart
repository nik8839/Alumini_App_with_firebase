// login_page.dart
import 'package:appdev/pages/adminpage.dart';
import 'package:appdev/pages/signuppage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import 'alumini_connect_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _graduationYearController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _currentJobController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  Future<void> _login() async {
    try {

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        //graduationYear:_graduationYearController.text,
      );

      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!userSnapshot.exists) {
        print('Document does not exist for uid: ${userCredential.user!.uid}');
        // Handle the case where the document doesn't exist
        return;
      }
      UserModel loggedInUser = UserModel(
        uid: userCredential.user!.uid,
        email: userSnapshot['email'],
        displayName: userSnapshot['displayName'],
        graduationYear: userSnapshot['graduationYear'],
        currentJob: userSnapshot['currentJob'],
        role: userSnapshot['role'],
      );

      if (loggedInUser != null) {
        if (loggedInUser.role == 'alumini') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlumniConnectPage(currentUserUid: loggedInUser.uid),
            ),
          );
        } else if (loggedInUser.role == 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPage(),
            ),
          );
        }
        // Handle other roles if needed
      }
    }catch (e) {
      print('Error during login: $e');
      // Handle login errors here
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                decoration: InputDecoration(labelText: 'Current JobRole'),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _roleController,
                decoration: InputDecoration(labelText: 'Role'), // Add this line
              ),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              SizedBox(height: 8.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                child: Text('Don\'t have an account? Sign up here.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

