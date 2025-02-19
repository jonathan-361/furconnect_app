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
      backgroundColor: const Color.fromARGB(255, 238, 238, 238),
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: const Color.fromARGB(255, 238, 238, 238),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 20,
          fontFamily: 'RobotoR',
          fontWeight: FontWeight.w600,
        ),
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
                        const CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 60,
                        ),
                        SizedBox(height: 18),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatWord(
                                        '${userData?['nombre'] ?? 'Nombre no disponible'} ${userData?['apellido'] ?? ''}'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    context.push('/editUser', extra: userData);
                                  },
                                  child: Icon(
                                    Icons.border_color,
                                    size: 18,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 35),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                      bottomLeft: Radius.zero,
                                      bottomRight: Radius.zero,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  context.push('/myPets');
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.pets, color: Colors.black),
                                          SizedBox(width: 8),
                                          Text(
                                            'Mis mascotas',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: Icon(Icons.chevron_right,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.zero),
                                  ),
                                ),
                                onPressed: () {
                                  context.push('/furconnectPlus');
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.pets, color: Colors.black),
                                          SizedBox(width: 8),
                                          Text(
                                            'FurConnect+',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: Icon(Icons.chevron_right,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.zero,
                                      topRight: Radius.zero,
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  loginService.logout();
                                  context.go('/login');
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(width: 8),
                                          Text(
                                            'Cerrar sesión',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  String _formatWord(String word) {
    if (word.isEmpty) return word;

    return word
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join(' ');
  }
}
