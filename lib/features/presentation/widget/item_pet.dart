import 'package:flutter/material.dart';
import 'package:furconnect/features/data/services/pet_service.dart';

class ItemPet extends StatelessWidget {
  final String petId;

  const ItemPet({Key? key, required this.petId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalles de la mascota")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: PetService()
            .getPetById(petId), // Usar petId para hacer la solicitud
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final petData = snapshot.data;
          if (petData == null) {
            return Center(child: Text('No se encontró la mascota'));
          }

          return ListView(
            children: [
              ListTile(title: Text("Nombre: ${petData['nombre']}")),
              ListTile(title: Text("Raza: ${petData['raza']}")),
              ListTile(title: Text("Tipo: ${petData['tipo']}")),
              ListTile(title: Text("Color: ${petData['color']}")),
              ListTile(title: Text("Tamaño: ${petData['tamaño']}")),
              ListTile(title: Text("Edad: ${petData['edad']}")),
              ListTile(title: Text("Sexo: ${petData['sexo']}")),
              ListTile(title: Text("Pedigree: ${petData['pedigree']}")),
              ListTile(title: Text("Temperamento: ${petData['temperamento']}")),
              ListTile(
                  title: Text("Dueño: ${petData['usuario_id']['nombre']}")),
            ],
          );
        },
      ),
    );
  }
}
