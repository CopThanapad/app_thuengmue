import 'package:app_thuengmue/Account/Methods.dart';
import 'package:app_thuengmue/Screens/PartnerScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/widgets.dart';

Future<bool> checkIfEmailExistsInPartner(String email) async {
  var partnerQuery = await FirebaseFirestore.instance
      .collection('partners')
      .where('email', isEqualTo: email)
      .get();
  return partnerQuery.docs.isEmpty;
}

class ProfileScreen extends StatefulWidget {
  final String userEmail;
  ProfileScreen({required this.userEmail});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      // Upload the image and update the profile image URL in Firestore
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      return;
    }

    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${_auth.currentUser!.uid}.jpg');

      await ref.putFile(_image!);

      String downloadURL = await ref.getDownloadURL();
      print("Image uploaded. Download URL: $downloadURL");

      // Update the user's document in Firestore with the profile image URL
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        "profileImageUrl": downloadURL,
      });
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          title: Text(
            "Profile",
            style: GoogleFonts.josefinSans(
              textStyle: Theme.of(context).textTheme.displayLarge,
              color: Colors.purple.shade900,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Colors.yellow.shade800,
                ),
                onPressed: () => logOut(context))
          ],
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/eatperson.png'), // แทนที่ด้วยพาธของรูปภาพที่คุณใช้
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.2), // แก้สีและความทึบตามต้องการ
                BlendMode.dstATop, // แก้ BlendMode ตามต้องการ
              ),
            ),
          ),
          child: FutureBuilder<DocumentSnapshot>(
            future: _firestore
                .collection("users")
                .doc(_auth.currentUser!.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                Map<String, dynamic> userData =
                    snapshot.data!.data() as Map<String, dynamic>;
                String profileImageUrl = userData['profileImageUrl'] ?? '';

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            backgroundImage: profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : null,
                            radius: 50,
                            child: profileImageUrl.isEmpty
                                ? Icon(Icons.person,
                                    size:
                                        60) // Default icon when no image is available
                                : null,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 45),
                            Row(
                              children: [
                                Icon(Icons.person, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  "Name: ${userData['name']}",
                                  style: GoogleFonts.josefinSans(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    color: Colors.purple.shade900,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Divider(), // เพิ่มเส้นแบ่งชั้นบรรทัด
                            Row(
                              children: [
                                Icon(Icons.email, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  "Email: ${userData['email']}",
                                  style: GoogleFonts.josefinSans(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    color: Colors.purple.shade900,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Divider(), // เพิ่มเส้นแบ่งชั้นบรรทัด
                            Row(
                              children: [
                                Icon(Icons.card_travel, size: 24),
                                SizedBox(
                                  width: 8,
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    User? user =
                                        FirebaseAuth.instance.currentUser;

                                    if (user != null) {
                                      bool emailExistsInPartner =
                                          await checkIfEmailExistsInPartner(
                                              widget.userEmail);

                                      if (emailExistsInPartner) {
                                        DocumentSnapshot userSnapshot =
                                            await FirebaseFirestore.instance
                                                .collection('partners')
                                                .doc(user.uid)
                                                .get();

                                        if (userSnapshot.exists) {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(
                                                "You have already registered as a Partners in the system.",
                                                style: GoogleFonts.josefinSans(
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .displayLarge,
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
                                                  child: Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          // User is not registered as a partner, proceed with registration
                                          await FirebaseFirestore.instance
                                              .collection('partners')
                                              .doc(user.uid)
                                              .set({
                                            'email': widget.userEmail,
                                          });

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Partner()),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.yellow
                                        .shade700, // กำหนดสีพื้นหลังของปุ่ม
                                    onPrimary:
                                        Colors.white, // กำหนดสีของตัวอักษร
                                  ),
                                  child: Text(
                                    "Become a Partner",
                                    style: GoogleFonts.josefinSans(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/id-card.png'), // แทนที่ด้วยพาธของรูปภาพที่คุณใช้
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Center(child: Text("Error loading user data"));
              }
            },
          ),
        ));
  }
}
