import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';

class UserService {
  final ApiService _apiService;
  final LoginService _loginService;

  UserService(this._apiService, this._loginService);

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.get(
        "/users/$userId",
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Error al obtener los datos del usuario");
      }
    } catch (err) {
      throw Exception("Error en la solicitud: ${err}");
    }
  }
}
