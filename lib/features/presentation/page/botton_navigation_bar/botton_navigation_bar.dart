import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:furconnect/features/presentation/page/home_page/home.dart';
import 'package:furconnect/features/presentation/page/chat_page/menu_chat.dart';
import 'package:furconnect/features/presentation/page/pet_page/my_pets.dart';
import 'package:furconnect/features/presentation/page/match_page/match.dart';
import 'package:furconnect/features/presentation/widget/pet_card_home.dart';

class BottonNavigationBarPage extends StatefulWidget {
  const BottonNavigationBarPage({super.key});

  @override
  State<BottonNavigationBarPage> createState() =>
      _BottonNavigationBarPageState();
}

class _BottonNavigationBarPageState extends State<BottonNavigationBarPage> {
  int _actualPage = 0;

  final List<Widget> _pages = [
    HomePage(),
    PetCardHome(),
    MyPets(),
    MenuChat(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_actualPage],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _actualPage,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 4) {
            context
                .push('/furconnectPlus'); // Navega a la pantalla de suscripción
          } else {
            setState(() {
              _actualPage = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border), // Ícono de Match
            label: 'Match',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Mascotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Plus',
          ),
        ],
      ),
    );
  }
}
