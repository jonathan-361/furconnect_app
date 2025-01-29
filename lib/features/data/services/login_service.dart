// login_service.dart
import 'package:furconnect/features/data/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  final ApiService _apiService;
  String? _authToken;

  LoginService(this._apiService);

  Future<String?> login(String email, String password) async {
    final response = await _apiService.post(
      "/login",
      data: {
        "email": email,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      final token = response.data['token'];
      _authToken = token;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      print("Token guardado: $token");
      return token;
    } else {
      throw Exception("Error al iniciar sesión: ${response.statusMessage}");
    }
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('token');
  }

  void logout() {
    _authToken = null;
  }

  bool isAuthenticated() {
    return _authToken != null;
  }

  String? get authToken => _authToken;
}
