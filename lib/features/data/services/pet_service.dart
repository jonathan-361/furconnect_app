import 'package:dio/dio.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';

class PetService {
  final ApiService _apiService;
  final LoginService _loginService;

  PetService(this._apiService, this._loginService);

  Future<Map<String, dynamic>?> getPetById(String petId) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.get(
        '/pets/$petId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Error al obtener la mascota.");
      }
    } on DioException catch (e) {
      throw Exception("Error en la solicitud: ${e.message}");
    }
  }

  Future<List<dynamic>> getPetsByOwner(String ownerId) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.get(
        '/pets/owner/$ownerId',
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
        throw ("No tienes mascotas todavía");
      } else {
        throw Exception("Error al obtener las mascotas.");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("No tienes mascotas todavía");
      } else {
        throw Exception("Error en la solicitud: ${e.message}");
      }
    }
  }

  Future<bool> addPet(
    String imagen,
    String nombre,
    String raza,
    String tipo,
    String color,
    String tamano,
    int edad,
    String sexo,
    bool pedigree,
    List<String> vacunas,
    String temperamento,
    String usuarioId,
    List<String> media,
  ) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.post(
        '/pets',
        data: {
          "imagen": imagen,
          "nombre": nombre,
          "raza": raza,
          "tipo": tipo,
          "color": color,
          "tamaño": tamano.toLowerCase(),
          "edad": edad,
          "sexo": sexo.toLowerCase(),
          "pedigree": pedigree,
          "vacunas": vacunas,
          "temperamento": temperamento,
          "usuario_id": usuarioId,
          "media": media,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Mascota agregada exitosamente.");
        return true;
      } else {
        throw Exception(
            "Error al agregar la mascota: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception("Error en la solicitud: ${e.message}");
    }
  }

  Future<bool> updatePet(
    String petId,
    String nombre,
    String raza,
    String tipo,
    String color,
    String tamano,
    int edad,
    String sexo,
    bool pedigree,
    List<String> vacunas,
    String temperamento,
    String usuarioId,
    List<String> media,
  ) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.put(
        '/pets/$petId',
        data: {
          "nombre": nombre,
          "raza": raza,
          "tipo": tipo,
          "color": color,
          "tamaño": tamano.toLowerCase(),
          "edad": edad,
          "sexo": sexo.toLowerCase(),
          "pedigree": pedigree,
          "vacunas": vacunas,
          "temperamento": temperamento,
          "media": media,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("Mascota actualizada exitosamente.");
        return true;
      } else {
        throw Exception(
            "Error al actualizar la mascota: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception("Error en la solicitud: ${e.message}");
    }
  }

  Future<void> deletePet(String petId) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.delete(
        '/pets/$petId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("Mascota eliminada exitosamente.");
        return response.data;
      } else {
        throw Exception(
            "Error al eliminar la mascota: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception("Error en la solicitud: ${e.message}");
    }
  }
}
