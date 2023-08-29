import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_thuengmue/Screens/ChatRoom.dart';
import 'package:google_fonts/google_fonts.dart';


class ChatRoomListScreen extends StatefulWidget {
  @override
  _ChatRoomListScreenState createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen>
    with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  Map<String, dynamic>? authorData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
    setState(() {
      isLoading = true;
    });
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  String chatRoomId(String user1, String user2) {
    List<String> users = [user1, user2];
    users.sort(); 
    return "${users[0]}${users[1]}"; 
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "IN",
                  style: GoogleFonts.josefinSans(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    color: Colors.purple.shade900,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: "BOX . . .",
                  style: GoogleFonts.josefinSans(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    color: Colors.yellow.shade700,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/vet.png'), 
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.2), 
                BlendMode.dstATop, 
              ),
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('fav_blog').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final favBlogs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: favBlogs.length,
                itemBuilder: (context, index) {
                  final favBlog =
                      favBlogs[index].data() as Map<String, dynamic>;
                  final profileImageUrlBlog = favBlog['profileImageUrl_blog'];
                  final profileImageUrlUser = favBlog['profileImageUrl_user'];
                  final userId = favBlog['userId'];
                  final userIdBlog = favBlog['userId_blog'];
                  final userName = favBlog['userName'];
                  final userNameBlog = favBlog['userName_blog'];

                  return _user?.uid == userIdBlog
                      ? ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(profileImageUrlUser),
                          ),
                          title: Text(
                            userName,
                            style: GoogleFonts.josefinSans(
                              textStyle: TextStyle(
                                color: Colors.yellow.shade800,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.chat),
                            onPressed: () async {
                              DocumentSnapshot authorSnapshot = await _firestore
                                  .collection('users')
                                  .doc(userId)
                                  .get();

                              if (authorSnapshot.exists) {
                                setState(() {
                                  authorData = authorSnapshot.data()
                                      as Map<String, dynamic>;
                                });
                                String roomId = chatRoomId(
                                  _auth.currentUser!.displayName!,
                                  authorData!['name'],
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatRoom(
                                      chatRoomId: roomId,
                                      userMap: authorData!,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        )
                      : (_user?.uid == userId)
                          ? ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(profileImageUrlBlog),
                              ),
                              title: Text(
                                userNameBlog,
                                style: GoogleFonts.josefinSans(
                                  textStyle: TextStyle(
                                    color: Colors.purple.shade900,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.chat),
                                onPressed: () async {
                                  DocumentSnapshot authorSnapshot =
                                      await _firestore
                                          .collection('users')
                                          .doc(userIdBlog)
                                          .get();

                                  if (authorSnapshot.exists) {
                                    setState(() {
                                      authorData = authorSnapshot.data()
                                          as Map<String, dynamic>;
                                    });
                                    String roomId = chatRoomId(
                                      _auth.currentUser!.displayName!,
                                      authorData!['name'],
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatRoom(
                                          chatRoomId: roomId,
                                          userMap: authorData!,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            )
                          : Container(); 
                },
              );
            },
          ),
        ));
  }
}
