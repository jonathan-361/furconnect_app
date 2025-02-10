import 'package:furconnect/features/data/services/api_service.dart';
import 'package:logger/logger.dart';
import 'dart:io';

class RegisterService {
  final ApiService _apiService;
  final Logger _logger = Logger();

  RegisterService(this._apiService);

  Future<bool> registerUser(String nombre, String email, String password,
      String telefono, String ciudad, String estado, String pais) async {
    try {
      final response = await _apiService.post('/users', data: {
        "nombre": nombre,
        "email": email,
        "password": password,
        "telefono": telefono,
        "ciudad": ciudad,
        "estado": estado,
        "pais": pais,
        "role": "user"
      });

      if (response.statusCode == 201) {
        _logger.i('Usuario creado exitosamente');
        return true;
      } else if (response.statusCode == 400 || response.statusCode == 409) {
        // Suponiendo que la API devuelve un 400 o 409 si el correo ya está en uso
        _logger.w('El correo ya está en uso');
        return false;
      } else {
        _logger.w('Error al crear usuario: ${response.statusMessage}');
        return false;
      }
    } on SocketException catch (e) {
      _logger.e('Error de conexión: $e');
      // Si ocurre una excepción de tipo SocketException, la red no está disponible
      throw Exception(
          'No se pudo establecer la conexión. Por favor, verifica tu conexión a Internet.');
    } catch (e) {
      _logger.e('Excepción en el registro del usuario: $e');
      return false;
    }
  }
}
