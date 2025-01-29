import 'package:furconnect/features/data/services/api_service.dart';
import 'package:logger/logger.dart';

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
      } else {
        _logger.w('Error al crear usuario: ${response.statusMessage}');
        return false;
      }
    } catch (e) {
      _logger.e('Excepción en el registro del usuario: $e');
      return false;
    }
  }
}
