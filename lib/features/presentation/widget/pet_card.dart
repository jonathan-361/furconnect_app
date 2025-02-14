import 'package:flutter/material.dart';
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
            _showPetImage(),
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
                backgroundColor: const Color.fromARGB(223, 233, 118, 65),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              ),
              child: Text("Editar mascota"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showDeleteConfirmationDialog(
                  context, petService, petData['_id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(223, 126, 51, 17),
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

  void _deletePet(
      BuildContext context, PetService petService, String petId) async {
    try {
      await petService.deletePet(petId);
      _showOverlay(context, Colors.green, 'Mascota eliminada exitosamente');
      context.pop(true);
    } catch (e) {
      _showOverlay(context, Colors.red, 'Error al eliminar la mascota: $e');
    }
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, PetService petService, String petId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Se usa un contexto separado para evitar conflictos con el cierre del diálogo.
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar esta mascota?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(); // Cierra el diálogo antes de ejecutar la acción
                _deletePet(context, petService,
                    petId); // Llama al método de eliminación
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showPetImage() {
    List<String> media = (petData['media'] as List<dynamic>?)
            ?.map((item) => item.toString().trim())
            .toList() ??
        [];

    String imageUrl = media.isNotEmpty
        ? media.first
        : 'assets/images/placeholder/pet_placeholder.jpg';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 200,
        fit: BoxFit.fitWidth,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/placeholder/pet_placeholder.jpg',
            width: 200,
            fit: BoxFit.fitWidth,
          );
        },
      ),
    );
  }

  void _showOverlay(BuildContext context, Color color, String message) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.12,
            left: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(Duration(milliseconds: 1500), () {
      overlayEntry.remove();
    });
  }
}
