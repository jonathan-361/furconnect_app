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
      return decodedToken['id'];
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
        if (mounted) {
          setState(() {
            _pets = petsData;
            hasPets = petsData.isNotEmpty;
            isLoading = false;
          });
        }
      } catch (err) {
        if (mounted) {
          setState(() {
            hasPets = err.toString().contains("No tienes mascotas todavía")
                ? false
                : hasPets;
            isLoading = false;
          });
        }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Color(0xFF894936),
        elevation: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Mascotas",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : hasPets
                    ? ListView.builder(
                        itemCount: _pets.length,
                        itemBuilder: (context, index) {
                          return ItemPet(
                            petData: _pets[index],
                            navigateTo: '/petCard',
                            onPetDeleted: () {
                              _fetchPets();
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
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/newPet').then((value) {
                    _fetchPets();
                  });
                },
                icon: Icon(Icons.add,
                    size: 20, color: Color.fromARGB(255, 235, 234, 232)),
                label: Text(
                  "Agregar",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 236, 236, 236),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC48253),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
