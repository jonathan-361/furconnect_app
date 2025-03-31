import 'package:furconnect/features/data/services/api_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:furconnect/features/data/services/login_service.dart';

class SocketService {
  late IO.Socket _socket;

  final LoginService _loginService;

  SocketService(this._loginService);

  void connect() {
    // Configurar la conexión del socket
    _socket = IO.io('https://furconnect.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    // Manejar eventos de conexión
    _socket.onConnect((_) {
      print('Conectado al servidor de WebSocket');
    });

    _socket.onDisconnect((_) {
      print('Desconectado del servidor de WebSocket');
    });

    _socket.onError((error) {
      print('Error en la conexión del WebSocket: $error');
    });

    // Conectar el socket
    _socket.connect();
  }

  void disconnect() {
    _socket.disconnect();
  }

  void sendMessage(
      String chatRoomId, String senderId, String content, String tempId) {
    try {
      _socket.emit('sendMessage', {
        'chatRoomId': chatRoomId,
        'sender': senderId,
        'content': content,
        'tempId': tempId,
      });
    } catch (e) {
      print('Error al enviar mensaje: $e');
    }
  }

  void onReceiveMessage(Function(Map<String, dynamic>) callback) {
    try {
      _socket.on('receiveMessage', (data) {
        if (data['tempId'] == null) {
          callback(data);
        }
      });
    } catch (err) {
      print('Error al recibir mensaje: $err');
    }
  }

  void joinRoom(String chatRoomId) {
    _socket.emit('joinRoom', chatRoomId);
  }
}
