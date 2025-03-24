import 'package:dio/dio.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';

class ChatService {
  final ApiService _apiService;
  final LoginService _loginService;

  ChatService(this._apiService, this._loginService);

  Future<List<dynamic>> getChats() async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.get(
        'chatrooms',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic> &&
            response.data['chats'] != null) {
          return List.from(response.data['chats']);
        } else if (response.data is List<dynamic>) {
          return response.data;
        } else {
          return [];
        }
      } else if (response.statusCode == 204) {
        return [];
      } else {
        throw Exception("Error al obtener los chats.");
      }
    } on DioException catch (err) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getChatById(String chatId) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.get(
        "chatrooms/$chatId",
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Error al obtener los datos del chat");
      }
    } catch (err) {
      throw Exception("Error en la solicitud: ${err}");
    }
  }
}
