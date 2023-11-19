// chat_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String chatRoomId;

  const ChatPage({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('chat_rooms').doc(widget.chatRoomId).collection('messages').add({
        'text': _messageController.text,
        'senderUid': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('chat_rooms')
                  .doc(widget.chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                List<QueryDocumentSnapshot> messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];

                for (QueryDocumentSnapshot message in messages) {
                  final messageText = message['text'];
                  final messageSenderUid = message['senderUid'];
                  final isSentMessage = messageSenderUid == _auth.currentUser!.uid;

                  messageWidgets.add(
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: isSentMessage
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blue, // You can customize the color
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    messageText,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Text('You'), // Display your name for sent messages
                              ],
                            ),
                          ),
                        ],
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey, // You can customize the color
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(messageText),
                                ),
                                FutureBuilder(
                                  future: _firestore.collection('users').doc(messageSenderUid).get(),
                                  builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                    if (!userSnapshot.hasData || userSnapshot.data == null) {
                                      return CircularProgressIndicator();
                                    }
                                    final displayName = userSnapshot.data!['displayName'];
                                    return Text(displayName);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }



                return ListView(
                  children: messageWidgets,
                );

              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
