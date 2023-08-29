import 'package:app_thuengmue/Account/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context).copyWith(
        
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}