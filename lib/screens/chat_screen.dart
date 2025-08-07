import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _service = ChatService();
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _loading = false;
  
  // Variables para reconocimiento de voz
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    
    // Mensaje inicial del asistente
    _messages.add(
      ChatMessage(
        role: ChatRole.assistant,
        content: "¡Hola! Soy tu asistente virtual. ¿En qué puedo ayudarte hoy?\n\n"
            "- Puedes preguntarme sobre:\n"
            "  Ver tipos de tamales\n\n"
            "- ¿Cuál es el combo más vendido?\n"
            "  Saber qué bebidas llevan canela\n\n"
            "- ¿Qué tamales son picantes?\n"
            "  ¿Cuál es la bebida más popular?",
      ),
    );
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done') {
            _stopListening();
          }
        },
        onError: (error) => print('Error: $error'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) => setState(() {
            _lastWords = result.recognizedWords;
            if (result.finalResult) {
              _controller.text = _lastWords;
              _stopListening();
            }
          }),
        );
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
      if (_lastWords.isNotEmpty) {
        _controller.text = _lastWords;
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(role: ChatRole.user, content: text));
      _loading = true;
    });
    
    _controller.clear();
    final reply = await _service.sendMessage(text);
    
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (reply != null) {
        _messages.add(ChatMessage(role: ChatRole.assistant, content: reply));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Asistente Virtual', style: TextStyle(color: Colors.white)),
            Text(
              'En línea',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade200,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue, // Color de fondo de la AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de tiempo
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.center,
            color: Colors.grey.shade100,
            child: Text(
              '5:17 PM',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_loading && index == _messages.length) {
                  return _buildTyping();
                }
                final msg = _messages[index];
                final isUser = msg.role == ChatRole.user;
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.lightBlueAccent.shade100
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: isUser ? Colors.black87 : Colors.grey.shade800,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red : Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all( 
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        color: Colors.white,
                      ),
                      onPressed: _startListening,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Escribe tu mensaje',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue, // Color azul para mejor contraste
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTyping() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.grey.shade500,
                    ),
                  ),
                  Positioned(
                    left: 8,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.grey.shade500,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text('Escribiendo...'),
          ],
        ),
      ),
    );
  }
}