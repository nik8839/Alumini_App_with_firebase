// login_page.dart


import 'package:appdev/pages/adminpage.dart';
import 'package:appdev/pages/signuppage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'alumini_connect_page.dart';

class LoginPage extends StatefulWidget {
  //double screenHeight = MediaQuery.of(context).size.height;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool shouldClearFields = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Clear text fields only when shouldClearFields is true
    if (shouldClearFields) {
      _emailController.clear();
      _passwordController.clear();
    }

    // Reset the flag

    shouldClearFields = false;
  }
  final String backgroundImageUrl = 'https://img.freepik.com/free-vector/mobile-login-concept-illustration_114360-135.jpg?w=740&t=st=1700802790~exp=1700803390~hmac=052c452fa07bd03517a09631a17ab5aa0144a17a5fdc402db5ca79fe66f2d5e9';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _emailError;
  String? _passwordError;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!userSnapshot.exists) {
        print('Document does not exist for uid: ${userCredential.user!.uid}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User does not exist. Please check your credentials or sign up.'),
            backgroundColor: Colors.red,
          ),
        );
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
    } catch (e) {
      print('Error during login: $e');
      String errorMessage = 'Invalid credentials';
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email address';
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
    // Get the screen height
    double screenHeight = MediaQuery.of(context).size.height;

    // Calculate the desired height as a percentage of the screen height
    double imageHeight = screenHeight * 0.3; // Adjust the percentage as needed

    return WillPopScope(
      onWillPop: () async {
        // Clear text fields when back button is pressed
        _emailController.clear();
        _passwordController.clear();
        return true; // Allow back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Login',style: TextStyle(fontSize: 30,color: Colors.deepPurple),)),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Image.network(
                backgroundImageUrl,
               fit: BoxFit.cover,
                height: imageHeight,
                width: MediaQuery.of(context).size.width,
              ),
              SizedBox(height: 20,),
              Center(
                child: Container(
                  // margin: EdgeInsets.only(top: 20),
                  //color: Colors.blueGrey
                  padding: EdgeInsets.all(40.0),
                  //height: 500,
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(60.0),
                    border: Border.all(
                      color: Colors.deepPurple,
                      width: 5.0,

                    ),
                    color: Colors.white24,

                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Welcome Back!',
                            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextField(
                          controller: _emailController,
                          onChanged: (value) {
                            setState(() {
                              _emailError = _emailController.text.isNotEmpty &&
                                  !RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(_emailController.text)
                                  ? 'Enter a valid email'
                                  : null;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Email',
                            errorText: _emailError,
                          ),
                        ),

                        TextField(
                          controller: _passwordController,
                          onChanged: (value) {
                            setState(() {
                              _passwordError = _passwordController.text.isNotEmpty &&
                                  _passwordController.text.length < 6
                                  ? 'Password must be at least 6 characters'
                                  : null;
                            });
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            errorText: _passwordError,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () async {
                            await _login(context);
                          },
                          child: Text('Login',style: TextStyle(color: Colors.deepPurple),),
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

              ),

            ],

              ),
        ),
      ),
    );
  }

  }




