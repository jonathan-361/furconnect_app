import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/pet_service.dart';

class PetCard extends StatelessWidget {
  const PetCard({super.key});

  Future<void> _deletePet(
      Map<String, dynamic> pet, BuildContext context) async {
    final loginService = LoginService(ApiService());
    await loginService.loadToken();
    final token = loginService.authToken;
    final String? errorMessage;
    if (token == null) {
      errorMessage = 'No se encontro un token válido.';
      print(errorMessage);
      return;
    }
    final petService = PetService(ApiService(), loginService);

    final petId = pet['_id'];
    print('ID Mascota: $petId');

    try {
      await petService.deletePet(petId);
      print("Mascota eliminada exitosamente.");
    } catch (e) {
      errorMessage = "Error al eliminar la mascota: $e";
      print(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = GoRouter.of(context).state.extra as Map<String, dynamic>?;

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
            child: Text('No hay datos de la mascota seleccionada')),
      );
    }

    String vacunasDisplay = '';
    if (pet['vacunas'] is List) {
      vacunasDisplay = (pet['vacunas'] as List).join(', ');
    } else {
      vacunasDisplay = pet['vacunas'] ?? 'No tiene';
    }

    String petImageUrl = pet['media'] != null && pet['media'].isNotEmpty
        ? pet['media'][0].trim()
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Mascota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _loadPetImage(petImageUrl),
            ),
            SizedBox(height: 8),
            Text(
              _formatWord(pet['nombre']),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Raza: '),
                Text(_formatWord(pet['raza'])),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Tipo: '),
                Text(_formatWord(pet['tipo'])),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Color: '),
                Text(_formatWord(pet['color'])),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Tamaño: '),
                Text(_formatWord(pet['tamaño'])),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Edad: '),
                Text('${pet['edad']}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Sexo: '),
                Text(_formatWord(pet['sexo'])),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Pedigree: '),
                Text(_formatWord(pet['pedigree'] ? 'Sí' : 'No')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Vacunas: '),
                Text(_formatWord(vacunasDisplay)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Historial de cruzas: '),
                Text('${pet['historia_cruzas'] ?? 'No hay'}'),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 211, 194, 40),
                foregroundColor: Colors.black,
              ),
              child: Text("Editar mascota"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showDeleteConfirmationDialog(context, pet);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 177, 24, 24),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              ),
              child: Text("Eliminar mascota"),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  String _formatWord(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, Map<String, dynamic> pet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar esta mascota?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                context.pop();
                try {
                  _deletePet(pet, context);
                  context.pop(true);
                } catch (e) {
                  print("Error al eliminar la mascota: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _loadPetImage(String imageUrl) {
    String cleanImageUrl = imageUrl.trim();

    return cleanImageUrl.isEmpty
        ? Image.asset(
            'assets/images/placeholder/pet_placeholder.jpg',
            width: 200,
            fit: BoxFit.fitWidth,
          )
        : Image.network(
            cleanImageUrl,
            width: 200,
            fit: BoxFit.fitWidth,
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
