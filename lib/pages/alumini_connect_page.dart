import 'dart:math';

import 'package:appdev/models/user_model.dart';
import 'package:appdev/pages/settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'chatpage.dart';

class AlumniConnectPage extends StatefulWidget {
  final String currentUserUid;


  AlumniConnectPage({Key? key, required this.currentUserUid}) : super(key: key);

  @override
  State<AlumniConnectPage> createState() => _AlumniConnectPageState();
}

class _AlumniConnectPageState extends State<AlumniConnectPage> {
 late UserModel currentUser;

  @override

  void initState() {
    super.initState();
    // Initialize currentUser here, fetch data from Firebase Firestore
    _fetchUserData();
  }

 Future<void> _fetchUserData() async {
   try {
     var userDoc = await FirebaseFirestore.instance
         .collection('users')
         .doc(widget.currentUserUid)
         .get();

     if (userDoc.exists) {
       setState(() {
         currentUser = UserModel(
           uid: userDoc['uid'],
           email: userDoc['email'],
           displayName: userDoc['displayName'],
           graduationYear: userDoc['graduationYear'],
           currentJob: userDoc['currentJob'],
           role: userDoc['role'],
         );
       });
     } else {
       // Handle the case where the document does not exist
       print('User document does not exist');
     }
   } catch (e) {
     // Handle errors, e.g., show an error message
     print('Error fetching user data: $e');
   }
 }

 int _currentIndex = 0;
  TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> filteredAlumni = [];
  late AsyncSnapshot<QuerySnapshot> snapshot;

  String generateChatRoomId(String user1, String user2) {
    List<String> users = [user1, user2]..sort();
    return "${users[0]}_${users[1]}";
  }

  Future<void> _browseImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Handle the selected image (upload or process as needed)
      print('Selected image path: ${pickedFile.path}');
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Alumni'),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(hintText: 'Enter alumni name'),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performSearch();
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _performSearch() {
    String searchQuery = _searchController.text.toLowerCase();
    filteredAlumni = snapshot.data!.docs
        .where((user) =>
    user['uid'] != widget.currentUserUid &&
        user['role'] != 'admin' &&
        user['displayName'].toLowerCase().contains(searchQuery))
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Alumni')),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Handle navigation to different screens based on index
            switch (_currentIndex) {
              case 0:
              // Navigate to home screen or perform any action
                break;
              case 1:
              // Trigger search functionality when Search icon is tapped
                _showSearchDialog(context);
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditUserDetailsPage(currentUser: currentUser),
                  ),
                );
                break;
              default:
              // Navigate to home screen or perform any default action
                break;
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      drawer: Drawer(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(
              widget.currentUserUid).get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('User not found');
            }

            // Replace these fields with your actual Firestore document fields
            String displayName = snapshot.data!['displayName'] ?? 'Your Name';
            String graduationYear = snapshot.data!['graduationYear'] ??
                'Your Graduation Year';
            String currentJob = snapshot.data!['currentJob'] ??
                'Your currentJob';
            String userEmail = snapshot.data!['email'] ?? 'Your gmailid';

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MYSELF',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection(
                                'users').doc(widget.currentUserUid).get(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator(
                                  color: Colors.white,
                                );
                              }

                              if (snapshot.hasError) {
                                return Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                );
                              }

                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return Text(
                                  'User not found',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                );
                              }

                              String displayName = snapshot
                                  .data!['displayName'] ?? 'Your Name';

                              return Text(
                                'Welcome, $displayName!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      // Circular option for photo upload
                      GestureDetector(
                        onTap: _browseImageFromGallery,
                        child: Container(
                          margin: EdgeInsets.all(8.0),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            color: Colors
                                .white, // You can set a background color or use an icon for the circular option
                          ),
                          child: Icon(
                            Icons.add_a_photo,
                            // You can replace this with your photo upload icon
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text('Name: $displayName'),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(
                        'Email ID: $userEmail'), // Assuming you have userEmail defined somewhere
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text('Graduation Year: $graduationYear'),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text('Job Role: $currentJob'),
                  ),
                ),
                // Add more Container widgets for other user details
              ],
            );
          },
        ),
      ),
      body: _currentIndex == 1 ? _buildSearchScreen() : _buildAlumniList(),
    );
  }

  Widget _buildSearchScreen() {
    return ListView.builder(
      itemCount: filteredAlumni.length,
      itemBuilder: (context, index) {
        final alumniUser = filteredAlumni[index];
        String chatRoomId = generateChatRoomId(
            widget.currentUserUid, alumniUser['uid']);

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
  }

  Widget _buildAlumniList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
        if (!asyncSnapshot.hasData) {
          return CircularProgressIndicator();
        }

        snapshot = asyncSnapshot; // Save the snapshot for later use

        List<QueryDocumentSnapshot> alumni = asyncSnapshot.data!.docs
            .where((user) =>
        user['uid'] != widget.currentUserUid && user['role'] != 'admin')
            .toList();

        return ListView.builder(
          itemCount: alumni.length,
          itemBuilder: (context, index) {
            final alumniUser = alumni[index];
            String chatRoomId = generateChatRoomId(
                widget.currentUserUid, alumniUser['uid']);

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
    );
  }
}

