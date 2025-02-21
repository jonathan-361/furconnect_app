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
        backgroundColor: Color(0xFF894936),
        title: Text(
          petData['nombre'],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _showPetImage(),
              SizedBox(height: 16),
              _infoCard(),
              SizedBox(height: 16),
              _actionButtons(context, petService),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.pets, "Tipo", petData['tipo']),
            _infoRow(Icons.category, "Raza", petData['raza']),
            _infoRow(Icons.cake, "Edad", "${petData['edad']} años"),
            _infoRow(Icons.color_lens, "Color", petData['color']),
            _infoRow(Icons.check_circle, "Pedigree",
                petData['pedigree'] ? "Sí" : "No"),
            _infoRow(Icons.height, "Tamaño", petData['tamaño']),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFC48253)),
          SizedBox(width: 10),
          Text("$label:", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 5),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _actionButtons(BuildContext context, PetService petService) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFC48253),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text("Editar Mascota", style: TextStyle(color: Colors.white)),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _showDeleteConfirmationDialog(
              context, petService, petData['_id']),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF894936),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child:
              Text("Eliminar Mascota", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _showPetImage() {
    String imageUrl = petData['media'].isNotEmpty
        ? petData['media'].first
        : 'assets/images/placeholder/pet_placeholder.jpg';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/placeholder/pet_placeholder.jpg',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, PetService petService, String petId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar esta mascota?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deletePet(context, petService, petId);
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePet(
      BuildContext context, PetService petService, String petId) async {
    try {
      await petService.deletePet(petId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Mascota eliminada exitosamente'),
            backgroundColor: Colors.green),
      );
      context.pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al eliminar la mascota: $e'),
            backgroundColor: Colors.red),
      );
    }
  }
}
