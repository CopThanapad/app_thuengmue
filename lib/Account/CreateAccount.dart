import 'dart:io';
import 'package:app_thuengmue/Account/Methods.dart';
import 'package:app_thuengmue/Screens/buttom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _image;
  bool isLoading = false;
  bool isImagePicked = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        isImagePicked = true; // Set the flag to indicate an image is picked
      });
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/create-ac.png'), // แทนที่ด้วยพาธของรูปภาพที่คุณใช้
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.40), // แก้สีและความทึบตามต้องการ
              BlendMode.dstATop, // แก้ BlendMode ตามต้องการ
            ),
          ),
        ),
        child: isLoading
            ? Center(
                child: Container(
                  height: size.height / 20,
                  width: size.height / 20,
                  child: CircularProgressIndicator(),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height / 20,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: size.width / 0.5,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: size.height / 50,
                    ),
                    Container(
                      width: size.width / 1.8,
                      alignment: Alignment.center,
                      child: Text(
                        "Create Account",
                        style: GoogleFonts.josefinSans(
                          textStyle: Theme.of(context).textTheme.headline6,
                          color: Colors.purple.shade900,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      width: size.width / 1.3,
                      child: Text(
                        "Thung Mue Application",
                        style: GoogleFonts.josefinSans(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          color: Colors.yellow.shade800,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height / 35,
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        backgroundColor: _image == null
                            ? Colors.purple.shade400
                            : null, // Set background color for no image
                        radius: 50,
                        child: _image == null
                            ? Icon(Icons.person, size: 60)
                            : null,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      width: size.width / 1.3,
                      child: Text(
                        "Add your Profile Image",
                        style: GoogleFonts.josefinSans(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          color: Colors.purple.shade800,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Container(
                        width: size.width,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          controller: _name,
                          // ให้แสดงเป็น *** สำหรับรหัสผ่าน
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            hintText: "Name...",
                            hintStyle: TextStyle(color: Colors.yellow.shade300),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true, // ใส่สีพื้นหลัง
                            fillColor: Colors.purple.shade400, // สีพื้นหลัง
                          ),
                          style: TextStyle(
                            color: Colors.white, // เปลี่ยนสีตัวอักษร
                            fontFamily:
                                'YourFontFamily', // เปลี่ยนแบบอักษร (font family)
                            fontSize: 16, // เปลี่ยนขนาดตัวอักษร
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      width: size.width,
                      child: TextField(
                        controller: _email,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: "Email...",
                          hintStyle: TextStyle(color: Colors.yellow.shade300),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          filled: true, // ใส่สีพื้นหลัง
                          fillColor: Colors.purple.shade400, // สีพื้นหลัง
                        ),
                        style: TextStyle(
                          color: Colors.white, // เปลี่ยนสีตัวอักษร
                          fontFamily:
                              'YourFontFamily', // เปลี่ยนแบบอักษร (font family)
                          fontSize: 16, // เปลี่ยนขนาดตัวอักษร
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Container(
                        width: size.width,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          controller: _password,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            hintText: "Password..",
                            hintStyle: TextStyle(color: Colors.yellow.shade300),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Colors.purple.shade400,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'YourFontFamily',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Container(
                        width: size.width,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          controller: _confirmPassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            hintText: "Confirm Password..",
                            hintStyle: TextStyle(color: Colors.yellow.shade300),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Colors.purple.shade400,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'YourFontFamily',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height / 30,
                    ),
                    customButton(size),
                    SizedBox(
                      height: size.height / 35,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          "Login",
                          style: GoogleFonts.josefinSans(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            color: Colors.blue.shade900,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
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

  Future<void> _handleSignUp() async {
    if (!isImagePicked) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Image Require",
            style: GoogleFonts.josefinSans(
              textStyle: Theme.of(context).textTheme.displayLarge,
              color: Colors.purple.shade900,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            "Please Select image for your profile",
            style: GoogleFonts.josefinSans(
              textStyle: Theme.of(context).textTheme.displayLarge,
              color: Colors.purple.shade900,
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
      return; // Return early if no image is picked
    }

    if (_password.text != _confirmPassword.text) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Password do not MATCH",
            style: GoogleFonts.josefinSans(
              textStyle: Theme.of(context).textTheme.displayLarge,
              color: Colors.purple.shade900,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            "Please make sure the passwords match.",
            style: GoogleFonts.josefinSans(
              textStyle: Theme.of(context).textTheme.displayLarge,
              color: Colors.purple.shade900,
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
      return;
    }
    if (_name.text.isNotEmpty &&
        _email.text.isNotEmpty &&
        _password.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      final user = await createAccount(_name.text, _email.text, _password.text);

      if (user != null) {
        await _uploadImage();

        setState(() {
          isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => buttom()),
        );
        print("Account created successfully");
      } else {
        print("Failed to create account");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              "Failed to Create",
              style: GoogleFonts.josefinSans(
                textStyle: Theme.of(context).textTheme.displayLarge,
                color: Colors.purple.shade900,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            content: Text(
              "There are duplicate emails in the system.",
              style: GoogleFonts.josefinSans(
                textStyle: Theme.of(context).textTheme.displayLarge,
                color: Colors.yellow.shade500,
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
        setState(() {
          isLoading = false;
        });
      }
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Fill in the missing information",
          style: GoogleFonts.josefinSans(
            textStyle: Theme.of(context).textTheme.displayLarge,
            color: Colors.purple.shade900,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          "Please add all information.",
          style: GoogleFonts.josefinSans(
            textStyle: Theme.of(context).textTheme.displayLarge,
            color: Colors.yellow.shade500,
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
    return;
  }

  Widget customButton(Size size) {
    return GestureDetector(
      onTap: _handleSignUp,
      child: Container(
        height: 46,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.purple.shade400,
        ),
        alignment: Alignment.center,
        child: Text(
          "Sign Up",
          style: GoogleFonts.josefinSans(
            textStyle: Theme.of(context).textTheme.displayLarge,
            color: Colors.yellow.shade300,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget field(
      Size size, String hintText, IconData icon, TextEditingController cont) {
    return Container(
      height: size.height / 15,
      width: size.width / 1.2,
      child: TextField(
        controller: cont,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
