import 'package:flutter/material.dart';
import 'package:furconnect/features/data/services/request_service.dart';

import 'package:furconnect/features/presentation/widget/item_request_pet.dart';
import 'package:furconnect/features/presentation/widget/my_item_request_send.dart';
import 'package:furconnect/features/presentation/widget/my_item_receive_request.dart';
import 'package:furconnect/features/presentation/widget/overlays/loading_overlay.dart';
import 'package:furconnect/features/presentation/widget/pet_card_home.dart';

class MatchPage extends StatefulWidget {
  final RequestService requestService;

  const MatchPage({super.key, required this.requestService});

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  List<dynamic> sendRequests = [];
  List<dynamic> receiveRequest = [];
  bool _isLoading = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadSendRequest();
    _loadReceiveRequest();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _reloadReceiveRequests() async {
    await _loadReceiveRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Match'),
            ),
            body: Column(
              children: [
                const TabBar(
                  labelStyle:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  unselectedLabelStyle:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  labelColor: Color.fromARGB(255, 97, 97, 97),
                  unselectedLabelColor: Color.fromARGB(255, 112, 112, 112),
                  tabs: [
                    Tab(text: 'Solicitudes recibidas'),
                    Tab(text: 'Solicitudes enviadas'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      receiveRequest.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pets,
                                    size: 70,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Todavía no tienes solicitudes recibidas',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(8),
                              itemCount: receiveRequest.length,
                              itemBuilder: (context, index) {
                                var request = receiveRequest[index];
                                return MyItemReceiveRequest(
                                  petData: request['mascota_solicitante_id'],
                                  acceptButton: 'Aceptar',
                                  rejectButton: 'Rechazar',
                                  requestId: request['_id'].toString(),
                                  requestService: widget.requestService,
                                  onRequestHandled: _reloadReceiveRequests,
                                );
                              },
                            ),
                      sendRequests.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pets,
                                    size: 70,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Todavía no has enviado solicitudes',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(8),
                              itemCount: sendRequests.length,
                              itemBuilder: (context, index) {
                                var request = sendRequests[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Navegar a PetCardHome cuando se toca un elemento de la lista
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PetCardHome(
                                          petData:
                                              request['mascota_solicitante_id'],
                                          source: 'requestSend',
                                          requestId: request['_id'].toString(),
                                          onDelete: _deleteRequestHandler,
                                        ),
                                      ),
                                    );
                                  },
                                  child: MyItemRequestSend(
                                    petData: request['mascota_solicitante_id'],
                                    deleteButton: 'Borrar solicitud',
                                    requestId: request['_id'].toString(),
                                    requestService: widget.requestService,
                                    onDelete: _deleteRequestHandler,
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading) LoadingOverlay(),
      ],
    );
  }

  void showLoadingOverlay() {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
  }

  void hideLoadingOverlay() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteRequestHandler() async {
    showLoadingOverlay();
    await Future.delayed(Duration(milliseconds: 500));
    await _loadSendRequest();
    hideLoadingOverlay();
  }

  Future<void> _loadSendRequest() async {
    if (_isDisposed) return;

    showLoadingOverlay();
    try {
      final requests = await widget.requestService.getSendRequest();
      if (_isDisposed) return;

      final pendingRequests = requests
          .where((request) =>
              request['estado'] == 'pendiente' &&
              request['mascota_solicitante_id'] != null)
          .toList();

      if (mounted) {
        setState(() {
          sendRequests = pendingRequests;
        });
      }

      hideLoadingOverlay();
    } catch (err) {
      if (!_isDisposed) {
        hideLoadingOverlay();
        print("Error al cargar solicitudes enviadas: $err");
      }
    }
  }

  Future<void> _loadReceiveRequest() async {
    showLoadingOverlay();
    try {
      final requests = await widget.requestService.getReceiveRequest();
      final pendingRequests = requests
          .where((request) => request['estado'] == 'pendiente')
          .toList();

      if (mounted) {
        setState(() {
          receiveRequest = pendingRequests;
        });
      }

      for (var request in pendingRequests) {
        print(
            "Nombre de la mascota solicitada: ${request['mascota_solicitado_id']['nombre']}");
        print("Usuario solicitado ID: ${request['usuario_solicitado_id']}");
        print("${request['estado']}");
      }

      hideLoadingOverlay();
    } catch (err) {
      hideLoadingOverlay();
      print("Error al cargar solicitudes recibidas: $err");
    }
  }
}
