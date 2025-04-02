import 'package:dio/dio.dart';
import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';

class PaymentService {
  final ApiService _apiService;
  final LoginService _loginService;

  PaymentService(this._apiService, this._loginService);

  Future<bool> sendStripeWebhook(String userId) async {
    final token = await _loginService.getToken();

    if (!_loginService.isAuthenticated()) {
      throw Exception("No se encuentra autenticado. Inicie sesión.");
    }

    try {
      final response = await _apiService.post(
        '/webhook',
        data: {}, // Enviamos el body en JSON
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "userId": userId, // También enviamos el userId en los headers
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Webhook enviado correctamente.");
        return true;
      } else {
        throw Exception(
            "Error al enviar el webhook: ${response.statusMessage}");
      }
    } on DioException catch (err) {
      throw Exception("Error en la solicitud: ${err.message}");
    }
  }
}
