import 'package:flutter/material.dart';

class MyPets extends StatelessWidget {
  const MyPets({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis mascotas'),
      ),
      body: Column(
        children: [
          // Invocamos el nuevo widget y le pasamos los datos
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
        ],
      ),
    );
  }
}

// Widget PetCard reutilizable
class PetCard extends StatelessWidget {
  final String nombre;
  final String raza;
  final String tamano;
  final String color;
  final String edad;

  const PetCard({
    super.key,
    required this.nombre,
    required this.raza,
    required this.tamano,
    required this.color,
    required this.edad,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      elevation: 4, // Sombra de la tarjeta
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Bordes redondeados
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Cuadrado gris a la izquierda
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300], // Color gris
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(width: 16), // Espacio entre el cuadrado y el texto
            // Información de la mascota
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text("Raza: $raza"),
                Text("Tamaño: $tamano"),
                Text("Color: $color"),
                Text("Edad: $edad"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
