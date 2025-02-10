import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final loginService = LoginService(ApiService());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor:
                            Colors.grey, // Placeholder para la foto
                        radius: 40,
                      ),
                      const SizedBox(width: 16), // Espacio entre imagen y texto
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Alinear texto a la izquierda
                          children: const [
                            Text(
                              'Nombre:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Usuario Ejemplo',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Ciudad:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Ciudad Ejemplo',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.push('/myPets');
                },
                child: const Text('Mis mascotas'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                child: const Text('FurConnect+'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Tienda'),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  loginService.logout();
                  context.go('/login'); // Cerrar sesión
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
