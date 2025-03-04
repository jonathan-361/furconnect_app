import 'package:flutter/material.dart';
import 'package:furconnect/features/data/services/request_service.dart';
import 'package:furconnect/features/presentation/widget/item_request_pet.dart';
import 'package:furconnect/features/presentation/widget/my_item_request_send.dart';
import 'package:furconnect/features/presentation/widget/loading_overlay.dart';

class MatchPage extends StatefulWidget {
  final RequestService requestService;

  const MatchPage({super.key, required this.requestService});

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  List<dynamic> sendRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSendRequest();
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
                      ListView(
                        padding: EdgeInsets.all(8),
                        children: [
                          ItemRequestPet(
                            nombre: '',
                            raza: '',
                            imagenUrl: '',
                            firstTextButton: 'Aceptar',
                            secondTextButton: 'Rechazar',
                          ),
                          ItemRequestPet(
                            nombre: '',
                            raza: '',
                            imagenUrl: '',
                            firstTextButton: 'Aceptar',
                            secondTextButton: 'Rechazar',
                          ),
                          ItemRequestPet(
                            nombre: '',
                            raza: '',
                            imagenUrl: '',
                            firstTextButton: 'Aceptar',
                            secondTextButton: 'Rechazar',
                          ),
                        ],
                      ),
                      ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: sendRequests.length,
                        itemBuilder: (context, index) {
                          var request = sendRequests[index];
                          return MyItemRequestSend(
                            nombre: request['mascota_solicitado_id']['nombre'],
                            raza: request['mascota_solicitado_id']['raza'],
                            imagenUrl: request['mascota_solicitado_id']
                                    ['imagen'] ??
                                '',
                            deleteButton: 'Borrar solicitud',
                            requestId: request['_id'].toString(),
                            requestService: widget.requestService,
                            onDelete: _deleteRequestHandler,
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
    setState(() {
      _isLoading = true;
    });
  }

  void hideLoadingOverlay() {
    setState(() {
      _isLoading = false;
    });
  }

  void _deleteRequestHandler() async {
    showLoadingOverlay();
    await Future.delayed(Duration(milliseconds: 500));
    await _loadSendRequest();
    hideLoadingOverlay();
  }

  Future<void> _loadSendRequest() async {
    showLoadingOverlay();
    try {
      final requests = await widget.requestService.getSendRequest();

      // Filtramos las solicitudes que tienen estado 'pendiente'
      final pendingRequests = requests
          .where((request) => request['estado'] == 'pendiente')
          .toList();

      setState(() {
        sendRequests =
            pendingRequests; // Actualizamos la lista con solo las solicitudes pendientes
      });

      // Para pruebas, muestra la información de las solicitudes pendientes
      for (var request in pendingRequests) {
        print(
            "Nombre de la mascota solicitada: ${request['mascota_solicitado_id']['nombre']}");
        print("Usuario solicitado ID: ${request['usuario_solicitado_id']}");
        print("${request['estado']}");
      }

      hideLoadingOverlay();
    } catch (err) {
      hideLoadingOverlay();
      print("Error al cargar solicitudes enviadas: $err");
    }
  }
}
