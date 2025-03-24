import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/user_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  CustomAppBar({required this.scaffoldKey});

  final apiService = ApiService();
  final loginService = LoginService(ApiService());
  final userService = UserService(ApiService(), LoginService(ApiService()));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => scaffoldKey.currentState?.openDrawer(),
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _loadUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey, // Placeholder color
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        AssetImage('assets/images/placeholder/avatar.jpg'),
                  );
                }

                final userData = snapshot.data;
                return CircleAvatar(
                  radius: 20,
                  backgroundImage: userData?['imagen'] != null &&
                          userData?['imagen'].isNotEmpty
                      ? NetworkImage(userData?['imagen'])
                      : AssetImage('assets/images/placeholder/avatar.jpg')
                          as ImageProvider,
                );
              },
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

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
}
