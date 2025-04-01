import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:ui';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/user_service.dart';
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
  final UserService _userService =
      UserService(ApiService(), LoginService(ApiService()));
  List<dynamic> _chats = [];
  bool isLoading = true;
  String? errorMessage;
  String _userStatus = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _printUserStatus();
    _fetchChats();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchChats();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        chatData.sort((a, b) {
          final aMessages = a['mensajes'] ?? [];
          final bMessages = b['mensajes'] ?? [];
          final String aId = a['_id'] ?? '';
          final String bId = b['_id'] ?? '';
          final int aVersion = a['__v'] ?? 0;
          final int bVersion = b['__v'] ?? 0;

          if (aMessages.isNotEmpty && bMessages.isNotEmpty) {
            final aTimestamp =
                aMessages.last['timestamp'] ?? '1970-01-01T00:00:00.000Z';
            final bTimestamp =
                bMessages.last['timestamp'] ?? '1970-01-01T00:00:00.000Z';
            return bTimestamp.compareTo(aTimestamp);
          }

          if (aMessages.isNotEmpty && bMessages.isEmpty) {
            final aTimestamp =
                aMessages.last['timestamp'] ?? '1970-01-01T00:00:00.000Z';
            if (bId.compareTo(aId) > 0) {
              return 1;
            }
            if (bVersion > aVersion) {
              return 1;
            }
            return -1;
          }

          if (bMessages.isNotEmpty && aMessages.isEmpty) {
            final bTimestamp =
                bMessages.last['timestamp'] ?? '1970-01-01T00:00:00.000Z';
            if (aId.compareTo(bId) > 0) {
              return -1;
            }
            if (aVersion > bVersion) {
              return -1;
            }
            return 1;
          }

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
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchChats,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(
                        child: Text(
                          errorMessage!,
                          style:
                              const TextStyle(fontSize: 18, color: Colors.red),
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
                                const SizedBox(height: 16),
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
                          ),
          ),
          if (_userStatus == 'gratis')
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  backgroundBlendMode: BlendMode.lighten,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          if (_userStatus == 'gratis')
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 50, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Actualiza a Premium para ver tus chats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF894936),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      // Navegar a la pantalla de actualización a premium
                      context.push('/furconnectPlus');
                    },
                    child: const Text(
                      'Actualizar a Premium',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _navigateToChat(
      BuildContext context, Map<String, dynamic> chat) async {
    if (_userStatus == 'gratis') {
      // Mostrar diálogo o mensaje indicando que necesita ser premium
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Función Premium'),
          content: const Text(
              'Necesitas actualizar a Premium para acceder a los chats.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/furconnectPlus');
              },
              child: const Text('Actualizar'),
            ),
          ],
        ),
      );
      return;
    }

    final chatId = chat['_id'];
    final name = await getNameForChat(chat);

    await context.push<bool>('/chat', extra: {
      'chatId': chatId,
      'name': name,
      'onMessageSent': true,
    });

    _fetchChats();
  }

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

      return usuarios[1]["nombre"] ?? "Usuario desconocido";
    } catch (err) {
      print('Error al obtener el nombre: $err');
      return "Usuario desconocido";
    }
  }

  Future<String?> _getUserId() async {
    try {
      final loginService = LoginService(ApiService());
      await loginService.loadToken();
      final token = loginService.authToken;

      if (token == null) {
        return null;
      }

      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['id'];
    } catch (err) {
      print('Error al decodificar el token: $err');
      return null;
    }
  }

  Future<String?> _getUserStatus() async {
    try {
      final userId = await _getUserId();
      if (userId != null) {
        final userData = await _userService.getUserById(userId);
        //return userData?['estatus'];
        return 'premium';
      }
      return null;
    } catch (err) {
      print('Error al obtener el estatus del usuario: $err');
      return null;
    }
  }

  void _printUserStatus() async {
    final userState = await _getUserStatus();
    if (userState != null) {
      setState(() {
        _userStatus = userState;
      });
      print('Estado del usuario: $userState');
    } else {
      print('No se pudo obtener el estado del usuario');
    }
  }
}
