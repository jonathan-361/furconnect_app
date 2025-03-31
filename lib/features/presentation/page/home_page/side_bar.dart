import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/user_service.dart';

class SideBar extends StatelessWidget {
  SideBar({super.key});

  final apiService = ApiService();
  final loginService = LoginService(ApiService());
  final userService = UserService(ApiService(), LoginService(ApiService()));

  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _loadUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data;
          final userName =
              _formatWord(userData?['nombre'] ?? 'Nombre no disponible');
          final userEmail = userData?['email'] ?? 'example@gmail.com';

          return Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(userName,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  radius: 50,
                  backgroundImage: userData?['imagen'] != null &&
                          userData?['imagen'].isNotEmpty
                      ? NetworkImage(userData?['imagen'])
                      : AssetImage('assets/images/placeholder/avatar.jpg')
                          as ImageProvider,
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Perfil'),
                onTap: () {
                  context.push('/profile');
                },
              ),
              /*
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Favoritos'),
                onTap: () {},
              ),
              */
              Spacer(),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text('Cerrar sesión',
                    style: TextStyle(color: const Color(0xFFF44336))),
                onTap: () {
                  loginService.logout();
                  context.go('/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _loadUserData() async {
    try {
      await loginService.loadToken();
      final token = loginService.authToken;

      if (token == null) {
        return null;
      }

      final decodedToken = JwtDecoder.decode(token);
      final userId = decodedToken['id'];

      final data = await userService.getUserById(userId);
      return data;
    } catch (err) {
      print("Error al cargar los datos del usuario: $err");
      return null;
    }
  }

  String _formatWord(String word) {
    if (word.isEmpty) return word;

    return word
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildSidebar(context),
    );
  }
}
