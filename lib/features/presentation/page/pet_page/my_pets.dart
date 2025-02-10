import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:go_router/go_router.dart';

import 'package:furconnect/features/data/services/pet_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/api_service.dart';

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
              context.push('/newPet').then((_) {
                _fetchPets();
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _pets.isEmpty
              ? Center(
                  child: Text('No tienes mascotas aún'),
                )
              : ListView.builder(
                  itemCount: _pets.length,
                  itemBuilder: (context, index) {
                    final pet = _pets[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      color: const Color.fromARGB(255, 255, 255, 255),
                      elevation: 5,
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 1, horizontal: 6),
                        title: Row(
                          children: [
                            // Imagen de la mascota
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _loadPetImage(pet['media'] != null &&
                                      pet['media'].isNotEmpty
                                  ? pet['media'][0].trim()
                                  : ''),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _formatWord(pet['nombre']),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                      Spacer(),
                                      Wrap(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  70, 201, 134, 60),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              _formatWord(pet['sexo']),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                color: const Color.fromARGB(
                                                    220, 79, 42, 15),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Raza:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      Text(
                                        _formatWord(pet['raza']),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Edad:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      Text(
                                        '${pet['edad']} años',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Tamaño:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      Text(
                                        _formatWord(pet['tamaño']),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Color:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      Text(
                                        _formatWord(pet['color']),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          context.push('/petCard', extra: pet).then((value) {
                            if (value == true) {
                              _fetchPets();
                              _fetchPets();
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
    );
  }

  String _formatWord(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  Widget _loadPetImage(String imageUrl) {
    String cleanImageUrl = imageUrl.trim();

    return cleanImageUrl.isEmpty
        ? Image.asset(
            'assets/images/placeholder/pet_placeholder.jpg',
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          )
        : Image.network(
            cleanImageUrl,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child; // Imagen ya cargada
              }
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ); // Mientras carga, muestra un indicador
            },
          );
  }
}
