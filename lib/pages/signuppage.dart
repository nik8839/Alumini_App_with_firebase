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
  bool shouldClearFields = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Clear text fields when the page is reloaded
    if(shouldClearFields) {
      _displayNameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _graduationYearController.clear();
      _currentJobController.clear();
      shouldClearFields=false;
    }
  }
  String? _displayNameError;
  String? _emailError;
  String? _passwordError;
  String? _graduationYearError;
  String? _currentJobError;
  String? _validateName(String value) {
    if (value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateGraduationYear(String value) {
    if (isGraduationYearVisible && value.isEmpty) {
      return 'Year of graduation is required';
    }
    return null;
  }

  String? _validateCurrentJob(String value) {
    if (isCurrentJobVisible && value.isEmpty) {
      return 'Current job role is required';
    }
    return null;
  }
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
      String errorMessage = 'Error during signup. Please try again.';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak. Please choose a stronger password.';
            break;
          case 'email-already-in-use':
            errorMessage = 'The account already exists for that email. Please sign in or use a different email.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid. Please enter a valid email address.';
            break;
        // Add more cases as needed based on FirebaseAuthException codes
        }
      }

      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Clear text fields when back button is pressed
        _displayNameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _graduationYearController.clear();
        _currentJobController.clear();
        return true; // Allow back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Sign up',style: TextStyle(fontSize: 30,color: Colors.deepPurple),)),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(40.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60.0),
              border: Border.all(
                color: Colors.deepPurple,
                width: 5.0,
              ),
            ),
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
                    onChanged: (value) {
                      // Check for validation only if the user has started typing
                      if (_displayNameController.text.isNotEmpty) {
                        setState(() {
                          // Update the error message based on the validation result
                          _displayNameError = _validateName(_displayNameController.text);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Name',
                      errorText: _displayNameError, // Use a variable to store the error message
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    controller: _emailController,
                    onChanged: (value) {
                      if (_emailController.text.isNotEmpty) {
                        setState(() {
                          _emailError = _validateEmail(_emailController.text);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: _emailError,
                    ),
                  ),

                  SizedBox(height: 8.0),
                  TextField(
                    controller: _passwordController,
                    onChanged: (value) {
                      if (_passwordController.text.isNotEmpty) {
                        setState(() {
                          _passwordError = _validatePassword(_passwordController.text);
                        });
                      }
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: _passwordError,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Graduation year field
                  Visibility(
                    visible: isGraduationYearVisible,
                    child: TextField(
                      controller: _graduationYearController,
                      onChanged: (value) {
                        if (_graduationYearController.text.isNotEmpty) {
                          setState(() {
                            _graduationYearError = _validateGraduationYear(_graduationYearController.text);
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Year of graduation',
                        errorText: _graduationYearError,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Current job field
                  Visibility(
                    visible: isCurrentJobVisible,
                    child: TextField(
                      controller: _currentJobController,
                      onChanged: (value) {
                        if (_currentJobController.text.isNotEmpty) {
                          setState(() {
                            _currentJobError = _validateCurrentJob(_currentJobController.text);
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Current JobRole',
                        errorText: _currentJobError,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  // Sign-up button
          ElevatedButton(
            onPressed: () {
              if (_validateName(_displayNameController.text) == null &&
                  _validateEmail(_emailController.text) == null &&
                  _validatePassword(_passwordController.text) == null &&
                  _validateGraduationYear(_graduationYearController.text) == null &&
                  _validateCurrentJob(_currentJobController.text) == null) {
                _signUp();
              }
            },
            child: Text('Sign Up'),
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

// UserModel class (replace it with your actual user model)

