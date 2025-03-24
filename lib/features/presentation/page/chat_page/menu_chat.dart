import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/chat_service.dart';
import 'package:furconnect/features/presentation/widget/chat/item_chat.dart';

class MenuChat extends StatefulWidget {
  const MenuChat({super.key});

  @override
  State<MenuChat> createState() => _MenuChatState();
}

class _MenuChatState extends State<MenuChat> with WidgetsBindingObserver {
  final ChatService _chatService =
      ChatService(ApiService(), LoginService(ApiService()));
  List<dynamic> _chats = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchChats();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Este método detecta cuando la pantalla vuelve a estar visible (por ejemplo, después de regresar)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchChats();
    }
  }

  // Este método se llama cuando la aplicación se reanuda después de estar en segundo plano
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Verificar si esta pantalla está activa
    if (ModalRoute.of(context)?.isCurrent == true) {
      _fetchChats();
    }
  }

  Future<void> _fetchChats() async {
    if (!mounted) return;

    try {
      setState(() {
        isLoading = true;
      });

      final chatData = await _chatService.getChats();

      if (mounted) {
        // Ordenar los chats por la fecha del último mensaje o novedad del chat
        chatData.sort((a, b) {
          // Obtener el último mensaje de cada chat
          final aMessages = a['mensajes'] ?? [];
          final bMessages = b['mensajes'] ?? [];

          // Extraer timestamps de los IDs (asumiendo que son ObjectIds de MongoDB)
          final String aId = a['_id'] ?? '';
          final String bId = b['_id'] ?? '';

          // Obtener versión (puede indicar cuán reciente es un chat)
          final int aVersion = a['__v'] ?? 0;
          final int bVersion = b['__v'] ?? 0;

          // Para chats con mensajes, usar el timestamp del último mensaje
          if (aMessages.isNotEmpty && bMessages.isNotEmpty) {
            final aTimestamp =
                aMessages.last['timestamp'] ?? '1970-01-01T00:00:00.000Z';
            final bTimestamp =
                bMessages.last['timestamp'] ?? '1970-01-01T00:00:00.000Z';
            return bTimestamp.compareTo(aTimestamp);
          }

          // Si un chat tiene mensajes y el otro no, el que tiene mensajes va primero
          // a menos que el chat sin mensajes sea más nuevo (basado en ID)
          if (aMessages.isNotEmpty && bMessages.isEmpty) {
            // Comparar timestamp del mensaje con la "novedad" del chat B
            final aTimestamp =
                aMessages.last['timestamp'] ?? '1970-01-01T00:00:00.000Z';

            // Si el ID de B parece más reciente, B va primero
            if (bId.compareTo(aId) > 0) {
              return 1; // B es más reciente (por ID), así que B va primero
            }

            // Si la versión de B es mayor, B podría ser más reciente
            if (bVersion > aVersion) {
              return 1; // B podría ser más reciente (por versión), así que B va primero
            }

            return -1; // A tiene mensajes y B no parece más reciente, así que A va primero
          }

          if (bMessages.isNotEmpty && aMessages.isEmpty) {
            // Comparar timestamp del mensaje con la "novedad" del chat A
            final bTimestamp =
                bMessages.last['timestamp'] ?? '1970-01-01T00:00:00.000Z';

            // Si el ID de A parece más reciente, A va primero
            if (aId.compareTo(bId) > 0) {
              return -1; // A es más reciente (por ID), así que A va primero
            }

            // Si la versión de A es mayor, A podría ser más reciente
            if (aVersion > bVersion) {
              return -1; // A podría ser más reciente (por versión), así que A va primero
            }

            return 1; // B tiene mensajes y A no parece más reciente, así que B va primero
          }

          // Si ninguno tiene mensajes, ordenar por ID (asumiendo que los IDs más recientes son mayores)
          // Lo que funciona bien con ObjectIds de MongoDB
          return bId.compareTo(aId);
        });

        setState(() {
          _chats = chatData;
          isLoading = false;
          errorMessage = null;
        });
      }
    } catch (err) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "Error al obtener los chats: ${err.toString()}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
        backgroundColor: const Color(0xFF894936),
      ),
      body: RefreshIndicator(
          onRefresh: _fetchChats,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    )
                  : _chats.isNotEmpty
                      ? ListView.builder(
                          itemCount: _chats.length,
                          itemBuilder: (context, index) {
                            final chat = _chats[index];
                            return ItemChat(
                              chat: chat,
                              onTap: () => _navigateToChat(context, chat),
                            );
                          },
                        )
                      : Center(
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
                                'No tienes chats aún',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )),
    );
  }

  // Método para navegar al chat y actualizar al regresar
  Future<void> _navigateToChat(
      BuildContext context, Map<String, dynamic> chat) async {
    final chatId = chat['_id'];
    final name = await getNameForChat(chat);

    // Navegar y esperar resultado
    await context.push<bool>('/chat', extra: {
      'chatId': chatId,
      'name': name,
      'onMessageSent': true, // Indica que queremos saber si se envió un mensaje
    });

    // Refrescar siempre al regresar
    _fetchChats();
  }

  // Método para obtener el nombre del chat
  Future<String> getNameForChat(Map<String, dynamic> chat) async {
    try {
      final loginService = LoginService(ApiService());
      await loginService.loadToken();
      final token = loginService.authToken;

      if (token == null) {
        return "Usuario desconocido";
      }

      final usuarios = chat['usuarios'] ?? [];
      if (usuarios.length < 2) {
        return "Usuario desconocido";
      }

      // Este código es simplificado y deberías usar tu lógica real aquí
      return usuarios[1]["nombre"] ?? "Usuario desconocido";
    } catch (err) {
      print('Error al obtener el nombre: $err');
      return "Usuario desconocido";
    }
  }
}
