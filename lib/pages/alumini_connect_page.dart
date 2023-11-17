import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chatpage.dart'; // Import the dart:math library

// ...

class AlumniConnectPage extends StatelessWidget {
  final String currentUserUid;

  const AlumniConnectPage({Key? key, required this.currentUserUid}) : super(key: key);

  // Function to generate a unique chat room ID
  String generateChatRoomId(String user1, String user2) {
    // Sort the user IDs to ensure consistency
    List<String> users = [user1, user2]..sort();

    // Concatenate and return the sorted user IDs
    return "${users[0]}_${users[1]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alumni Connect'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<QueryDocumentSnapshot> alumni = snapshot.data!.docs
              .where((user) => user['uid'] != currentUserUid)
              .toList();

          return ListView.builder(
            itemCount: alumni.length,
            itemBuilder: (context, index) {
              final alumniUser = alumni[index];
              String chatRoomId = generateChatRoomId(currentUserUid, alumniUser['uid']);

              return ListTile(
                title: Text(alumniUser['displayName']),
                subtitle: Text('Graduation Year: ${alumniUser['graduationYear']}\nCurrent Job: ${alumniUser['currentJob']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(chatRoomId: chatRoomId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
