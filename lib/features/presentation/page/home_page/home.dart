import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/user_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final apiService = ApiService();
  final loginService = LoginService(ApiService());
  final userService = UserService(ApiService(), LoginService(ApiService()));

  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = '';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(
                    'assets/images/placeholder/user_placeholder.jpg'),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  hintStyle: TextStyle(
                    color: Colors.white,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: _buildSidebar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                FilterChip(
                  label: Text('Macho'),
                  onSelected: (bool value) {},
                ),
                FilterChip(
                  label: Text('Pug'),
                  onSelected: (bool value) {},
                ),
                FilterChip(
                  label: Text('Otros'),
                  onSelected: (bool value) {},
                ),
                ActionChip(
                  avatar: Icon(Icons.filter_list),
                  label: Text('Filtros'),
                  onPressed: () => _showFilterModal(context),
                ),
              ],
            ),
          ),
          Expanded(
              child: GridView(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            children: [
              _buildPetCard(
                imagePath: 'assets/images/placeholder/pet_placeholder.jpg',
                name: 'Cruzar mascota',
                onTap: () => print('Cruzar mascota'),
              ),
              _buildPetCard(
                imagePath: 'assets/images/placeholder/pet_placeholder.jpg',
                name: 'Hacer amigos',
                onTap: () => print('Hacer amigos'),
              ),
              _buildPetCard(
                imagePath: 'assets/images/placeholder/pet_placeholder.jpg',
                name: 'Max',
                onTap: () => print('Card 3'),
              ),
              _buildPetCard(
                imagePath: 'assets/images/placeholder/pet_placeholder.jpg',
                name: 'Bella',
                onTap: () => print('Card 4'),
              ),
            ],
          )),
        ],
      ),
    );
  }

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
          final userEmail =
              _formatWord(userData?['email'] ?? 'example@gmail.com');

          return Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(userName,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                      'assets/images/placeholder/user_placeholder.jpg'),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Perfil'),
                onTap: () {
                  context.push('/profile');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Configuración'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Favoritos'),
                onTap: () {},
              ),
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

  Widget _buildPetCard({
    required String imagePath,
    required String name,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Filtros',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              CheckboxListTile(
                title: Text('Solo mascotas vacunadas'),
                value: false,
                onChanged: (value) {},
              ),
              CheckboxListTile(
                title: Text('Disponibles para adopción'),
                value: false,
                onChanged: (value) {},
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Aplicar filtros'),
              ),
            ],
          ),
        );
      },
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
