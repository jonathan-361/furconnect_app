import 'package:furconnect/features/data/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  final ApiService _apiService;
  String? _authToken;
  DateTime? _tokenExpiration;

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
      _tokenExpiration = DateTime.now().add(Duration(hours: 1));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      return token;
    } else {
      throw Exception("Error al iniciar sesión: ${response.statusMessage}");
    }
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('token');
    _tokenExpiration = DateTime.now().add(Duration(hours: 1));
  }

  Future<void> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');

    if (email == null || password == null) {
      throw Exception("No se encontraron credenciales para refrescar el token");
    }

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
      _tokenExpiration = DateTime.now().add(Duration(hours: 1));

      await prefs.setString('token', token);
    } else {
      throw Exception("Error al refrescar el token: ${response.statusMessage}");
    }
  }

  Future<String?> getToken() async {
    if (_authToken == null) {
      await loadToken();
    }

    if (_tokenExpiration != null &&
        DateTime.now()
            .isAfter(_tokenExpiration!.subtract(Duration(minutes: 5)))) {
      await refreshToken();
    }

    return _authToken;
  }

  void logout() {
    _authToken = null;
    _tokenExpiration = null;
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('token');
      prefs.remove('email');
      prefs.remove('password');
    });
  }

  bool isAuthenticated() {
    return _authToken != null;
  }

  String? get authToken => _authToken;
}
