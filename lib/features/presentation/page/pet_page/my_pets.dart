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
  bool hasPets = true;

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
          hasPets = petsData.isNotEmpty;
          isLoading = false;
        });
      } catch (err) {
        if (err.toString().contains("No tienes mascotas todavía")) {
          setState(() {
            hasPets = false;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('Error al obtener las mascotas: $err');
        }
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
      backgroundColor: const Color.fromARGB(255, 238, 238, 238),
      appBar: AppBar(
        title: Text("Mis Mascotas"),
        backgroundColor: const Color.fromARGB(255, 238, 238, 238),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 20,
          fontFamily: 'RobotoR',
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: const Color.fromARGB(255, 158, 89, 9),
              size: 35,
            ),
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
          : hasPets
              ? ListView.builder(
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
                )
              : Center(
                  child: Text(
                    "No tienes mascota aún",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
    );
  }
}
