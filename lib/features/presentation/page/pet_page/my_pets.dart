import 'package:flutter/material.dart';

import 'package:furconnect/features/presentation/widget/pet_card.dart';
import 'package:go_router/go_router.dart';

class MyPets extends StatelessWidget {
  const MyPets({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis mascotas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/newPet');
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Llamamos a PetCard y pasamos los datos
          PetCard(
            nombre: "Max",
            raza: "Labrador",
            tamano: "Grande",
            color: "Dorado",
            edad: "3 años",
          ),
          PetCard(
            nombre: "Bella",
            raza: "Bulldog",
            tamano: "Mediano",
            color: "Blanco",
            edad: "2 años",
          ),
          PetCard(
            nombre: "Rocky",
            raza: "Pastor Alemán",
            tamano: "Grande",
            color: "Negro y marrón",
            edad: "4 años",
          ),
          PetCard(
            nombre: "Rocky",
            raza: "Pastor Alemán",
            tamano: "Grande",
            color: "Negro y marrón",
            edad: "4 años",
          ),
        ],
      ),
    );
  }
}
