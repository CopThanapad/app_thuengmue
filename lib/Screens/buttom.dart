import 'package:flutter/material.dart';
import 'package:molten_navigationbar_flutter/molten_navigationbar_flutter.dart';
import 'package:app_thuengmue/Screens/ChatListScreen.dart';
import 'package:app_thuengmue/Screens/ProfileScreen.dart';
import 'package:app_thuengmue/Screens/Forum.dart';

class buttom extends StatefulWidget {
  @override
  _buttomState createState() => _buttomState();
}

class _buttomState extends State<buttom> {
  
  int _selectedIndex = 0;
  final screens = [
    BlogScreen(),
    ProfileScreen(userEmail: ''),
    ChatRoomListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context).copyWith(
        
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ),
      ),
      home: Scaffold(
        body: Center(
          child: screens[_selectedIndex],
        ),
        
        bottomNavigationBar: MoltenBottomNavigationBar(
          domeCircleColor: Colors.purple.shade900,
          barColor:Colors.blue.shade100 ,
          curve: Curves.decelerate,
          domeHeight: 25,
          selectedIndex: _selectedIndex,
          
          
          onTabChange: (clickedIndex) {
            setState(() {
              _selectedIndex = clickedIndex;
            });
          },
          
          tabs: [
            MoltenTab(
              icon: Icon(
                Icons.featured_play_list,
                size: 35,
                ),
              unselectedColor: Colors.purple.shade200,
              selectedColor: Colors.yellow,

              
            ),
            MoltenTab(
              icon: Icon(
                Icons.person_pin,
                size: 35,
                ),
              unselectedColor: Colors.purple.shade200,
              selectedColor: Colors.yellow,
              title: Text('Profile')
              
            ),
            MoltenTab(
              icon: Icon(
                Icons.message_sharp,
                size: 35,
                ),
              unselectedColor: Colors.purple.shade200,
              selectedColor: Colors.yellow,
            ),
          ],
        ),
      ),
    );
  }
}
