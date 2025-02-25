import 'package:go_router/go_router.dart';

import 'package:furconnect/features/presentation/page/login_page/login.dart';
import 'package:furconnect/features/presentation/page/register_page/register.dart';
import 'package:furconnect/features/presentation/page/home_page/home.dart';
import 'package:furconnect/features/presentation/page/botton_navigation_bar/botton_navigation_bar.dart';
import 'package:furconnect/features/presentation/page/pet_page/my_pets.dart';
import 'package:furconnect/features/presentation/widget/pet_card.dart';
import 'package:furconnect/features/presentation/page/pet_page/new_pet.dart';
import 'package:furconnect/features/presentation/page/pet_page/edit_pet.dart';
import 'package:furconnect/features/presentation/page/suscription/suscription.dart';
import 'package:furconnect/features/presentation/page/user_page/edit_user.dart';
import 'package:furconnect/features/presentation/page/match_page/match.dart';
import 'package:furconnect/features/presentation/page/profile_page/profile.dart';
import 'package:furconnect/features/presentation/widget/pet_card_home.dart';

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
      name: 'petCard',
      builder: (context, state) =>
          PetCard(petData: state.extra as Map<String, dynamic>),
    ),
    GoRoute(
      path: '/newPet',
      builder: (context, state) => NewPet(),
    ),
    GoRoute(
      path: '/editPet',
      builder: (context, state) => EditPet(),
    ),
    GoRoute(
      path: '/furconnectPlus',
      builder: (context, state) => SubscriptionScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/petCardHome',
      builder: (context, state) => PetCardHome(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => Profile(),
    ),
    GoRoute(
      path: '/editUser',
      builder: (context, state) => EditUser(),
    ),
    GoRoute(
      path: '/match',
      builder: (context, state) => MatchPage(),
    ),
  ],
);
