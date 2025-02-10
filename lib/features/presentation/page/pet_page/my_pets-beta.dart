import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:go_router/go_router.dart';

import 'package:furconnect/features/data/services/pet_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/api_service.dart';

class MyPetPage extends StatefulWidget {
  @override
  _MyPetPageState createState() => _MyPetPageState();
}

class _MyPetPageState extends State<MyPetPage> {
  final PetService _petService =
      PetService(ApiService(), LoginService(ApiService()));
  List<dynamic> _pets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchPets();
  }

  Future<void> fetchPets() async {
    try {
      final loginService = LoginService(ApiService());
      await loginService.loadToken();
      final token = loginService.authToken;
      if (token == null) {
        setState(() {
          _error = "No se encontró un token válido. Inicia sesión nuevamente.";
          _isLoading = false;
        });
        return;
      }
      final decodedToken = JwtDecoder.decode(token);
      final userId = decodedToken['id'];

      final pets = await _petService.getPetsByOwner(userId);

      if (pets == null || pets.isEmpty) {
        setState(() {
          _error = 'Sin mascotas';
          _isLoading = false;
        });
      } else {
        setState(() {
          _pets = pets;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        if (e.response?.statusCode == 404) {
          _error = 'No se encontraron mascotas para este usuario.';
        } else {
          _error = "Ocurrió un error al obtener las mascotas: ${e.message}";
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Error inesperado: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  void _onPetDeleted(bool isDeleted) {
    if (isDeleted) {
      // Vuelve a cargar los registros
      fetchPets();
    }
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
              context.push('/newPet');
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  itemCount: _pets.length,
                  itemBuilder: (context, index) {
                    final pet = _pets[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: _buildImage(pet),
                        title: Text(pet['nombre'] ?? 'Desconocido'),
                        subtitle: Text("${pet['raza']} - ${pet['tipo']}"),
                        trailing: Text("Edad: ${pet['edad']} años"),
                        onTap: () async {
                          final isDeleted =
                              await context.push<bool>('/petCard', extra: pet);
                          _onPetDeleted(isDeleted ?? false);
                        },
                      ),
                    );
                  },
                ),
    );
  }

  // Placeholder
  Widget _buildPlaceholder() {
    return Image.asset(
      'assets/images/placeholder/pet_placeholder.jpg',
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }

  // Uso del placeholder
  Widget _buildImage(dynamic pet) {
    String imageUrl = pet['media'] != null && pet['media'].isNotEmpty
        ? _getValidImageUrl(pet['media'][0])
        : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: SizedBox(
          width: 50,
          height: 50,
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildPlaceholder();
                  },
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return _buildPlaceholder();
                  },
                )
              : _buildPlaceholder()),
    );
  }

  String _getValidImageUrl(String imageUrl) {
    final trimmedUrl = imageUrl.trim();
    final uri = Uri.tryParse(trimmedUrl);
    if (uri != null && uri.isAbsolute) {
      return trimmedUrl;
    } else {
      return '';
    }
  }
}
