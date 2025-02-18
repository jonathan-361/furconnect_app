import 'package:dio/dio.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';

class PublicationService {
  final ApiService _apiService;
  final LoginService _loginService;

  PublicationService(this._apiService, this._loginService);

  Future<Map<String, dynamic>?> getPublications() async {
    await _loginService.loadToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    final token = _loginService.authToken;

    try {
      final response = await _apiService.get(
        '/publications',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Error al obtener publicaciones.");
      }
    } on DioException catch (err) {
      throw Exception("Error en la solicitud: ${err}");
    }
  }

  Future<bool> addPublication(
    List<String> imagen,
    String etiqueta,
    String titulo,
    String descripcion,
    String mascotaId,
    String userId,
  ) async {
    await _loginService.loadToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }
    final token = _loginService.authToken;

    try {
      final response = await _apiService.post(
        '/publications',
        data: {
          "imagen": imagen,
          "etiqueta": etiqueta,
          "titulo": titulo,
          "descripcion": descripcion,
          "mascota_id": mascotaId,
          "user_id": userId,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Publicación agregada exitosamente.");
        return true;
      } else {
        throw Exception(
            "Error al hacer tu publicación: ${response.statusMessage}");
      }
    } on DioException catch (err) {
      throw Exception("Error en la solicitud: ${err.message}");
    }
  }

  Future<void> deletePublication(String publicationId) async {
    await _loginService.loadToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    final token = _loginService.authToken;

    try {
      final response = await _apiService.delete(
        '/publications/$publicationId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("Publicación eliminada exitosamente.");
        return response.data;
      } else {
        throw Exception(
            "Error al eliminar tu publicación: ${response.statusMessage}");
      }
    } on DioException catch (err) {
      throw Exception("Error en la solicitud: ${err.message}");
    }
  }
}
