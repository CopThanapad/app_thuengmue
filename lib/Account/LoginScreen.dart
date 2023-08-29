import 'package:app_thuengmue/Account/CreateAccount.dart';
import 'package:app_thuengmue/Account/Methods.dart';
import 'package:flutter/material.dart';
import 'package:app_thuengmue/Screens/buttom.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/widgets.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: isLoading
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
                          SystemNavigator.pop();
                        }),
                  ),
                  SizedBox(
                    height: size.height / 50,
                  ),
                  Container(
                    width: size.width / 1.8,
                    alignment: Alignment.center,
                    child: Text(
                      "Thung Mue",
                      style: GoogleFonts.josefinSans(
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        color: Colors.purple.shade900,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    width: size.width / 1.3,
                    child: Text(
                      "Pick up service for Wu Students",
                      style: GoogleFonts.josefinSans(
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        color: Colors.yellow.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 25,
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
                        obscureText: true, // ให้แสดงเป็น *** สำหรับรหัสผ่าน
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          hintText: "Password...",
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

                  SizedBox(
                    height: size.height / 10,
                  ),
                  customButton(size),
                  SizedBox(
                    height: size.height / 70,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CreateAccount())),
                    child: Text(
                      "Sign up",
                      style: GoogleFonts.josefinSans(
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        color: Colors.blue.shade900,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 25,
                  ),
// ใช้งาน DecorationImage ใน Container เพื่อแสดงรูปภาพ
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/deliver.png'), // แทนที่ด้วยพาธของรูปภาพที่คุณใช้
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget customButton(Size size) {
    return GestureDetector(
      onTap: () {
        if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
          setState(() {
            isLoading = true;
          });
          logIn(_email.text, _password.text).then((user) {
            if (user != null) {
              print("ล๊อคอินสำเร็จ");
              setState(() {
                isLoading = false;
              });
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => buttom()));
            } else {
              print("Failed to Login");
              setState(() {
                isLoading = false;
              });

              // Show an alert dialog for login failure
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Failed to Login'),
                  content: Text('Please Check your Email or Password'),
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
          });
        } else {
          print("กรอกรหัสผ่านหรืออีเมลให้ถูกต้อง");
        }
      },
      child: Container(
        height: 46,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.purple.shade400,
        ),
        alignment: Alignment.center,
        child: Text(
          "Login",
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
