import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/widgets.dart';

class Partner extends StatefulWidget {
  @override
  _PartnerState createState() => _PartnerState();
}

class _PartnerState extends State<Partner> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController yearinController = TextEditingController();
  final TextEditingController schoolofController = TextEditingController();
  bool agreedToTerms = false;

  void addUserToFirestore() async {
    if (agreedToTerms) {
      try {
        // Get the current user's ID
        String parterId = FirebaseAuth.instance.currentUser!.uid;

        // Create a reference to the user's document in Firestore
        var userRef =
            FirebaseFirestore.instance.collection('users').doc(parterId);

        // Create a map of the partner's data
        Map<String, dynamic> partnerData = {
          'name': nameController.text,
          'birthday': birthdayController.text,
          'yearin': yearinController.text,
          'schoolof': schoolofController.text,
        };

        // Get the user's document from Firestore
        DocumentSnapshot userSnapshot = await userRef.get();

        // Check if the user's document exists in Firestore
        if (userSnapshot.exists) {
          // Get the user's data
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;

          // Add the user's email to the partner's data
          partnerData['email'] = userData['email'];
        }

        // Create a reference to the partner's document in Firestore
        var partnerRef =
            FirebaseFirestore.instance.collection('partners').doc(parterId);

        // Add the partner's data to Firestore
        await partnerRef.set(partnerData);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('บันทึกข้อมูลสำเร็จ'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } catch (error) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล'),
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
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('กรุณายอมรับข้อตกลง'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Register to",
                      style: GoogleFonts.josefinSans(
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        color: Colors.purple.shade900,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: " Partner . . .",
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
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name - Surename . . .',
                    labelStyle: GoogleFonts.josefinSans(
                      textStyle: TextStyle(
                        color: Colors.purple.shade900,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  style: GoogleFonts.josefinSans(
                    textStyle: TextStyle(
                      color: Colors.yellow.shade800,
                      fontSize: 16, // ขนาดของข้อความ
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: birthdayController,
                  decoration: InputDecoration(
                    labelText: 'Birthday . . .',
                    labelStyle: GoogleFonts.josefinSans(
                      textStyle: TextStyle(
                        color: Colors.yellow.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  style: GoogleFonts.josefinSans(
                    textStyle: TextStyle(
                      color: Colors.purple.shade900,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: yearinController,
                  decoration: InputDecoration(
                    labelText: 'School Year . . .',
                    labelStyle: GoogleFonts.josefinSans(
                      textStyle: TextStyle(
                        color: Colors.purple.shade900,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  style: GoogleFonts.josefinSans(
                    textStyle: TextStyle(
                      color: Colors.yellow.shade800,
                      fontSize: 16, // ขนาดของข้อความ
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: schoolofController,
                  decoration: InputDecoration(
                    labelText: 'Faculty . . .',
                    labelStyle: GoogleFonts.josefinSans(
                      textStyle: TextStyle(
                        color: Colors.yellow.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  style: GoogleFonts.josefinSans(
                    textStyle: TextStyle(
                      color: Colors.purple.shade900,
                      fontSize: 16, // ขนาดของข้อความ
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: agreedToTerms,
                    onChanged: (bool? newValue) {
                      setState(() {
                        agreedToTerms = newValue ?? false;
                      });
                    },
                  ),
                  Text(
                    'Accept agreement',
                    style: GoogleFonts.josefinSans(
                      // กำหนดฟอนต์ให้กับข้อความ
                      textStyle: TextStyle(
                        color: Colors.purple.shade900, // สีของข้อความ
                        fontSize: 16, // ขนาดของข้อความ
                        fontWeight: FontWeight.w700, // น้ำหนักของข้อความ
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Check if the user agreed to terms before proceeding
                  if (agreedToTerms) {
                    // Check if any of the text fields are empty
                    if (nameController.text.isEmpty ||
                        birthdayController.text.isEmpty ||
                        yearinController.text.isEmpty ||
                        schoolofController.text.isEmpty) {
                      // Show an AlertDialog if any of the fields are empty
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            "Please complete the information.",
                            style: GoogleFonts.josefinSans(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              color: Colors.purple.shade900,
                              fontSize: 18,
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
                    } else {
                      // All fields are filled, proceed with registration
                      addUserToFirestore();
                    }
                  } else {
                    // Show the AlertDialog if the user has not agreed to terms
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          "Please Accept agreement",
                          style: GoogleFonts.josefinSans(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            color: Colors.purple.shade900,
                            fontSize: 18,
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
                },
                child: Text(
                  "Register",
                  style: GoogleFonts.josefinSans(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    color: Colors.yellow.shade300,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
