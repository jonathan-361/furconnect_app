import 'package:go_router/go_router.dart';

import 'package:furconnect/features/data/services/register_service.dart';
import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/request_service.dart';

import 'package:furconnect/features/presentation/page/test_page/test.dart';
import 'package:furconnect/features/presentation/page/login_page/login.dart';
import 'package:furconnect/features/presentation/page/register_page/register.dart';
import 'package:furconnect/features/presentation/page/register_page/choose_image.dart';
import 'package:furconnect/features/presentation/page/register_page/new_pet_user.dart';
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
import 'package:furconnect/features/presentation/page/chat_page/chat_page.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/testPage',
      builder: (context, state) => Test(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => Login(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => Register(),
    ),
    GoRoute(
      path: '/chooseImage',
      builder: (context, state) {
        final userData = state.extra as Map<String, String>;
        return ChooseImage(
          userData: userData,
          registerService: RegisterService(ApiService()),
        );
      },
    ),
    GoRoute(
      path: '/newPetUser',
      builder: (context, state) => NewPetUser(),
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
      name: 'petCardHome',
      builder: (context, state) {
        final extraData = state.extra as Map<String, dynamic>;

        return PetCardHome(
          petData: extraData['petData'] as Map<String, dynamic>,
          source: extraData['source'] as String,
          requestId: extraData['requestId'] as String,
          onDelete: extraData['onDelete'] as Function,
        );
      },
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
      builder: (context, state) => MatchPage(
          requestService:
              RequestService(ApiService(), LoginService(ApiService()))),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;

        final chatId = extra['chatId'] as String;
        final name = extra['name'] as String? ??
            'Nombre desconocido'; // Si name es null, usa un valor por defecto

        return ChatPage(chatId: chatId, name: name);
      },
    ),
  ],
);
