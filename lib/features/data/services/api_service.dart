import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiService {
  final Dio _dio;
  final Logger _logger = Logger();

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: "https://furconnect.onrender.com/",
            // baseUrl: "https://furconnect-api-copy-v2.onrender.com/api/",
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
            headers: {
              'Accept': 'application/json',
            },
          ),
        );

  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParams,
      Map<String, dynamic>? headers}) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }

    throw Exception("Error en la solicitud GET");
  }

  Future<Response> post(String endpoint,
      {Map<String, dynamic>? data, Map<String, dynamic>? headers}) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }

    throw Exception("Error en la solicitud POST");
  }

  Future<Response> put(String endpoint,
      {Map<String, dynamic>? data, Map<String, dynamic>? headers}) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }

    throw Exception("Error en la solicitud PUT");
  }

  Future<Response> delete(String endpoint,
      {Map<String, dynamic>? queryParams,
      Map<String, dynamic>? headers}) async {
    try {
      return await _dio.delete(
        endpoint,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }

    throw Exception("Error en la solicitud DELETE");
  }

  void _handleDioError(DioException e) {
    if (e.response?.statusCode == 400) {
      _logger.w("Error de cliente: ${e.response?.data}");
      throw ("Datos incorrectos proporcionados.");
    }
    if (e.type == DioExceptionType.connectionError) {
      _logger.e("Error de conexión: No se pudo establecer conexión");
      throw ("No se pudo conectar al servidor. Intenta nuevamente.");
    } else if (e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      _logger.e("Error de tiempo de espera agotado");
      // throw Exception("Tiempo de espera agotado. Intenta nuevamente.");
      throw ("Tiempo de espera agotado. Intenta nuevamente.");
    } else {
      _logger.e("Error inesperado: $e");
      throw ("Ocurrió un error inesperado. Intenta nuevamente.");
    }
  }
}
