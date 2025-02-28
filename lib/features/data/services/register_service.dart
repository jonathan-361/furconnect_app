import 'package:furconnect/features/data/services/api_service.dart';
import 'package:logger/logger.dart';
import 'dart:io';

class RegisterService {
  final ApiService _apiService;
  final Logger _logger = Logger();

  RegisterService(this._apiService);

  Future<bool> registerUser(
    String imagen,
    String nombre,
    String apellido,
    String email,
    String password,
    String telefono,
    String ciudad,
    String estado,
    String pais,
  ) async {
    try {
      final response = await _apiService.post(
        '/users',
        data: {
          "imagen": imagen,
          "nombre": nombre,
          "apellido": apellido,
          "email": email,
          "password": password,
          "telefono": telefono,
          "ciudad": ciudad,
          "estado": estado,
          "pais": pais,
          "role": "user"
        },
      );

      if (response.statusCode == 201) {
        _logger.i('Usuario creado exitosamente');
        return true;
      } else if (response.statusCode == 400 || response.statusCode == 409) {
        _logger.w('El correo ya está en uso');
        return false;
      } else {
        _logger.w('Error al crear usuario: ${response.statusMessage}');
        return false;
      }
    } on SocketException catch (e) {
      _logger.e('Error de conexión: $e');
      throw Exception(
          'No se pudo establecer la conexión. Por favor, verifica tu conexión a Internet.');
    } catch (e) {
      _logger.e('Excepción en el registro del usuario: $e');
      return false;
    }
  }
}
