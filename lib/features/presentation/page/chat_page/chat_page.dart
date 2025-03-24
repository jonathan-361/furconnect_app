import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/user_service.dart';
import 'package:furconnect/features/data/services/chat_service.dart';
import 'package:furconnect/features/data/services/socket_service.dart';
import 'package:furconnect/features/presentation/page/chat_page/emoji.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String name;

  ChatPage({
    super.key,
    required this.chatId,
    required this.name,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final String send = 'assets/images/svg/send-plane-2-line.svg';
  final String happyEmote = 'assets/images/svg/emotion-happy-line.svg';
  final String addFile = 'assets/images/svg/attachment-2.svg';

  final userService = UserService(ApiService(), LoginService(ApiService()));
  final chatService = ChatService(ApiService(), LoginService(ApiService()));
  late SocketService _socketService;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  String? _userId;
  bool _isLoadingMessage = true;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _currentPage = 1; // Start from page 1
  int _pageSize = 10;
  bool _hasMoreMessages = true;
  bool _emojiShowing = false;

  @override
  void initState() {
    super.initState();
    _socketService = SocketService(LoginService(ApiService()));
    _socketService.connect();
    _initializeChat();

    _socketService.joinRoom(widget.chatId);

    // Listen for new messages
    _socketService.onReceiveMessage((message) {
      setState(() {
        _messages.insert(0, message);
      });
    });

    // Listen for scroll events
    _scrollController.addListener(_onScroll);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // Scroll to top because list is reversed
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && _userId != null) {
      final newMessage = {
        'sender': _userId,
        'content': message,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Agregar el mensaje a la lista local
      setState(() {
        _messages.insert(0, newMessage);
      });

      // Enviar el mensaje a través del socket
      _socketService.sendMessage(widget.chatId, _userId!, message);

      // Limpiar el campo de texto
      _messageController.clear();

      // Desplazarse al final de la lista (inicio en lista invertida)
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _socketService.disconnect();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    await _getUserId();
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (_isLoadingMore || !_hasMoreMessages) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final chatData = await chatService.getChatById(widget.chatId);
      if (chatData != null && chatData['mensajes'] != null) {
        final allMessages =
            List<Map<String, dynamic>>.from(chatData['mensajes']);

        // Sort messages by timestamp if available, or keep original order
        allMessages.sort((a, b) {
          final aTime = a['timestamp'] ?? '';
          final bTime = b['timestamp'] ?? '';
          return bTime.compareTo(aTime); // Descending order (newest first)
        });

        // Calculate pagination
        final int startIndex = (_currentPage - 1) * _pageSize;
        final int endIndex = startIndex + _pageSize;

        // Check if we've reached the end
        if (startIndex >= allMessages.length) {
          setState(() {
            _hasMoreMessages = false;
            _isLoadingMore = false;
          });
          return;
        }

        // Get the page of messages
        final int actualEndIndex =
            endIndex > allMessages.length ? allMessages.length : endIndex;
        final List<Map<String, dynamic>> pageMessages =
            allMessages.sublist(startIndex, actualEndIndex);

        setState(() {
          if (_currentPage == 1) {
            // First page, replace all messages
            _messages = pageMessages;
          } else {
            // Add older messages to the end (which appears at the top when scrolling up)
            _messages.addAll(pageMessages);
          }
          _currentPage++;
          _isLoadingMessage = false;
        });

        // If we loaded fewer messages than page size, there are no more messages
        if (pageMessages.length < _pageSize) {
          setState(() {
            _hasMoreMessages = false;
          });
        }
      }
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    // When reaching the bottom of the list (since it's reversed, this is for older messages)
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore &&
        _hasMoreMessages) {
      _loadMessages();
    }
  }

  Future<void> _getUserId() async {
    try {
      final loginService = LoginService(ApiService());
      await loginService.loadToken();
      final token = loginService.authToken;

      if (token == null) {
        throw Exception("Authentication token not found.");
      }

      final decodedToken = JwtDecoder.decode(token);
      setState(() {
        _userId = decodedToken['id'];
      });
    } catch (e) {
      print('Error getting user ID: $e');
    }
  }

  bool _isMessageFromCurrentUser(Map<String, dynamic> message) {
    final senderId = message['sender'] is String
        ? message['sender']
        : message['sender']['_id'];
    return senderId == _userId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: Row(
          children: [
            BackButton(color: Colors.black),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
        centerTitle: true,
        title: Text(
          widget.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.3),
          child: Container(
            color: Colors.grey[300],
            height: 1.3,
          ),
        ),
      ),
      body: Container(
        color: theme.colorScheme.tertiary,
        height: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: _isLoadingMessage && _messages.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          reverse: true, // Show newest messages at the bottom
                          padding: EdgeInsets.all(10),
                          itemCount:
                              _messages.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show loading indicator at the end (top of reversed list)
                            if (_isLoadingMore && index == _messages.length) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final message = _messages[index];
                            final isSender = _isMessageFromCurrentUser(message);

                            return Align(
                              alignment: isSender
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: _ChatBubble(
                                message: message['content'],
                                isSender: isSender,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
            ),
            Offstage(
              offstage: !_emojiShowing,
              child: EmojiPickerWidget(
                textEditingController: _messageController,
                onEmojiSelected: () {
                  // Lógica adicional si es necesario
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1.5),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _emojiShowing = !_emojiShowing;
                      });
                    },
                    child: SvgPicture.asset(
                      happyEmote,
                      height: 25,
                      width: 25,
                      colorFilter: ColorFilter.mode(
                          theme.colorScheme.secondary, BlendMode.srcIn),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: theme.colorScheme.secondary,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: theme.colorScheme.secondary,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: theme.colorScheme.secondary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: SvgPicture.asset(
                      send,
                      height: 25,
                      width: 25,
                      colorFilter: ColorFilter.mode(
                          theme.colorScheme.secondary, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;

  const _ChatBubble({
    required this.message,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isSender ? Color.fromARGB(255, 153, 91, 62) : Colors.grey[300],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: isSender ? Radius.circular(20) : Radius.circular(5),
          bottomRight: isSender ? Radius.circular(5) : Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isSender ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
