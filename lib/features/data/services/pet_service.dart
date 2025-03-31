import 'package:dio/dio.dart';
import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';

class PetService {
  final ApiService _apiService;
  final LoginService _loginService;

  PetService(this._apiService, this._loginService);

  Future<List<dynamic>> getPets(int page, int limit) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.get(
        'api/pets',
        queryParams: {'page': page, 'limit': limit},
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic> &&
            response.data['pets'] != null) {
          return List.from(response.data['pets']);
        } else if (response.data is List<dynamic>) {
          return response.data;
        } else {
          throw Exception("La respuesta no contiene una lista de mascotas.");
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

  Future<List<dynamic>> getPetsFilter(
    int page,
    int limit,
    String raza,
    String sexo,
    String edad,
    String estado,
    String pais,
  ) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.get(
        'api/pets/search',
        queryParams: {
          'page': page,
          'limit': limit,
          'raza': raza,
          'sexo': sexo,
          'edad': edad,
          'estado': estado,
          'pais': pais,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic> &&
            response.data['pets'] != null) {
          return List.from(response.data['pets']);
        } else if (response.data is List<dynamic>) {
          return response.data;
        } else {
          throw Exception("La respuesta no contiene una lista de mascotas.");
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

  Future<Map<String, dynamic>?> getPetById(String petId) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.get(
        'api/pets/$petId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Error al obtener la mascota.");
      }
    } on DioException catch (err) {
      throw Exception("Error en la solicitud: ${err.message}");
    }
  }

  Future<List<dynamic>> getPetsByOwner(String ownerId) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.get(
        'api/pets/owner/$ownerId',
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
    } on DioException catch (err) {
      if (err.response?.statusCode == 404) {
        throw Exception("No tienes mascotas todavía");
      } else {
        throw Exception("Error en la solicitud: ${err.message}");
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
    String pais,
    String estado,
    String ciudad,
  ) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.post(
        'api/pets',
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
          "pais": pais,
          "estado": estado,
          "ciudad": ciudad
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
    } on DioException catch (err) {
      throw Exception("Error en la solicitud: ${err.message}");
    }
  }

  Future<bool> editPet(
    String petId,
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
    String pais,
    String estado,
    String ciudad,
  ) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.put(
        'api/pets/$petId',
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
          "pais": pais,
          "estado": estado,
          "ciudad": ciudad,
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
    } on DioException catch (err) {
      throw Exception("Error en la solicitud: ${err.message}");
    }
  }

  Future<void> deletePet(String petId) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.delete(
        'api/pets/$petId',
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
    } on DioException catch (err) {
      throw Exception("Error en la solicitud: ${err.message}");
    }
  }
}
