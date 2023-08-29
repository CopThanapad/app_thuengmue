import 'package:app_thuengmue/Account/PostScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_thuengmue/Screens/ChatRoom.dart';
import 'package:google_fonts/google_fonts.dart';


class BlogScreen extends StatefulWidget {
  @override
  _BlogScreenState createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? authorData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  String chatRoomId(String user1, String user2) {
    List<String> users = [user1, user2];
    users.sort(); // เรียงลำดับ users ตามลำดับอักขระเพื่อให้เหมือนกันทุกครั้ง
    return "${users[0]}${users[1]}"; // สร้าง chatRoomId จาก users
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "ThungMue",
                  style: GoogleFonts.josefinSans(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    color: Colors.purple.shade900,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: " Post . . .",
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
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              color: Colors.yellow.shade800,
              iconSize: 50,
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  // Check if the current user is a partner
                  DocumentSnapshot userSnapshot = await FirebaseFirestore
                      .instance
                      .collection('partners')
                      .doc(user.uid)
                      .get();

                  if (userSnapshot.exists) {
                    // User is a partner, allow navigation to PostScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PostScreen()),
                    );
                  } else {
                    // User is not a partner, show a dialog or perform any action you prefer
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          "You are not Partner",
                          style: GoogleFonts.josefinSans(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            color: Colors.purple.shade900,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Ok",
                              style: GoogleFonts.josefinSans(
                                textStyle:
                                    Theme.of(context).textTheme.displayLarge,
                                color: Colors.yellow.shade300,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/delivery-man.png'), // แทนที่ด้วยพาธของรูปภาพที่คุณใช้
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.20), // แก้สีและความทึบตามต้องการ
                BlendMode.dstATop, // แก้ BlendMode ตามต้องการ
              ),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('blog_articles')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> articleData =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;
                          bool isAuthor =
                              _auth.currentUser!.uid == articleData['userId'];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            color: Colors.white70,
                            child: GestureDetector(
                              onLongPress: () {
                                // Show an alert dialog with the content of the article
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Show more DETAIL',
                                      style: GoogleFonts.josefinSans(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        color: Colors.purple.shade900,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    content: Text(
                                      articleData['content'] ??
                                          'No content available',
                                      style: GoogleFonts.josefinSans(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        color: Colors.yellow.shade500,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          articleData['profileImageUrl'] ?? ''),
                                    ),
                                    title: Text(
                                      articleData['userName'] ?? 'No User ID',
                                      style: GoogleFonts.josefinSans(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        color: Colors.purple.shade900,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          articleData['time_delivery'] ??
                                              'No Content',
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          articleData['cartypes'] ??
                                              'No cartypes',
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(articleData['pickuptypes']
                                                ?.join(', ') ??
                                            'No pickuptypes'),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () async {
                                                if (isAuthor) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: Text(
                                                      "Confirm to DELETE.",
                                                      style: GoogleFonts
                                                          .josefinSans(
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .displayLarge,
                                                        color: Colors
                                                            .purple.shade900,
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                      content: Text(
                                                      "Make sure if you want to delete",
                                                      style: GoogleFonts
                                                          .josefinSans(
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .displayLarge,
                                                        color: Colors.purple,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Close the dialog
                                                          },
                                                          child: Text("Cancel"),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Close the dialog

                                                            String articleId =
                                                                snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                    .id;
                                                            await _firestore
                                                                .collection(
                                                                    'blog_articles')
                                                                .doc(articleId)
                                                                .delete();
                                                          },
                                                          child: Text("Delete"),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                       title: Text(
                                                      "You can't DELETE.",
                                                      style: GoogleFonts
                                                          .josefinSans(
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .displayLarge,
                                                        color: Colors
                                                            .purple.shade900,
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                      content: Text(
                                                      "You are not the OWNER of the post.",
                                                      style: GoogleFonts
                                                          .josefinSans(
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .displayLarge,
                                                        color: Colors
                                                            .purple.shade900,
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                      actions: [
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Close the dialog
                                                          },
                                                          child: Text("OK"),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.chat),
                                              onPressed: () async {
                                                DocumentSnapshot
                                                    authorSnapshot =
                                                    await _firestore
                                                        .collection('users')
                                                        .doc(articleData[
                                                            'userId'])
                                                        .get();

                                                if (authorSnapshot.exists) {
                                                  setState(() {
                                                    authorData = authorSnapshot
                                                            .data()
                                                        as Map<String, dynamic>;
                                                  });

                                                  String currentUserId = _auth
                                                      .currentUser!
                                                      .displayName!;
                                                  String selectedUserId =
                                                      authorData!['name'];

                                                  if (currentUserId !=
                                                      selectedUserId) {
                                                    String roomId = chatRoomId(
                                                        currentUserId,
                                                        selectedUserId);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            ChatRoom(
                                                          chatRoomId: roomId,
                                                          userMap: authorData!,
                                                        ),
                                                      ),
                                                    );
                                                    User? user = FirebaseAuth
                                                        .instance.currentUser;
                                                    if (user != null) {
                                                      DocumentSnapshot
                                                          selectedArticleSnapshot =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'blog_articles')
                                                              .doc(snapshot
                                                                  .data!
                                                                  .docs[index]
                                                                  .id)
                                                              .get();

                                                      if (selectedArticleSnapshot
                                                          .exists) {
                                                        Map<String, dynamic>
                                                            selectedArticleData =
                                                            selectedArticleSnapshot
                                                                    .data()
                                                                as Map<String,
                                                                    dynamic>;

                                                        QuerySnapshot
                                                            existingFavoriteSnapshot =
                                                            await _firestore
                                                                .collection(
                                                                    'fav_blog')
                                                                .where('userId',
                                                                    isEqualTo:
                                                                        user
                                                                            .uid)
                                                                .where(
                                                                    'userId_blog',
                                                                    isEqualTo:
                                                                        selectedArticleData[
                                                                            'userId'])
                                                                .get();

                                                        if (existingFavoriteSnapshot
                                                            .docs.isEmpty) {
                                                          DocumentSnapshot
                                                              userSnapshot =
                                                              await _firestore
                                                                  .collection(
                                                                      'users')
                                                                  .doc(user.uid)
                                                                  .get();
                                                          String
                                                              profileimageurlUser =
                                                              userSnapshot[
                                                                      'profileImageUrl'] ??
                                                                  '';

                                                          Map<String, dynamic>
                                                              newData = {
                                                            'userId': user.uid,
                                                            'userName': user
                                                                .displayName,
                                                            'userId_blog':
                                                                selectedArticleData[
                                                                    'userId'],
                                                            'profileImageUrl_user':
                                                                profileimageurlUser,
                                                            'profileImageUrl_blog':
                                                                selectedArticleData[
                                                                    'profileImageUrl'],
                                                            'userName_blog':
                                                                selectedArticleData[
                                                                    'userName'],
                                                            'email': user.email,
                                                            'blog_articlesid':
                                                                selectedArticleSnapshot
                                                                    .id,
                                                            'title':
                                                                selectedArticleData[
                                                                    'title'],
                                                            'content':
                                                                selectedArticleData[
                                                                    'content'],
                                                            'timestamp':
                                                                selectedArticleData[
                                                                    'timestamp'],
                                                          };

                                                          await _firestore
                                                              .collection(
                                                                  'fav_blog')
                                                              .add(newData);
                                                        } else {
                                                          print(
                                                              'Article already exists in fav_blog');
                                                        }
                                                      }
                                                    }
                                                    // Rest of your code for adding the article to favorites
                                                  } else {
                                                    // Display a message to the user indicating they cannot chat with themselves
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: Text(
                                                          "Can't CHAT",
                                                          style: GoogleFonts
                                                              .josefinSans(
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displayLarge,
                                                            color: Colors.purple
                                                                .shade900,
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        content: Text(
                                                          "You cannot initiate a chat with yourself.",
                                                          style: GoogleFonts
                                                              .josefinSans(
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displayLarge,
                                                            color: Colors.purple
                                                                .shade500,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        actions: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text("OK"),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(child: Text('No articles available'));
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
