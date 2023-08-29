import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/widgets.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _contentController = TextEditingController();

  
  void _updateProfileImageUrl(String userId, String newProfileImageUrl) {
    FirebaseFirestore.instance
        .collection('blog_articles')
        .where('userId', isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((articleDoc) {
        articleDoc.reference.update({
          'profileImageUrl': newProfileImageUrl, 
        });
      });
    });
  }

  List<String> _selectedPickupTypes = [];
  String _selectedCarTypes = '';
  String _selectedtime = '';

  @override
  void initState() {
    super.initState();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDocumentRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      userDocumentRef.snapshots().listen((snapshot) {
        String newProfileImageUrl = snapshot['profileImageUrl'] ?? '';
        _updateProfileImageUrl(user.uid, newProfileImageUrl);
      });
    }
  }

  void _postArticle() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (_selectedPickupTypes.isEmpty ||
          _selectedCarTypes.isEmpty ||
          _selectedtime.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Missing Information',
                style: GoogleFonts.josefinSans(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  color: Colors.purple.shade900,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: Text(
                'Need pick-up type,vehicle type and delivery time',
                style: GoogleFonts.josefinSans(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  color: Colors.purple.shade900,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); 
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String profileImageUrl = userSnapshot['profileImageUrl'] ?? '';
      String content = _contentController.text.isEmpty
          ? 'If interested, please message me.'
          : _contentController.text;

      await FirebaseFirestore.instance.collection('blog_articles').add({
        'userId': user.uid,
        'content': content,
        'userName': user.displayName,
        'profileImageUrl': profileImageUrl,
        'time_delivery': _selectedtime,
        'pickuptypes': _selectedPickupTypes,
        'cartypes': _selectedCarTypes,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Colors.purple.shade900), 
            onPressed: () {
              Navigator.of(context).pop(); 
            },
          ),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "PostPick-Up ",
                  style: GoogleFonts.josefinSans(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    color: Colors.purple.shade900,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: "ITEM . . .",
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
                  'assets/burger.png'), 
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.25),
                BlendMode.dstATop, 
              ),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pick-Up type',
                        style: GoogleFonts.josefinSans(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          color: Colors.yellow.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      CheckboxListTile(
                        title: Text(
                          'Food',
                          style: GoogleFonts.josefinSans(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            color: Colors.purple.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        value: _selectedPickupTypes.contains('Food'),
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              _selectedPickupTypes.add('Food');
                            } else {
                              _selectedPickupTypes.remove('Food');
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(
                          'Drink',
                          style: GoogleFonts.josefinSans(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            color: Colors.purple.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        value: _selectedPickupTypes.contains('Drink'),
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              _selectedPickupTypes.add('Drink');
                            } else {
                              _selectedPickupTypes.remove('Drink');
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(
                          'Package',
                          style: GoogleFonts.josefinSans(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            color: Colors.purple.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        value: _selectedPickupTypes.contains('Package'),
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              _selectedPickupTypes.add('Package');
                            } else {
                              _selectedPickupTypes.remove('Package');
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  //cartype
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle type',
                        style: GoogleFonts.josefinSans(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          color: Colors.yellow.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'Walk',
                          style: GoogleFonts.josefinSans(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            color: Colors.purple.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        value: 'Walk',
                        groupValue: _selectedCarTypes,
                        onChanged: (value) {
                          setState(() {
                            _selectedCarTypes = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'Motorcycle',
                          style: GoogleFonts.josefinSans(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            color: Colors.purple.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        value: 'Motorcycle',
                        groupValue: _selectedCarTypes,
                        onChanged: (value) {
                          setState(() {
                            _selectedCarTypes = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'Car',
                          style: GoogleFonts.josefinSans(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            color: Colors.purple.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        value: 'Car',
                        groupValue: _selectedCarTypes,
                        onChanged: (value) {
                          setState(() {
                            _selectedCarTypes = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  //time_dali
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery time',
                        style: GoogleFonts.josefinSans(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          color: Colors.yellow.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'at least 10 minutes',
                          style: GoogleFonts.josefinSans(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            color: Colors.purple.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        value: 'At least 10 Minutes',
                        groupValue: _selectedtime,
                        onChanged: (value) {
                          setState(() {
                            _selectedtime = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'at least 30 minutes',
                          style: GoogleFonts.josefinSans(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            color: Colors.purple.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        value: 'At least 30 Minutes',
                        groupValue: _selectedtime,
                        onChanged: (value) {
                          setState(() {
                            _selectedtime = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'at most 30 minutes',
                          style: GoogleFonts.josefinSans(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            color: Colors.purple.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        value: 'At most 30 Minutes',
                        groupValue: _selectedtime,
                        onChanged: (value) {
                          setState(() {
                            _selectedtime = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: 'Add more details . . .',
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
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _postArticle();
                    },
                    child: Container(
                      height: 36,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.purple.shade400,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "PostThungMue",
                        style: GoogleFonts.josefinSans(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          color: Colors.yellow.shade300,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
