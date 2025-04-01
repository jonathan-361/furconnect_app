import 'package:flutter/material.dart';
import 'package:furconnect/features/data/services/payment_service.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pago'),
      ),
    );
  }
}
