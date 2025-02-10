import 'package:go_router/go_router.dart';

import 'package:furconnect/features/presentation/page/login_page/login.dart';
import 'package:furconnect/features/presentation/page/register_page/register.dart';
import 'package:furconnect/features/presentation/page/home_page/home.dart';
import 'package:furconnect/features/presentation/page/botton_navigation_bar/botton_navigation_bar.dart';
import 'package:furconnect/features/presentation/page/pet_page/my_pets.dart';
import 'package:furconnect/features/presentation/widget/pet_card.dart';
import 'package:furconnect/features/presentation/page/pet_page/new_pet.dart';

//import 'package:furconnect/features/presentation/page/pet_page/my_pets-beta.dart';
//import 'package:furconnect/features/presentation/widget/pet_card_beta.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => Login(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => Register(),
    ),
    GoRoute(
      path: '/navigationBar',
      builder: (context, state) => BottonNavigationBarPage(),
    ),
    GoRoute(
      path: '/myPets',
      builder: (context, state) => MyPets(),
    ),
    GoRoute(
      path: '/petCard',
      builder: (context, state) => PetCard(),
    ),
    GoRoute(
      path: '/newPet',
      builder: (context, state) => NewPet(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomePage(),
    ),
  ],
);
