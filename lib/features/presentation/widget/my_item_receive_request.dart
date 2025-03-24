import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:furconnect/features/data/services/request_service.dart';
import 'package:furconnect/features/presentation/widget/overlays/overlay.dart';
import 'package:furconnect/features/presentation/widget/overlays/loading_overlay.dart';

class MyItemReceiveRequest extends StatefulWidget {
  final Map<String, dynamic> petData;
  final acceptButton;
  final rejectButton;
  final String requestId;
  final RequestService requestService;
  final VoidCallback onRequestHandled;

  const MyItemReceiveRequest({
    super.key,
    required this.petData,
    required this.acceptButton,
    required this.rejectButton,
    required this.requestId,
    required this.requestService,
    required this.onRequestHandled,
  });

  @override
  State<MyItemReceiveRequest> createState() => _MyItemReceiveRequestState();
}

class _MyItemReceiveRequestState extends State<MyItemReceiveRequest> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        title: Row(
          children: [
            _buildImage(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatWord(widget.petData['nombre']),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: _getResponsiveFontSize(context, 20),
                          fontFamily: 'Nunito',
                          color: Colors.brown.shade700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatWord(widget.petData['raza']),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: _getResponsiveFontSize(context, 16),
                      fontFamily: 'Nunito',
                      color: const Color.fromARGB(255, 134, 128, 126),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton(
                          text: widget.acceptButton,
                          onPressed: () {
                            _acceptRequest(context);
                          },
                          buttonColor: Colors.green,
                          buttonSize: _getResponsiveFontSize(context, 14),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: _buildButton(
                          text: widget.rejectButton,
                          onPressed: () {
                            _rejectRequest(context);
                          },
                          buttonColor: Colors.red,
                          buttonSize: _getResponsiveFontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () => context.pushNamed('petCardHome', extra: {
          'petData': widget.petData,
          'source': 'requestReceive',
          'requestId': widget.requestId,
          'onDelete': widget.onRequestHandled,
        }),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: widget.petData['imagen'] != null &&
              widget.petData['imagen']!.isNotEmpty
          ? Image.network(
              widget.petData['imagen']!.trim(),
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            )
          : Image.asset(
              'assets/images/placeholder/pet_placeholder.jpg',
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    Color buttonColor = Colors.blue,
    double buttonSize = 13,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: buttonSize,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 350) {
      return baseSize * 0.9;
    } else if (screenWidth < 340) {
      return baseSize * 0.8;
    }
    return baseSize;
  }

  void _acceptRequest(BuildContext context) async {
    try {
      await widget.requestService.acceptRequest(widget.requestId);
      widget.onRequestHandled();
      AppOverlay.showOverlay(
          context, Colors.green, "Solicitud aceptada éxitosamente");
    } catch (err) {
      AppOverlay.showOverlay(
          context, Colors.red, "Error al aceptar la solicitud: $err");
    }
  }

  void _rejectRequest(BuildContext context) async {
    try {
      await widget.requestService.rejectRequest(widget.requestId);
      widget.onRequestHandled();
    } catch (err) {
      AppOverlay.showOverlay(
          context, Colors.red, "Error al rechazar la solicitud: $err");
    }
  }

  String _formatWord(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }
}
