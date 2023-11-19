import 'package:appdev/models/user_model.dart';
import 'package:appdev/pages/adminpage.dart';
import 'package:appdev/pages/alumini_connect_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final TextEditingController _roleController = TextEditingController();

  String selectedRole = 'alumini'; // Default to alumni
  bool isGraduationYearVisible = true;
  bool isCurrentJobVisible = true;

  void _handleRoleChange(String value) {
    setState(() {
      selectedRole = value;

      // Update visibility based on the selected role
      isGraduationYearVisible = selectedRole == 'alumini';
      isCurrentJobVisible = selectedRole == 'alumini';
    });
  }

  Future<void> _signUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Create a user model
      // Use the selectedRole for additional logic as needed
      // Here, we're just storing it in the role field of the user model
      // Modify this part according to your user model structure
      // You can also add more fields based on the role if needed
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: _emailController.text,
        displayName: _displayNameController.text,
        graduationYear: _graduationYearController.text,
        currentJob: _currentJobController.text,
        role: selectedRole,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': newUser.uid,
        'email': newUser.email,
        'displayName': newUser.displayName,
        'graduationYear': newUser.graduationYear,
        'currentJob': newUser.currentJob,
        'role': newUser.role,
      });
      if (newUser != null) {
        if (newUser.role == 'alumini') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlumniConnectPage(currentUserUid: newUser.uid),
            ),
          );
        } else if (newUser.role == 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPage(),
            ),
          );
        }
        // Handle other roles if needed
      }

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Radio buttons for selecting the role
              Row(
                children: [
                  Radio(
                    value: 'alumini',
                    groupValue: selectedRole,
                    onChanged: (String? value) {
                      _handleRoleChange(value!);
                    },
                  ),
                  Text('alumini'),
                  Radio(
                    value: 'admin',
                    groupValue: selectedRole,
                    onChanged: (String? value) {
                      _handleRoleChange(value!);
                    },
                  ),
                  Text('admin'),
                ],
              ),
              SizedBox(height: 16.0),
              // Text fields for user input
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              SizedBox(height: 8.0),
              // Graduation year field
              Visibility(
                visible: isGraduationYearVisible,
                child: TextField(
                  controller: _graduationYearController,
                  decoration: InputDecoration(labelText: 'Year of graduation'),
                ),
              ),
              SizedBox(height: 8.0),
              // Current job field
              Visibility(
                visible: isCurrentJobVisible,
                child: TextField(
                  controller: _currentJobController,
                  decoration: InputDecoration(labelText: 'Current JobRole'),
                ),
              ),
              SizedBox(height: 16.0),
              // Sign-up button
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// UserModel class (replace it with your actual user model)

