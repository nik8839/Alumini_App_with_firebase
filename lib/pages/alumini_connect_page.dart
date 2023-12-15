import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chatpage.dart';

class AlumniConnectPage extends StatelessWidget {
  final String currentUserUid;

  const AlumniConnectPage({Key? key, required this.currentUserUid}) : super(key: key);

  String generateChatRoomId(String user1, String user2) {
    List<String> users = [user1, user2]..sort();
    return "${users[0]}_${users[1]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Alumni ')),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<QueryDocumentSnapshot> alumni = snapshot.data!.docs
              .where((user) => user['uid'] != currentUserUid && user['role'] != 'admin')
              .toList();

          return ListView.builder(
            itemCount: alumni.length,
            itemBuilder: (context, index) {
              final alumniUser = alumni[index];
              String chatRoomId = generateChatRoomId(currentUserUid, alumniUser['uid']);

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    alumniUser['displayName'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  subtitle: Text(
                    'Graduation Year: ${alumniUser['graduationYear']}\nCurrent Job: ${alumniUser['currentJob']}',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(chatRoomId: chatRoomId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
