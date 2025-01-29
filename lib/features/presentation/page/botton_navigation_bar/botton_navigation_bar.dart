import 'package:flutter/material.dart';

import 'package:furconnect/features/presentation/page/home_page/home.dart';
import 'package:furconnect/features/presentation/page/search_page/search.dart';
import 'package:furconnect/features/presentation/page/chat_page/menu_chat.dart';
import 'package:furconnect/features/presentation/page/profile_page/profile.dart';

class BottonNavigationBarPage extends StatefulWidget {
  const BottonNavigationBarPage({super.key});

  @override
  State<BottonNavigationBarPage> createState() =>
      _BottonNavigationBarPageState();
}

class _BottonNavigationBarPageState extends State<BottonNavigationBarPage> {
  int _actualPage = 0;

  List<Widget> _pages = [
    HomePage(),
    Search(),
    MenuChat(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_actualPage],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _actualPage = index;
          });
        },
        currentIndex: _actualPage,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '',
          ),
        ],
      ),
    );
  }
}
