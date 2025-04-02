import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/user_service.dart';
import 'package:furconnect/features/data/services/payment_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final UserService _userService =
      UserService(ApiService(), LoginService(ApiService()));
  final PaymentService _paymentService =
      PaymentService(ApiService(), LoginService(ApiService()));

  String _userStatus = '';
  bool _isLoading = true;

  final String stripeUrl = "https://buy.stripe.com/test_4gw17L6kv7XPceI5kk";
  final Uri _url = Uri.parse('https://buy.stripe.com/test_4gw17L6kv7XPceI5kk');

  @override
  void initState() {
    super.initState();
    _loadUserStatus();
  }

  Future<void> _loadUserStatus() async {
    setState(() => _isLoading = true);
    final status = await _getUserStatus();
    setState(() {
      _userStatus = status ?? '';
      _isLoading = false;
    });
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<String> _getUserId() async {
    try {
      final loginService = LoginService(ApiService());
      await loginService.loadToken();
      final token = loginService.authToken;

      if (token == null) {
        throw Exception('Token is null');
      }

      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['id'];
    } catch (err) {
      print('Error al decodificar el token: $err');
      throw Exception('Failed to get user ID: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/background_login_copy.png'),
              fit: BoxFit.cover,
            )),
          ),
          Opacity(
            opacity: 0.8,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromARGB(255, 77, 5, 0),
                    const Color.fromARGB(255, 0, 0, 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 26,
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'FurConnect+',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFeature('Solicitudes ilimitadas (5/día actual)'),
                  _buildFeature('Envío de mensajes sin restricciones'),
                  _buildFeature('Sin publicidad'),
                  _buildFeature('Publicaciones visibles en cualquier ciudad'),
                  _buildFeature('Tus solicitudes destacan'),
                  const SizedBox(height: 30),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    _buildActionButton(),
                  const SizedBox(height: 10),
                  const Text(
                    'Pago recurrente',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_userStatus.toLowerCase() == 'premium') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        ),
        onPressed: _showCancelSubscriptionDialog,
        child: const Center(
          child: Text(
            'Cancelar suscripción',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      );
    } else {
      return // subscription.dart (solo el método modificado)
          ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        ),
        onPressed: () async {
          //final userId = await _getUserId();
          _launchUrl();
        },
        child: const Center(
          child: Text(
            'Suscribirme por \$129',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      );
    }
  }

  void _showCancelSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar suscripción'),
          content: const Text(
              '¿Estás seguro de que deseas cancelar tu suscripción a FurConnect+?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                // Aquí iría la lógica para cancelar la suscripción
              },
              child: const Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _getUserStatus() async {
    try {
      final userId = await _getUserId();
      if (userId != null) {
        final userData = await _userService.getUserById(userId);
        return userData?['estatus'];
      }
      return null;
    } catch (err) {
      print('Error al obtener el estatus del usuario: $err');
      return null;
    }
  }
}
