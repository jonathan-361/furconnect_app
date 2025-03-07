import 'package:dio/dio.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';

class RequestService {
  final ApiService _apiService;
  final LoginService _loginService;

  RequestService(this._apiService, this._loginService);

  Future<List<dynamic>> getSendRequest() async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.get(
        '/solicitudes/enviadas/todas',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.data.isEmpty) {
          return [];
        } else {
          return response.data;
        }
      } else if (response.statusCode == 204) {
        throw ("No tienes solicitudes todavía");
      } else {
        throw Exception("Error al obtener las solicitudes.");
      }
    } on DioException catch (err) {
      if (err.response?.statusCode == 404) {
        throw Exception("No tienes solicitudes todavía");
      } else {
        throw Exception("Error en la solicitud: ${err.message}");
      }
    }
  }

  Future<List<dynamic>> getReceiveRequest() async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.get(
        '/solicitudes/recibidas',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.data.isEmpty) {
          return [];
        } else {
          return response.data;
        }
      } else if (response.statusCode == 204) {
        throw ("No tienes solicitudes todavía");
      } else {
        throw Exception("Error al obtener las solicitudes.");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("No tienes solicitudes todavía");
      } else {
        throw Exception("Error en la solicitud: ${e.message}");
      }
    }
  }

  Future<bool> addRequest(
    String mascotaUsuarioId,
    String usuarioId,
    String mascotaSolicitadoId,
    String usuarioSolicitadoId,
    String estado,
  ) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.post(
        '/solicitudes',
        data: {
          "mascota_solicitante_id": mascotaUsuarioId,
          "usuario_solicitante_id": usuarioId,
          "mascota_solicitado_id": mascotaSolicitadoId,
          "usuario_solicitado_id": usuarioSolicitadoId,
          "estado": estado,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Solicitud enviada exitosamente.");
        return true;
      } else {
        throw Exception(
            "Error al enviar la solicitud: ${response.statusMessage}");
      }
    } on DioException catch (err) {
      throw Exception("Error en la solicitud: ${err.message}");
    }
  }

  Future<void> deleteRequest(String requestId) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.delete(
        '/solicitudes/$requestId/',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("Solicitud eliminada exitosamente.");
        return response.data;
      } else {
        throw Exception(
            "Error al eliminar la solicitud: ${response.statusMessage}");
      }
    } on DioException catch (err) {
      throw Exception(
          "Error en la eliminación de la solicitud: ${err.message}");
    }
  }
}
