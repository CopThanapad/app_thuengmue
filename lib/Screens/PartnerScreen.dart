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
     
        String parterId = FirebaseAuth.instance.currentUser!.uid;

        
        var userRef =
            FirebaseFirestore.instance.collection('users').doc(parterId);


        Map<String, dynamic> partnerData = {
          'name': nameController.text,
          'birthday': birthdayController.text,
          'yearin': yearinController.text,
          'schoolof': schoolofController.text,
        };

       
        DocumentSnapshot userSnapshot = await userRef.get();

        
        if (userSnapshot.exists) {
          
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;

         
          partnerData['email'] = userData['email'];
        }

     
        var partnerRef =
            FirebaseFirestore.instance.collection('partners').doc(parterId);

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
                        color: Colors.purple.shade900, 
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  
                  if (agreedToTerms) {
                    
                    if (nameController.text.isEmpty ||
                        birthdayController.text.isEmpty ||
                        yearinController.text.isEmpty ||
                        schoolofController.text.isEmpty) {
                    
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
                    
                      addUserToFirestore();
                    }
                  } else {
                   
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
