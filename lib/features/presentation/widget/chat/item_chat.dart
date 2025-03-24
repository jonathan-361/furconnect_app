import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';

class ItemChat extends StatelessWidget {
  final Map<String, dynamic> chat;
  final Function()? onTap;

  ItemChat({
    super.key,
    required this.chat,
    this.onTap,
  });

  Future<String?> _getUserId() async {
    try {
      final loginService = LoginService(ApiService());
      await loginService.loadToken();
      final token = loginService.authToken;

      if (token == null) {
        return null;
      }

      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['id'];
    } catch (err) {
      print('Error al decodificar el token: $err');
      return null;
    }
  }

  String _getOtherUserName(List<dynamic> usuarios, String userId) {
    for (var usuario in usuarios) {
      if (usuario["_id"] != userId) {
        return usuario["nombre"] ?? "Usuario desconocido";
      }
    }
    return "Usuario desconocido";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text("Cargando..."),
            subtitle: Text("Cargando mensajes..."),
          );
        }

        final String? userId = snapshot.data;
        if (userId == null) {
          return ListTile(
            title: Text("Error"),
            subtitle: Text("No se pudo obtener tu información."),
          );
        }

        final List<dynamic> usuarios = chat['usuarios'] ?? [];
        final List<dynamic> mensajes = chat['mensajes'] ?? [];

        // Obtener el nombre del otro usuario
        final String otherUserName = _getOtherUserName(usuarios, userId);

        // Obtener el último mensaje
        String messagePrefix = "¡Nuevo chat!";
        if (mensajes.isNotEmpty) {
          final lastMessage = mensajes.last;
          final String sender = lastMessage['sender'] ?? "";
          final String content =
              lastMessage['content'] ?? "Mensaje sin contenido";

          // Determinar si el mensaje lo enviaste tú o el otro usuario
          if (sender == userId) {
            messagePrefix = "Tú: $content";
          } else {
            messagePrefix = "$otherUserName: $content";
          }
        }

        return ListTile(
          title: Text(otherUserName),
          subtitle: Text(
            messagePrefix,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: onTap,
        );
      },
    );
  }
}
