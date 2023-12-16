import 'package:appdev/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserDetailsPage extends StatefulWidget {
   UserModel currentUser;

   EditUserDetailsPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _EditUserDetailsPageState createState() => _EditUserDetailsPageState();
}

class _EditUserDetailsPageState extends State<EditUserDetailsPage> {
  late TextEditingController displayNameController;
  late TextEditingController graduationYearController;
  late TextEditingController currentJobController;

  @override
  void initState() {
    super.initState();

    // Ensure that currentUser is not null before accessing its properties
    if (widget.currentUser != null) {
      displayNameController = TextEditingController(text: widget.currentUser.displayName);
      graduationYearController = TextEditingController(text: widget.currentUser.graduationYear);
      currentJobController = TextEditingController(text: widget.currentUser.currentJob);
    } else {
      // Handle the case where currentUser is null (optional, based on your app's logic)
      displayNameController = TextEditingController();
      graduationYearController = TextEditingController();
      currentJobController = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    displayNameController = TextEditingController(text: widget.currentUser.displayName);
    graduationYearController = TextEditingController(text: widget.currentUser.graduationYear);
    currentJobController = TextEditingController(text: widget.currentUser.currentJob);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: displayNameController,
              decoration: InputDecoration(labelText: 'Display Name'),
            ),
            TextField(
              controller: graduationYearController,
              decoration: InputDecoration(labelText: 'Graduation Year'),
            ),
            TextField(
              controller: currentJobController,
              decoration: InputDecoration(labelText: 'Current Job'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                UserModel updatedUser = UserModel(
                  uid: widget.currentUser.uid,
                  email: widget.currentUser.email,
                  displayName: displayNameController.text,
                  graduationYear: graduationYearController.text,
                  currentJob: currentJobController.text,
                  role: widget.currentUser.role,
                );

                // Update the user details in Firestore
                await _updateUserDetails(updatedUser);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserDetails(UserModel updatedUser) async {
    try {
      // Get the reference to the user's document in Firestore
      var userRef = FirebaseFirestore.instance.collection('users').doc(updatedUser.uid);

      // Perform the update operation
      await userRef.update({
        'displayName': updatedUser.displayName,
        'graduationYear': updatedUser.graduationYear,
        'currentJob': updatedUser.currentJob,
      });

      // Show a success message dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('User details updated successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Pop the page and pass the updated user to the previous screen
                  Navigator.pop(context, updatedUser);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle errors, e.g., show an error message
      print('Error updating user details: $e');
    }
  }

  @override
  void dispose() {
    displayNameController.dispose();
    graduationYearController.dispose();
    currentJobController.dispose();
    super.dispose();
  }
}
