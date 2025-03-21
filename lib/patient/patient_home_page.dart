// import 'package:ehealthsolution/chat_screen.dart';
import 'package:ehealthsolution/doctor/doctor_list_page.dart';
import 'package:ehealthsolution/patient/chat_list_page.dart';
import 'package:ehealthsolution/patient/chatbot.dart';
import 'package:ehealthsolution/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _children = [
    DoctorListPage(),
    ChatListPage(),
    ProfilePage(),
    ChatBot(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
  bool? exitApp = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Exit App?',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: const Text(
        'Are you sure you want to exit the app?',
        style: TextStyle(fontSize: 16),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            SystemNavigator.pop(); // Exit the app
          },
          child: const Text('Yes', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );

  return exitApp == true; // Ensure it returns true or false
}


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _children[_selectedIndex],
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              unselectedItemColor: Colors.grey.shade500,
              selectedItemColor: const Color(0xff0064FA),
              iconSize: 28,
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              elevation: 10,
              showUnselectedLabels: true,
              selectedFontSize: 14,
              unselectedFontSize: 12,
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: _selectedIndex == 0 ? const EdgeInsets.all(6) : EdgeInsets.zero,
                    decoration: _selectedIndex == 0
                        ? BoxDecoration(
                            color: const Color(0xff0064FA).withOpacity(0.15),
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: const Icon(Icons.home_filled),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: _selectedIndex == 1 ? const EdgeInsets.all(6) : EdgeInsets.zero,
                    decoration: _selectedIndex == 1
                        ? BoxDecoration(
                            color: const Color(0xff0064FA).withOpacity(0.15),
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: const Icon(Icons.chat),
                  ),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: _selectedIndex == 2 ? const EdgeInsets.all(6) : EdgeInsets.zero,
                    decoration: _selectedIndex == 2
                        ? BoxDecoration(
                            color: const Color(0xff0064FA).withOpacity(0.15),
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: const Icon(Icons.person),
                  ),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
  icon: AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    padding: _selectedIndex == 3 ? const EdgeInsets.all(6) : EdgeInsets.zero,
    decoration: _selectedIndex == 3
        ? BoxDecoration(
            color: const Color(0xff0064FA).withOpacity(0.15),
            shape: BoxShape.circle,
          )
        : null,
    child: const Icon(Icons.chat_bubble_outline),
  ),
  label: 'Ask me',
),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
