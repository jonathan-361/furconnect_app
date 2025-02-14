import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:go_router/go_router.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/user_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final apiService = ApiService();
  final loginService = LoginService(ApiService());
  final userService = UserService(ApiService(), LoginService(ApiService()));

  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final loginService = LoginService(ApiService());
      await loginService.loadToken();
      final token = loginService.authToken;

      if (token == null) {
        return null;
      }

      final decodedToken = JwtDecoder.decode(token);
      final userId = decodedToken['id'];

      final data = await userService.getUserById(userId);
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (err) {
      setState(() {
        errorMessage = "Error al cargar los datos del usuario: $err";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : errorMessage.isNotEmpty
                  ? Text(errorMessage)
                  : Column(
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
                                const SizedBox(
                                    width: 16), // Espacio entre imagen y texto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Alinear texto a la izquierda
                                    children: [
                                      Text(
                                        'Nombre:',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _formatWord(userData?['nombre'] ??
                                            'Nombre no disponible'),
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Ciudad:',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _formatWord(userData?['ciudad'] ??
                                            'Ciudad no disponible'),
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

  String _formatWord(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }
}
