// admin_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(QueryDocumentSnapshot<Object?> doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

    return data['role'] != 'admin' ? ListTile(
      title: Text(data['email']),
      subtitle: Text('Role: ${data['role']}'),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          _showDeleteConfirmationDialog(doc.id, data['email']);
        },
      ),
    ) : Container();
  }
  Future<void> _showDeleteConfirmationDialog(String userId, String userEmail) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete User"),
          content: Text("Are you sure you want to delete the user $userEmail?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
                _deleteUser(userId, userEmail);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
  Future<void> _deleteUser(String userId, String userEmail) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      print('User deleted successfully.');
      _showSuccessDialog(userEmail);
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
  void _showSuccessDialog(String userEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("User $userEmail deleted successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the success dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

}
