import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:go_router/go_router.dart';

import 'package:furconnect/features/data/services/pet_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/presentation/widget/item_pet.dart';

class MyPets extends StatefulWidget {
  const MyPets({super.key});

  @override
  State<MyPets> createState() => _MyPetsState();
}

class _MyPetsState extends State<MyPets> {
  final PetService _petService =
      PetService(ApiService(), LoginService(ApiService()));
  List<dynamic> _pets = [];
  bool isLoading = true;

  Future<String?> _getUserId() async {
    try {
      final loginService = LoginService(ApiService());
      await loginService.loadToken();
      final token = loginService.authToken;

      if (token == null) {
        return null;
      }

      final decodedToken = JwtDecoder.decode(token);
      final userId = decodedToken['id'];

      return userId;
    } catch (e) {
      print('Error al decodificar el token: $e');
      return null;
    }
  }

  Future<void> _fetchPets() async {
    final userId = await _getUserId();
    if (userId != null) {
      try {
        final petsData = await _petService.getPetsByOwner(userId);
        setState(() {
          _pets = petsData;
          isLoading = false;
        });
      } catch (err) {
        setState(() {
          isLoading = false;
        });
        print('Error al obtener las mascotas: $err');
      }
    } else {
      print('Usuario no autenticado o token inválido');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Mascotas"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              context.push('/newPet').then((value) {
                _fetchPets();
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _pets.length,
              itemBuilder: (context, index) {
                return ItemPet(
                  petData: _pets[index],
                  navigateTo: '/petCard',
                  onPetDeleted: () {
                    _fetchPets(); // Recargar la lista de mascotas
                  },
                );
              },
            ),
    );
  }
}
