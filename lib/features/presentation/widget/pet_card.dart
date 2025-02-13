import 'package:flutter/material.dart';
import 'package:furconnect/features/presentation/page/login_page/login.dart';
import 'package:go_router/go_router.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/pet_service.dart';

class PetCard extends StatelessWidget {
  final Map<String, dynamic> petData;

  const PetCard({super.key, required this.petData});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final loginService = LoginService(apiService);
    final petService = PetService(apiService, loginService);

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
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _formatWord(petData['nombre']),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                Wrap(
                  children: [
                    Icon(
                      petData['sexo'].toLowerCase() == "macho"
                          ? Icons.male
                          : Icons.female,
                      color: const Color.fromARGB(220, 79, 42, 15),
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '${_formatWord(petData['tipo'])} - ',
                ),
                Text(_formatWord(petData['raza'])),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    width: 70,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 214, 214, 214),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Edad',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${int.tryParse(petData['edad']?.toString() ?? '0')?.toString() ?? '0'} años',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    width: 70,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 214, 214, 214),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Color',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          _formatWord(petData['color']),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    width: 70,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 214, 214, 214),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Pedigree',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${petData['pedigree'] == true ? "Sí" : "No"}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Tamaño: '),
                Text(_formatWord(petData['tamaño'])),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vacunas: '),
                Expanded(
                  child: Text(
                    petData['vacunas'].join(', '),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Historial de cruzas: '),
                Expanded(
                  child: Text(
                    petData['historial_cruzas'].isNotEmpty
                        ? petData['historial_cruzas'].join(', ')
                        : 'No se ha cruzado',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 15,
                  ),
                ),
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
                try {
                  petService.deletePet(petData['_id']).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mascota eliminada exitosamente')),
                    );
                    context.pop(true);
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar la mascota: $e')),
                  );
                }
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
}
